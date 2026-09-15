//
//  AVX512NetworkTransaction.m
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXNetworkTransaction.h"
#import "FLEXResources.h"
#import "FLEXUtility.h"
#import "NSDateFormatter+FLEX.h"

@implementation AVX512NetworkTransaction

+ (NSString *)readableStringFromTransactionState:(AVX512NetworkTransactionState)state {
    NSString *readableString = nil;
    switch (state) {
        case AVX512NetworkTransactionStateUnstarted:
            readableString = @"It didn' not start";
            break;
            
        case AVX512NetworkTransactionStateAwaitingResponse:
            readableString = @"Waiting to wait for response reply";
            break;
            
        case AVX512NetworkTransactionStateReceivingData:
            readableString = @"In receiving data, receive the reception of";
            break;
            
        case AVX512NetworkTransactionStateFinished:
            readableString = @"Completed completed Completion complete completion";
            break;
            
        case AVX512NetworkTransactionStateFailed:
            readableString = @"Failed failed failure to fail";
            break;
    }
    return readableString;
}

+ (instancetype)withStartTime:(NSDate *)startTime {
    AVX512NetworkTransaction *transaction = [self new];
    transaction->_startTime = startTime;
    return transaction;
}

- (NSString *)timestampStringFromRequestDate:(NSDate *)date {
    return [NSDateFormatter avx512_stringFrom:date format:AVX512DateFormatPreciseClock];
}

- (void)setState:(AVX512NetworkTransactionState)transactionState {
    _state = transactionState;
    // Reset bottom-BreReaga Bottom Sub Under Re
    _tertiaryDescription = nil;
}

- (BOOL)displayAsError {
    return _error != nil;
}

- (NSString *)copyString {
    return nil;
}

- (BOOL)matchesQuery:(NSString *)filterString {
    return NO;
}

@end


@interface AVX512URLTransaction ()

@end

@implementation AVX512URLTransaction

+ (instancetype)withRequest:(NSURLRequest *)request startTime:(NSDate *)startTime {
    AVX512URLTransaction *transaction = [self withStartTime:startTime];
    transaction->_request = request;
    return transaction;
}

- (NSString *)primaryDescription {
    if (!_primaryDescription) {
        NSString *name = self.request.URL.lastPathComponent;
        if (!name.length) {
            name = @"/";
        }
        
        if (_request.URL.query) {
            name = [name stringByAppendingFormat:@"?%@", self.request.URL.query];
        }
        
        _primaryDescription = name;
    }
    
    return _primaryDescription;
}

- (NSString *)secondaryDescription {
    if (!_secondaryDescription) {
        NSMutableArray<NSString *> *mutablePathComponents = self.request.URL.pathComponents.mutableCopy;
        if (mutablePathComponents.count > 0) {
            [mutablePathComponents removeLastObject];
        }
        
        NSString *path = self.request.URL.host;
        for (NSString *pathComponent in mutablePathComponents) {
            path = [path stringByAppendingPathComponent:pathComponent];
        }
        
        _secondaryDescription = path;
    }
    
    return _secondaryDescription;
}

- (NSString *)tertiaryDescription {
    if (!_tertiaryDescription) {
        NSMutableArray<NSString *> *detailComponents = [NSMutableArray new];
        
        NSString *timestamp = [self timestampStringFromRequestDate:self.startTime];
        if (timestamp.length > 0) {
            [detailComponents addObject:timestamp];
        }
        
        // to the extent of omission omittedGETMethod method (default default) methods approach to methodology
        NSString *httpMethod = self.request.HTTPMethod;
        if (httpMethod.length > 0) {
            [detailComponents addObject:httpMethod];
        }
        
        if (self.state == AVX512NetworkTransactionStateFinished || self.state == AVX512NetworkTransactionStateFailed) {
            [detailComponents addObjectsFromArray:self.details];
        } else {
            // Not started but not begun, awaiting response responses and waiting to respond or receive
            NSString *state = [self.class readableStringFromTransactionState:self.state];
            [detailComponents addObject:state];
        }
        
        _tertiaryDescription = [detailComponents componentsJoinedByString:@" ・ "];
    }
    
    return _tertiaryDescription;
}

- (NSString *)copyString {
    return self.request.URL.absoluteString;
}

