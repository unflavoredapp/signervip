//
//  AVX512NetworkRecorder.m
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXNetworkRecorder.h"
#import "FLEXNetworkCurlLogger.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXUtility.h"
#import "FLEXResources.h"
#import "NSUserDefaults+FLEX.h"
#import "OSCache.h"

#define Synchronized(queue, obj) ({ \
    __block id __synchronized_retval = nil; \
    dispatch_sync(queue, ^{ __synchronized_retval = obj; }); \
    __synchronized_retval; \
})
    

NSString *const kAVX512NetworkRecorderNewTransactionNotification = @"kAVX512NetworkRecorderNewTransactionNotification";
NSString *const kAVX512NetworkRecorderTransactionUpdatedNotification = @"kAVX512NetworkRecorderTransactionUpdatedNotification";
NSString *const kAVX512NetworkRecorderUserInfoTransactionKey = @"transaction";
NSString *const kAVX512NetworkRecorderTransactionsClearedNotification = @"kAVX512NetworkRecorderTransactionsClearedNotification";

NSString *const kAVX512NetworkRecorderResponseCacheLimitDefaultsKey = @"com.flex.responseCacheLimit";

@interface AVX512NetworkRecorder ()

@property (nonatomic) OSCache *restCache;
@property (atomic) NSMutableArray<AVX512HTTPTransaction *> *orderedHTTPTransactions;
@property (atomic) NSMutableArray<AVX512WebsocketTransaction *> *orderedWSTransactions;
@property (atomic) NSMutableArray<AVX512FirebaseTransaction *> *orderedFirebaseTransactions;
@property (atomic) NSMutableDictionary<NSString *, __kindof AVX512NetworkTransaction *> *requestIDsToTransactions;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation AVX512NetworkRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.restCache = [OSCache new];
        NSUInteger responseCacheLimit = [[NSUserDefaults.standardUserDefaults
            objectForKey:kAVX512NetworkRecorderResponseCacheLimitDefaultsKey] unsignedIntegerValue
        ];
        
        // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
        self.restCache.totalCostLimit = responseCacheLimit ?: 25 * 1024 * 1024;
        [self.restCache setTotalCostLimit:responseCacheLimit];
        
        self.orderedWSTransactions = [NSMutableArray new];
        self.orderedHTTPTransactions = [NSMutableArray new];
        self.orderedFirebaseTransactions = [NSMutableArray new];
        self.requestIDsToTransactions = [NSMutableDictionary new];
        self.hostDenylist = NSUserDefaults.standardUserDefaults.avx512_networkHostDenylist.mutableCopy;

        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.flex.AVX512NetworkRecorder", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)defaultRecorder {
    static AVX512NetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [self new];
    });
    
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit {
    return self.restCache.totalCostLimit;
}

- (void)setResponseCacheByteLimit:(NSUInteger)responseCacheByteLimit {
    self.restCache.totalCostLimit = responseCacheByteLimit;
    [NSUserDefaults.standardUserDefaults
        setObject:@(responseCacheByteLimit)
        forKey:kAVX512NetworkRecorderResponseCacheLimitDefaultsKey
    ];
}

- (NSArray<AVX512HTTPTransaction *> *)HTTPTransactions {
    return Synchronized(self.queue, self.orderedHTTPTransactions.copy);
}

- (NSArray<AVX512WebsocketTransaction *> *)websocketTransactions {
    return Synchronized(self.queue, self.orderedWSTransactions.copy);
}

- (NSArray<AVX512FirebaseTransaction *> *)firebaseTransactions {
    return Synchronized(self.queue, self.orderedFirebaseTransactions.copy);
}

- (NSData *)cachedResponseBodyForTransaction:(AVX512HTTPTransaction *)transaction {
    return [self.restCache objectForKey:transaction.requestID];
}

- (void)clearRecordedActivity {
    dispatch_async(self.queue, ^{
        [self.restCache removeAllObjects];
        [self.orderedWSTransactions removeAllObjects];
        [self.orderedHTTPTransactions removeAllObjects];
        [self.orderedFirebaseTransactions removeAllObjects];
        [self.requestIDsToTransactions removeAllObjects];
        
        [self notify:kAVX512NetworkRecorderTransactionsClearedNotification transaction:nil];
    });
}

- (void)clearRecordedActivity:(AVX512NetworkTransactionKind)kind matching:(NSString *)query {
    dispatch_async(self.queue, ^{
        switch (kind) {
            case AVX512NetworkTransactionKindFirebase: {
                [self.orderedFirebaseTransactions avx512_filter:^BOOL(AVX512FirebaseTransaction *obj, NSUInteger idx) {
                    return ![obj matchesQuery:query];
                }];
                break;
            }
            case AVX512NetworkTransactionKindREST: {
                NSArray<AVX512HTTPTransaction *> *toRemove;
                toRemove = [self.orderedHTTPTransactions avx512_filtered:^BOOL(AVX512HTTPTransaction *obj, NSUInteger idx) {
                    return [obj matchesQuery:query];
                }];
                
                // Remove from cache
                for (AVX512HTTPTransaction *t in toRemove) {
                    [self.restCache removeObjectForKey:t.requestID];
                }
                
                // Remove from list
                [self.orderedHTTPTransactions removeObjectsInArray:toRemove];
                
                break;
            }
            case AVX512NetworkTransactionKindWebsockets: {
                [self.orderedWSTransactions avx512_filter:^BOOL(AVX512WebsocketTransaction *obj, NSUInteger idx) {
                    return ![obj matchesQuery:query];
                }];
                break;
            }
        }
        
        [self notify:kAVX512NetworkRecorderTransactionsClearedNotification transaction:nil];
    });
}