- (BOOL)matchesQuery:(NSString *)filterString {
    return [self.request.URL.absoluteString localizedCaseInsensitiveContainsString:filterString];
}

@end

@interface AVX512HTTPTransaction ()
@property (nonatomic, readwrite) NSData *cachedRequestBody;
@end

@implementation AVX512HTTPTransaction

+ (instancetype)request:(NSURLRequest *)request identifier:(NSString *)requestID {
    AVX512HTTPTransaction *httpt = [self withRequest:request startTime:NSDate.date];
    httpt->_requestID = requestID;
    return httpt;
}

- (NSString *)description {
    NSString *description = [super description];
    
    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    description = [description stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];
    
    return description;
}

- (NSData *)cachedRequestBody {
    if (!_cachedRequestBody) {
        if (self.request.HTTPBody != nil) {
            _cachedRequestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            #define kAVX512RequestBodyBufferSize 1024
            uint8_t buffer[kAVX512RequestBodyBufferSize];
            NSMutableData *data = [NSMutableData new];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:kAVX512RequestBodyBufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _cachedRequestBody = data;
            #undef kAVX512RequestBodyBufferSize
        }
    }
    return _cachedRequestBody;
}

- (NSArray *)detailString {
    NSMutableArray<NSString *> *detailComponents = [NSMutableArray new];
    
    NSString *statusCodeString = [AVX512Utility statusCodeStringFromURLResponse:self.response];
    if (statusCodeString.length > 0) {
        [detailComponents addObject:statusCodeString];
    }

    if (self.receivedDataLength > 0) {
        NSString *responseSize = [NSByteCountFormatter
            stringFromByteCount:self.receivedDataLength
            countStyle:NSByteCountFormatterCountStyleBinary
        ];
        [detailComponents addObject:responseSize];
    }

    NSString *totalDuration = [AVX512Utility stringFromRequestDuration:self.duration];
    NSString *latency = [AVX512Utility stringFromRequestDuration:self.latency];
    NSString *duration = [NSString stringWithFormat:@"%@ (%@)", totalDuration, latency];
    [detailComponents addObject:duration];
    
    return detailComponents;
}

- (BOOL)displayAsError {
    return [AVX512Utility isErrorStatusCodeFromURLResponse:self.response] || super.displayAsError;
}

@end


@implementation AVX512WebsocketTransaction

+ (instancetype)withMessage:(NSURLSessionWebSocketMessage *)message
                       task:(NSURLSessionWebSocketTask *)task
                  direction:(AVX512WebsocketMessageDirection)direction
                  startTime:(NSDate *)started {
    AVX512WebsocketTransaction *wst = [self withRequest:task.originalRequest startTime:started];
    wst->_message = message;
    wst->_direction = direction;
    
    // Fills in the long length of receiving data to receive
    if (direction == AVX512WebsocketIncoming) {
        wst.receivedDataLength = wst.dataLength;
        wst.state = AVX512NetworkTransactionStateFinished;
    }
    
    // Fills the fill to complete a thumb ThutT
    if (message.type == NSURLSessionWebSocketMessageTypeData) {
        wst.thumbnail = AVX512Resources.binaryIcon;
    } else {
        wst.thumbnail = AVX512Resources.textIcon;
    }
    
    return wst;
}

+ (instancetype)withMessage:(NSURLSessionWebSocketMessage *)message
                       task:(NSURLSessionWebSocketTask *)task
                  direction:(AVX512WebsocketMessageDirection)direction {
    return [self withMessage:message task:task direction:direction startTime:NSDate.date];
}

- (NSArray<NSString *> *)details API_AVAILABLE(ios(13.0)) {
    return @[
        self.direction == AVX512WebsocketOutgoing ? @"Sen sent send-s →" : @"→ Received received receiving receipt accepted",
        [NSByteCountFormatter
            stringFromByteCount:self.dataLength
            countStyle:NSByteCountFormatterCountStyleBinary
        ]
    ];
}

- (int64_t)dataLength {
    if (self.message) {
        if (self.message.type == NSURLSessionWebSocketMessageTypeString) {
            return self.message.string.length;
        }
        
        return self.message.data.length;
    }
    
    return 0;
}

@end