- (void)clearExcludedTransactions {
    dispatch_sync(self.queue, ^{
        self.orderedHTTPTransactions = ({
            [self.orderedHTTPTransactions avx512_filtered:^BOOL(AVX512HTTPTransaction *ta, NSUInteger idx) {
                NSString *host = ta.request.URL.host;
                for (NSString *excluded in self.hostDenylist) {
                    if ([host hasSuffix:excluded]) {
                        return NO;
                    }
                }
                
                return YES;
            }];
        });
    });
}

- (void)synchronizeDenylist {
    NSUserDefaults.standardUserDefaults.avx512_networkHostDenylist = self.hostDenylist;
}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(NSURLRequest *)request
                            redirectResponse:(NSURLResponse *)redirectResponse {
    for (NSString *host in self.hostDenylist) {
        if ([request.URL.host hasSuffix:host]) {
            return;
        }
    }
    
    AVX512HTTPTransaction *transaction = [AVX512HTTPTransaction request:request identifier:requestID];

    // Before async block to keep times accurate
    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }

    // A redirect is always a new request
    dispatch_async(self.queue, ^{
        [self.orderedHTTPTransactions insertObject:transaction atIndex:0];
        self.requestIDsToTransactions[requestID] = transaction;

        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response {
    // Before async block to stay accurate
    NSDate *responseDate = [NSDate date];

    dispatch_async(self.queue, ^{
        AVX512HTTPTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.response = response;
        transaction.state = AVX512NetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength {
    dispatch_async(self.queue, ^{
        AVX512HTTPTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.receivedDataLength += dataLength;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody {
    NSDate *finishedDate = [NSDate date];

    dispatch_async(self.queue, ^{
        AVX512HTTPTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.state = AVX512NetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];

        BOOL shouldCache = responseBody.length > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray<NSString *> *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.restCache setObject:responseBody forKey:requestID cost:responseBody.length];
        }

        NSString *mimeType = transaction.response.MIMEType;
        if ([mimeType hasPrefix:@"image/"] && responseBody.length > 0) {
            // Thumbnail image previews on a separate background queue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSInteger maxPixelDimension = UIScreen.mainScreen.scale * 32.0;
                transaction.thumbnail = [AVX512Utility
                    thumbnailedImageWithMaxPixelDimension:maxPixelDimension
                    fromImageData:responseBody
                ];
                [self postUpdateNotificationForTransaction:transaction];
            });
        } else if ([mimeType isEqual:@"application/json"]) {
            transaction.thumbnail = AVX512Resources.jsonIcon;
        } else if ([mimeType isEqual:@"text/plain"]){
            transaction.thumbnail = AVX512Resources.textPlainIcon;
        } else if ([mimeType isEqual:@"text/html"]) {
            transaction.thumbnail = AVX512Resources.htmlIcon;
        } else if ([mimeType isEqual:@"application/x-plist"]) {
            transaction.thumbnail = AVX512Resources.plistIcon;
        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
            transaction.thumbnail = AVX512Resources.binaryIcon;
        } else if ([mimeType containsString:@"javascript"]) {
            transaction.thumbnail = AVX512Resources.jsIcon;
        } else if ([mimeType containsString:@"xml"]) {
            transaction.thumbnail = AVX512Resources.xmlIcon;
        } else if ([mimeType hasPrefix:@"audio"]) {
            transaction.thumbnail = AVX512Resources.audioIcon;
        } else if ([mimeType hasPrefix:@"video"]) {
            transaction.thumbnail = AVX512Resources.videoIcon;
        } else if ([mimeType hasPrefix:@"text"]) {
            transaction.thumbnail = AVX512Resources.textIcon;
        }
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error {
    dispatch_async(self.queue, ^{
        AVX512HTTPTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.state = AVX512NetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID {
    dispatch_async(self.queue, ^{
        AVX512HTTPTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.requestMechanism = mechanism;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark - Websocket Events

- (void)recordWebsocketMessageSend:(NSURLSessionWebSocketMessage *)message task:(NSURLSessionWebSocketTask *)task {
    dispatch_async(self.queue, ^{
        AVX512WebsocketTransaction *send = [AVX512WebsocketTransaction
            withMessage:message task:task direction:AVX512WebsocketOutgoing
        ];
        
        [self.orderedWSTransactions insertObject:send atIndex:0];
        [self postNewTransactionNotificationWithTransaction:send];
    });
}

- (void)recordWebsocketMessageSendCompletion:(NSURLSessionWebSocketMessage *)message error:(NSError *)error {
    dispatch_async(self.queue, ^{
        AVX512WebsocketTransaction *send = [self.orderedWSTransactions avx512_firstWhere:^BOOL(AVX512WebsocketTransaction *t) {
            return t.message == message;
        }];
        send.error = error;
        send.state = error ? AVX512NetworkTransactionStateFailed : AVX512NetworkTransactionStateFinished;
        
        [self postUpdateNotificationForTransaction:send];
    });
}

- (void)recordWebsocketMessageReceived:(NSURLSessionWebSocketMessage *)message task:(NSURLSessionWebSocketTask *)task {
    dispatch_async(self.queue, ^{
        AVX512WebsocketTransaction *receive = [AVX512WebsocketTransaction
            withMessage:message task:task direction:AVX512WebsocketIncoming
        ];
        
        [self.orderedWSTransactions insertObject:receive atIndex:0];
        [self postNewTransactionNotificationWithTransaction:receive];
    });
}

#pragma mark - Firebase, Reading

- (void)recordFIRQueryWillFetch:(FIRQuery *)query withTransactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction queryFetch:query];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRDocumentWillFetch:(FIRDocumentReference *)document withTransactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction documentFetch:document];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRQueryDidFetch:(FIRQuerySnapshot *)response error:(NSError *)error transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = self.requestIDsToTransactions[transactionID];
        if (!transaction) {
            return;
        }
        
        transaction.error = error;
        transaction.documents = response.documents;
        transaction.state = AVX512NetworkTransactionStateFinished;
        [self.orderedFirebaseTransactions insertObject:transaction atIndex:0];
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordFIRDocumentDidFetch:(FIRDocumentSnapshot *)response error:(NSError *)error transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = self.requestIDsToTransactions[transactionID];
        if (!transaction) {
            return;
        }
        
        transaction.error = error;
        transaction.documents = response ? @[response] : @[];
        transaction.state = AVX512NetworkTransactionStateFinished;
        [self.orderedFirebaseTransactions insertObject:transaction atIndex:0];
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Firebase, Writing

- (void)recordFIRWillSetData:(FIRDocumentReference *)doc
                        data:(NSDictionary *)documentData
                       merge:(NSNumber *)yesorno
                 mergeFields:(NSArray *)fields
               transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction
            setData:doc data:documentData merge:yesorno mergeFields:fields
        ];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRWillUpdateData:(FIRDocumentReference *)doc fields:(NSDictionary *)fields
                  transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction updateData:doc data:fields];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRWillDeleteDocument:(FIRDocumentReference *)doc transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction deleteDocument:doc];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRWillAddDocument:(FIRCollectionReference *)initiator document:(FIRDocumentReference *)doc
                   transactionID:(NSString *)transactionID {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = [AVX512FirebaseTransaction
            addDocument:initiator document:doc
        ];
        self.requestIDsToTransactions[transactionID] = transaction;
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordFIRDidSetData:(NSError *)error transactionID:(NSString *)transactionID {
    [self firebaseTransaction:transactionID didUpdate:error];
}

- (void)recordFIRDidUpdateData:(NSError *)error transactionID:(NSString *)transactionID {
    [self firebaseTransaction:transactionID didUpdate:error];
}

- (void)recordFIRDidDeleteDocument:(NSError *)error transactionID:(NSString *)transactionID {
    [self firebaseTransaction:transactionID didUpdate:error];
}

- (void)recordFIRDidAddDocument:(NSError *)error transactionID:(NSString *)transactionID {
    [self firebaseTransaction:transactionID didUpdate:error];
}

- (void)firebaseTransaction:(NSString *)transactionID didUpdate:(NSError *)error {
    dispatch_async(self.queue, ^{
        AVX512FirebaseTransaction *transaction = self.requestIDsToTransactions[transactionID];
        if (!transaction) {
            return;
        }
        
        transaction.error = error;
        transaction.state = AVX512NetworkTransactionStateFinished;
        [self.orderedFirebaseTransactions insertObject:transaction atIndex:0];
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark - Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(AVX512NetworkTransaction *)transaction {
    [self notify:kAVX512NetworkRecorderNewTransactionNotification transaction:transaction];
}

- (void)postUpdateNotificationForTransaction:(AVX512NetworkTransaction *)transaction {
    [self notify:kAVX512NetworkRecorderTransactionUpdatedNotification transaction:transaction];
}

- (void)notify:(NSString *)name transaction:(AVX512NetworkTransaction *)transaction {
    NSDictionary *userInfo = nil;
    if (transaction) {
        userInfo = @{ kAVX512NetworkRecorderUserInfoTransactionKey : transaction };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:name object:self userInfo:userInfo];
    });
}

@end
