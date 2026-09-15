//
//  AVX512NetworkObserver.m
//  from the source of origin:
//
//  PDAFNetworkDomainController.m
//  PonyDebugger
//
//  Created by Mike Lewis on 2/27/12.
//
//  Licences granted under a licence permit to be licensed in accordance with oneSquare, Inc.
//  Please refer to the licence document in which you distributed this work.
//
//  By being by and subjectTanner BennettMany changes and additions have been substantially modified, adapted or added to it by various other
//  git blameThe details of these changes are detailed in detail. These
//

#import "FLEXNetworkObserver.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXUtility.h"
#import "NSUserDefaults+FLEX.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXMethod.h"
#import "Firestore.h"

#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/queue.h>
#include <dlfcn.h>

NSString *const kAVX512NetworkObserverEnabledStateChangedNotification = @"kAVX512NetworkObserverEnabledStateChangedNotification";

typedef void (^NSURLSessionAsyncCompletion)(id fileURLOrData, NSURLResponse *response, NSError *error);
typedef NSURLSessionTask * (^NSURLSessionNewTaskMethod)(NSURLSession *, id, NSURLSessionAsyncCompletion);

@interface AVX512InternalRequestState : NSObject

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic) NSMutableData *dataAccumulator;

@end

@implementation AVX512InternalRequestState

@end

@interface AVX512NetworkObserver (NSURLConnectionHelpers)

- (void)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data delegate:(id<NSURLConnectionDelegate>)delegate;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection delegate:(id<NSURLConnectionDelegate>)delegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error delegate:(id<NSURLConnectionDelegate>)delegate;

- (void)connectionWillCancel:(NSURLConnection *)connection;

@end


@interface AVX512NetworkObserver (NSURLSessionTaskHelpers)

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite delegate:(id<NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location data:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate;

- (void)URLSessionTaskWillResume:(NSURLSessionTask *)task;

- (void)websocketTask:(NSURLSessionWebSocketTask *)task
        sendMessagage:(NSURLSessionWebSocketMessage *)message API_AVAILABLE(ios(13.0));
- (void)websocketTaskMessageSendCompletion:(NSURLSessionWebSocketMessage *)message
                                     error:(NSError *)error API_AVAILABLE(ios(13.0));

- (void)websocketTask:(NSURLSessionWebSocketTask *)task
     receiveMessagage:(NSURLSessionWebSocketMessage *)message
                error:(NSError *)error API_AVAILABLE(ios(13.0));

@end

@interface AVX512NetworkObserver ()

@property (nonatomic) NSMutableDictionary<NSString *, AVX512InternalRequestState *> *requestStatesForRequestIDs;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation AVX512NetworkObserver

#pragma mark - Public Methods

+ (void)setEnabled:(BOOL)enabled {
    BOOL previouslyEnabled = [self isEnabled];
    
    NSUserDefaults.standardUserDefaults.avx512_networkObserverEnabled = enabled;
    
    if (enabled) {
        // If necessary, inject the injection into if you need to do it. Thedispatch_onceProtection, so we can safely call it a number of times and several calls. It's
        // We can lower the impact of tools when this function is not disabled, through delayed inject injection via a delay input. When
        [self setNetworkMonitorHooks];
    }
    
    if (previouslyEnabled != enabled) {
        [NSNotificationCenter.defaultCenter postNotificationName:kAVX512NetworkObserverEnabledStateChangedNotification object:self];
    }
}

+ (BOOL)isEnabled {
    return NSUserDefaults.standardUserDefaults.avx512_networkObserverEnabled;
}

+ (void)load {
    // We do not want us to hope+loadIt's a method exchange, because we want all of the hook-ing that
    // The proxy class may not have been loaded to the agent category.
    // However, however yet neverthelessFirebaseThe class category must have been loaded by now. It's certainly already
    // So so we can hook up to these types earlier, sooner and early.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isEnabled]) {
            [self setNetworkMonitorHooks];
        }
    });
}

#pragma mark - Statics

+ (instancetype)sharedObserver {
    static AVX512NetworkObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [self new];
    });
    return sharedObserver;
}

+ (NSString *)nextRequestID {
    return NSUUID.UUID.UUIDString;
}

#pragma mark The agent injects a simple and easy-tre

/// All exchanges (all all swapsswizzledThis protective measure should be used as a safeguard.
/// This will prevent this from preventing the repetition of repeated sniffing and sn-sc again when a parent
/// We have also exchanged this patri fulfil in exchange for the parent. If it is called from original, if a call was made out of
/// (as well as the achievement in upper classes) will be implemented without interference. It is performed undistur
+ (void)sniffWithoutDuplicationForObject:(NSObject *)object selector:(SEL)selector
                           sniffingBlock:(void (^)(void))sniffingBlock originalImplementationBlock:(void (^)(void))originalImplementationBlock {
    // If we don't have an object to detect the nested call if you do not possess one of any objects that will test a embedded
    // If if, whatURLThis may occur when a person outside the loading system is not part of load-inloading systems directly calls for proxy
    // For illustrative examples, see See for example https://github.com/Flipboard/FLEX/issues/61
    if (!object) {
        originalImplementationBlock();
        return;
    }

    const void *key = selector;

    // Don't run running the sniff-sn nose detection block not to operate a ruler/
    if (!objc_getAssociatedObject(object, key)) {
        sniffingBlock();
    }

    // Mark marks we're calling the original method, so that let us detect nesting and call calls to use embedded sets
    objc_setAssociatedObject(object, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    originalImplementationBlock();
    objc_setAssociatedObject(object, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Hooking

static void (*_logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$)(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, FIRDocumentSnapshotBlock);
static void _logos_method$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, FIRDocumentSnapshotBlock);
static void (*_logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$)(
    _LOGOS_SELF_TYPE_NORMAL FIRQuery * _LOGOS_SELF_CONST, SEL, FIRQuerySnapshotBlock);
static void _logos_method$_ungrouped$FIRQuery$getDocumentsWithCompletion$(
    _LOGOS_SELF_TYPE_NORMAL FIRQuery * _LOGOS_SELF_CONST, SEL, FIRQuerySnapshotBlock);

static void (*_logos_orig$_ungrouped$FIRDocumentReference$setData$merge$completion$)(
 _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, NSDictionary *, BOOL, void (^)(NSError *));
static void (*_logos_orig$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$)(
 _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, NSDictionary *, NSArray *, void (^)(NSError *));
static void (*_logos_orig$_ungrouped$FIRDocumentReference$updateData$completion$)(
 _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, NSDictionary *, void (^)(NSError *));
static void (*_logos_orig$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$)(
 _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, void (^)(NSError *));

static void _logos_register_hook(Class _class, SEL _cmd, IMP _new, IMP *_old) {
    unsigned int _count, _i;
    Class _searchedClass = _class;
    Method *_methods;
    while (_searchedClass) {
        _methods = class_copyMethodList(_searchedClass, &_count);
        for (_i = 0; _i < _count; _i++) {
            if (method_getName(_methods[_i]) == _cmd) {
                if (_class == _searchedClass) {
                    *_old = method_getImplementation(_methods[_i]);
                    *_old = class_replaceMethod(_class, _cmd, _new, method_getTypeEncoding(_methods[_i]));
                } else {
                    class_addMethod(_class, _cmd, _new, method_getTypeEncoding(_methods[_i]));
                }
                free(_methods);
                return;
            }
        }
        free(_methods);
        _searchedClass = class_getSuperclass(_searchedClass);
    }
}

static Class _logos_superclass$_ungrouped$FIRDocumentReference;
static void (*_logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$)(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST, SEL, FIRDocumentSnapshotBlock);
static Class _logos_superclass$_ungrouped$FIRQuery;
static void (*_logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$)(
    _LOGOS_SELF_TYPE_NORMAL FIRQuery * _LOGOS_SELF_CONST, SEL, FIRQuerySnapshotBlock);
static Class _logos_superclass$_ungrouped$FIRCollectionReference;
static FIRDocumentReference * (*_logos_orig$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$)(
    _LOGOS_SELF_TYPE_NORMAL FIRCollectionReference * _LOGOS_SELF_CONST, SEL, NSDictionary *, void (^)(NSError *error));

#pragma mark Firebase, Reads to read data-reading

static void _logos_method$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST self, SEL _cmd, FIRDocumentSnapshotBlock completion) {
    
    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder recordFIRDocumentWillFetch:self withTransactionID:requestID];
    // Hang on to the echo-back.
    FIRDocumentSnapshotBlock orig = completion;
    completion = ^(FIRDocumentSnapshot *document, NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDocumentDidFetch:document error:error transactionID:requestID];
        if (orig != nil) {
            orig(document, error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$ ? _logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$ : (__typeof__(_logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRDocumentReference, @selector(getDocumentWithCompletion:)))(self, _cmd, completion);
}

static void _logos_method$_ungrouped$FIRQuery$getDocumentsWithCompletion$(
    _LOGOS_SELF_TYPE_NORMAL FIRQuery * _LOGOS_SELF_CONST self, SEL _cmd, FIRQuerySnapshotBlock completion) {
    
    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder recordFIRQueryWillFetch:self withTransactionID:requestID];
    // Hang on to the echo-back.
    FIRQuerySnapshotBlock orig = completion;
    completion = ^(FIRQuerySnapshot *query, NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRQueryDidFetch:query error:error transactionID:requestID];
        if (orig != nil) {
            orig(query, error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$ ? _logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$ : (__typeof__(_logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRQuery, @selector(getDocumentsWithCompletion:)))(self, _cmd, completion);
}

#pragma mark Firebase, Write to write writing data into the

static void _logos_method$_ungrouped$FIRDocumentReference$setData$merge$completion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST __unused self,
    SEL __unused _cmd, NSDictionary<NSString *, id> * documentData, BOOL merge, void (^completion)(NSError *)) {

    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder
        recordFIRWillSetData:self
        data:documentData
        merge:@(merge)
        mergeFields:nil
        transactionID:requestID
    ];
    
    // Hang on to the echo-back.
    void (^orig)(NSError *) = completion;
    completion = ^(NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDidSetData:error transactionID:requestID];
        if (orig != nil) {
            orig(error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRDocumentReference$setData$merge$completion$ ? _logos_orig$_ungrouped$FIRDocumentReference$setData$merge$completion$ : (__typeof__(_logos_orig$_ungrouped$FIRDocumentReference$setData$merge$completion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRDocumentReference, @selector(setData:merge:completion:)))(self, _cmd, documentData, merge, completion);
}

static void _logos_method$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST __unused self,
    SEL __unused _cmd, NSDictionary<NSString *, id> * documentData,
    NSArray * mergeFields, void (^completion)(NSError *)) {

    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder
        recordFIRWillSetData:self
        data:documentData
        merge:nil
        mergeFields:mergeFields
        transactionID:requestID
    ];

    // Hang on to the echo-back.
    void (^orig)(NSError *) = completion;
    completion = ^(NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDidSetData:error transactionID:requestID];
        if (orig != nil) {
            orig(error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$ ? _logos_orig$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$ : (__typeof__(_logos_orig$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRDocumentReference, @selector(setData:mergeFields:completion:)))(self, _cmd, documentData, mergeFields, completion);
}

static void _logos_method$_ungrouped$FIRDocumentReference$updateData$completion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST __unused self,
    SEL __unused _cmd, NSDictionary<id, id> * fields, void (^completion)(NSError *)) {

    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder recordFIRWillUpdateData:self fields:fields transactionID:requestID];
    // Hang on to the echo-back.
    void (^orig)(NSError *) = completion;
    completion = ^(NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDidUpdateData:error transactionID:requestID];
        if (orig != nil) {
            orig(error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRDocumentReference$updateData$completion$ ? _logos_orig$_ungrouped$FIRDocumentReference$updateData$completion$ : (__typeof__(_logos_orig$_ungrouped$FIRDocumentReference$updateData$completion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRDocumentReference, @selector(updateData:completion:)))(self, _cmd, fields, completion);
}

static void _logos_method$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$(
    _LOGOS_SELF_TYPE_NORMAL FIRDocumentReference * _LOGOS_SELF_CONST __unused self,
    SEL __unused _cmd, void (^completion)(NSError *)) {

    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];
    
    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder recordFIRWillDeleteDocument:self transactionID:requestID];
    // Hang on to the echo-back.
    void (^orig)(NSError *) = completion;
    completion = ^(NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDidDeleteDocument:error transactionID:requestID];
        if (orig != nil) {
            orig(error);
        }
    };
    
    // Forward-Add forwarded forwarding call calls to
    (_logos_orig$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$ ? _logos_orig$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$ : (__typeof__(_logos_orig$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRDocumentReference, @selector(deleteDocumentWithCompletion:)))(self, _cmd, completion);
}

static FIRDocumentReference * _logos_method$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$(
    _LOGOS_SELF_TYPE_NORMAL FIRCollectionReference * _LOGOS_SELF_CONST __unused self,
    SEL __unused _cmd, NSDictionary<NSString *, id> * data, void (^completion)(NSError *error)) {

    // Gene generation of services to generate theID
    NSString *requestID = [AVX512NetworkObserver nextRequestID];

    // Hang on to the echo-back.
    void (^orig)(NSError *) = completion;
    completion = ^(NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordFIRDidAddDocument:error transactionID:requestID];
        if (orig != nil) {
            orig(error);
        }
    };

    // Forward-Add forwarded forwarding call calls to
    FIRDocumentReference *ret = (_logos_orig$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$ ? _logos_orig$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$ : (__typeof__(_logos_orig$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$))class_getMethodImplementation(_logos_superclass$_ungrouped$FIRCollectionReference, @selector(addDocumentWithData:completion:)))(self, _cmd, data, completion);

    // Recording services start recording transaction and record
    [AVX512NetworkRecorder.defaultRecorder recordFIRWillAddDocument:self document:ret transactionID:requestID];

    // Returns Return return returned returns
    return ret;
}

+ (void)setNetworkMonitorHooks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hookFirebaseThings];
        [self injectIntoAllNSURLThings];
    });
}

+ (void)hookFirebaseThings {
    Class _logos_class$_ungrouped$FIRDocumentReference = objc_getClass("FIRDocumentReference");
    _logos_superclass$_ungrouped$FIRDocumentReference = class_getSuperclass(_logos_class$_ungrouped$FIRDocumentReference);
    Class _logos_class$_ungrouped$FIRQuery = objc_getClass("FIRQuery");
    _logos_superclass$_ungrouped$FIRQuery = class_getSuperclass(_logos_class$_ungrouped$FIRQuery);
    Class _logos_class$_ungrouped$FIRCollectionReference = objc_getClass("FIRCollectionReference");
    _logos_superclass$_ungrouped$FIRCollectionReference = class_getSuperclass(_logos_class$_ungrouped$FIRCollectionReference);

    // Read a read-read reading and //

    _logos_register_hook(
        _logos_class$_ungrouped$FIRDocumentReference,
        @selector(getDocumentWithCompletion:),
        (IMP)&_logos_method$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$,
        (IMP *)&_logos_orig$_ungrouped$FIRDocumentReference$getDocumentWithCompletion$
    );

    _logos_register_hook(
        _logos_class$_ungrouped$FIRQuery,
        @selector(getDocumentsWithCompletion:),
        (IMP)&_logos_method$_ungrouped$FIRQuery$getDocumentsWithCompletion$,
        (IMP *)&_logos_orig$_ungrouped$FIRQuery$getDocumentsWithCompletion$
    );

    // Write to write written writing //

    _logos_register_hook(
        _logos_class$_ungrouped$FIRDocumentReference,
        @selector(setData:merge:completion:),
        (IMP)&_logos_method$_ungrouped$FIRDocumentReference$setData$merge$completion$,
        (IMP *)&_logos_orig$_ungrouped$FIRDocumentReference$setData$merge$completion$
    );
    _logos_register_hook(
        _logos_class$_ungrouped$FIRDocumentReference,
        @selector(setData:mergeFields:completion:),
        (IMP)&_logos_method$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$,
        (IMP *)&_logos_orig$_ungrouped$FIRDocumentReference$setData$mergeFields$completion$
    );
    _logos_register_hook(
        _logos_class$_ungrouped$FIRDocumentReference,
        @selector(updateData:completion:),
        (IMP)&_logos_method$_ungrouped$FIRDocumentReference$updateData$completion$,
        (IMP *)&_logos_orig$_ungrouped$FIRDocumentReference$updateData$completion$
    );
    _logos_register_hook(
        _logos_class$_ungrouped$FIRDocumentReference,
        @selector(deleteDocumentWithCompletion:),
        (IMP)&_logos_method$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$,
        (IMP *)&_logos_orig$_ungrouped$FIRDocumentReference$deleteDocumentWithCompletion$
    );
    _logos_register_hook(
        _logos_class$_ungrouped$FIRCollectionReference,
        @selector(addDocumentWithData:completion:),
        (IMP)&_logos_method$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$,
        (IMP *)&_logos_orig$_ungrouped$FIRCollectionReference$addDocumentWithData$completion$
    );
}

+ (void)injectIntoAllNSURLThings {
    // The exchange is allowed only once. Only one time
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // In exchange for any class that achieves one of these selectors, you are exchanged to
        const SEL selectors[] = {
            @selector(connectionDidFinishLoading:),
            @selector(connection:willSendRequest:redirectResponse:),
            @selector(connection:didReceiveResponse:),
            @selector(connection:didReceiveData:),
            @selector(connection:didFailWithError:),
            @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:),
            @selector(URLSession:dataTask:didReceiveData:),
            @selector(URLSession:dataTask:didReceiveResponse:completionHandler:),
            @selector(URLSession:task:didCompleteWithError:),
            @selector(URLSession:dataTask:didBecomeDownloadTask:),
            @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:),
            @selector(URLSession:downloadTask:didFinishDownloadingToURL:)
        };

        const int numSelectors = sizeof(selectors) / sizeof(SEL);

        Class *classes = NULL;
        int numClasses = objc_getClassList(NULL, 0);

        if (numClasses > 0) {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
                Class class = classes[classIndex];

                if (class == [AVX512NetworkObserver class]) {
                    continue;
                }

                // Use the use of usageC APInot and instead rather thanNSObjectMethods of methods to avoid ways and means by which information messages can be sent in order
                // This may lead this risk that it could possibly cause us to call on calls for classes of potentially+initialize... . ...-
                // Note: C_Notes — Call callclass_getInstanceMethod()It will send to the class classes that+initialize
                // That's why we go through the list of methods that have been
                unsigned int methodCount = 0;
                Method *methods = class_copyMethodList(class, &methodCount);
                BOOL matchingSelectorFound = NO;
                for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
                    for (int selectorIndex = 0; selectorIndex < numSelectors; ++selectorIndex) {
                        if (method_getName(methods[methodIndex]) == selectors[selectorIndex]) {
                            [self injectIntoDelegateClass:class];
                            matchingSelectorFound = YES;
                            break;
                        }
                    }
                    if (matchingSelectorFound) {
                        break;
                    }
                }
                
                free(methods);
            }
            
            free(classes);
        }

        [self injectIntoNSURLConnectionCancel];
        [self injectIntoNSURLSessionTaskResume];

        [self injectIntoNSURLConnectionAsynchronousClassMethod];
        [self injectIntoNSURLConnectionSynchronousClassMethod];

        Class URLSession = [NSURLSession class];
        [self injectIntoNSURLSessionAsyncDataAndDownloadTaskMethods:URLSession];
        [self injectIntoNSURLSessionAsyncUploadTaskMethods:URLSession];
        
        // At some times at certain sometimes, inNSURLSession.sharedSessionit has been transformed into__NSURLSessionLocal...... .,
        // it's not[NSURLSession class]Return to the category of returned return, categories (of
        Class URLSessionLocal = NSClassFromString(@"__NSURLSessionLocal");
        if (URLSessionLocal && (URLSession != URLSessionLocal)) {
            [self injectIntoNSURLSessionAsyncDataAndDownloadTaskMethods:URLSessionLocal];
            [self injectIntoNSURLSessionAsyncUploadTaskMethods:URLSessionLocal];
        }
        
        if (@available(iOS 13.0, *)) {
            Class websocketTask = NSClassFromString(@"__NSURLSessionWebSocketTask");
            [self injectWebsocketSendMessage:websocketTask];
            [self injectWebsocketReceiveMessage:websocketTask];
            websocketTask = [NSURLSessionWebSocketTask class];
            [self injectWebsocketSendMessage:websocketTask];
            [self injectWebsocketReceiveMessage:websocketTask];
        }
    });
}

+ (void)injectIntoDelegateClass:(Class)cls {
    // Connections
    [self injectWillSendRequestIntoDelegateClass:cls];
    [self injectDidReceiveDataIntoDelegateClass:cls];
    [self injectDidReceiveResponseIntoDelegateClass:cls];
    [self injectDidFinishLoadingIntoDelegateClass:cls];
    [self injectDidFailWithErrorIntoDelegateClass:cls];
    
    // Sessions
    [self injectTaskWillPerformHTTPRedirectionIntoDelegateClass:cls];
    [self injectTaskDidReceiveDataIntoDelegateClass:cls];
    [self injectTaskDidReceiveResponseIntoDelegateClass:cls];
    [self injectTaskDidCompleteWithErrorIntoDelegateClass:cls];
    [self injectRespondsToSelectorIntoDelegateClass:cls];

    // Data tasks
    [self injectDataTaskDidBecomeDownloadTaskIntoDelegateClass:cls];

    // Download tasks
    [self injectDownloadTaskDidWriteDataIntoDelegateClass:cls];
    [self injectDownloadTaskDidFinishDownloadingIntoDelegateClass:cls];
}

+ (void)injectIntoNSURLConnectionCancel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLConnection class];
        SEL selector = @selector(cancel);
        SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
        Method originalCancel = class_getInstanceMethod(class, selector);

        void (^swizzleBlock)(NSURLConnection *) = ^(NSURLConnection *slf) {
            [AVX512NetworkObserver.sharedObserver connectionWillCancel:slf];
            ((void(*)(id, SEL))objc_msgSend)(
                slf, swizzledSelector
            );
        };

        IMP implementation = imp_implementationWithBlock(swizzleBlock);
        class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalCancel));
        Method newCancel = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalCancel, newCancel);
    });
}

+ (void)injectIntoNSURLSessionTaskResume {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // In being in theiOS 7in the middle of, medium midresumeis located in the place__NSCFLocalSessionTaskin which the middle of
        // In being in theiOS 8in the middle of, medium midresumeis located in the placeNSURLSessionTaskin which the middle of
        // In being in theiOS 9in the middle of, medium midresumeis located in the place__NSCFURLSessionTaskin which the middle of
        // In being in theiOS 14in the middle of, medium midresumeis located in the placeNSURLSessionTaskin which the middle of
        Class baseResumeClass = Nil;
        if (![NSProcessInfo.processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
            // iOS ... 7
            baseResumeClass = NSClassFromString(@"__NSCFLocalSessionTask");
        } else {
            NSInteger majorVersion = NSProcessInfo.processInfo.operatingSystemVersion.majorVersion;
            if (majorVersion < 9 || majorVersion >= 14) {
                // iOS 8 or/or is, iOS 14+
                baseResumeClass = [NSURLSessionTask class];
            } else {
                // iOS 9 ... 13
                baseResumeClass = NSClassFromString(@"__NSCFURLSessionTask");
            }
        }
        
        // The hook-per hold, the-resumebasic realization of the essential and fundamental
        IMP originalResume = [baseResumeClass instanceMethodForSelector:@selector(resume)];
        [self swizzleResumeSelector:@selector(resume) forClass:baseResumeClass];
        
        // *sighs and sighing an*
        //
        // So so, SOSoAFNetworking 2.5.Xmultiple versions of more than one version are exchanged in a variety and short-sighted exchange-resume... . ...-
        // If if you view your2.5.0historical records of the history, and in more or earlier versions
        // You will see that various technologies have been tried and tested, including the useNSURLSessionTaskPrivate, private and privately-private
        // Sub class and use sub classes below, using the subsections`originalResume`calling call to Call Calls for callsclass_addMethod...... .,
        // This would then exist in the category so that there existed-resumeDu duplication and repetition is achieved.
        //
        // This technology is particularly problematic because it poses particular problems,`baseResumeClass`The realization of what has been achieved is never called at all, and
        // That means that our exchange has never been called.
        //
        // The only solution is one that can be a tough and powerful resolution: we have to cycli cycle through the
        // less than under (under`baseResumeClass`, and check all the realized realizations are checked`af_resume`The kind of a class.
        // If the counterpart to that method approach would be corresponding ifIMPequals or equivalent to`originalResume`So, then we're ours
        // Except except for the exchange`baseResumeClass`Up up, top above`resume`Outside, it is exchanged for exchange. It's also
        //
        // However, we are only in the caseNSSelectorFromString
        // To be able to find, first and`"af_resume"`Select the selecter to choose a selection. Only care is taken when
        SEL sel_af_resume = NSSelectorFromString(@"af_resume");
        if (sel_af_resume) {
            NSMutableArray<Class> *classTree = AVX512GetAllSubclasses(baseResumeClass, NO).mutableCopy;
            for (NSInteger i = 0; i < classTree.count; i++) {
                [classTree addObjectsFromArray:AVX512GetAllSubclasses(classTree[i], NO)];
            }
            
            for (Class current in classTree) {
                IMP af_resume = [current instanceMethodForSelector:sel_af_resume];
                if (af_resume == originalResume) {
                    [self swizzleResumeSelector:sel_af_resume forClass:current];
                }
            }
        }
    });
}

+ (void)swizzleResumeSelector:(SEL)selector forClass:(Class)class {
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    Method originalResume = class_getInstanceMethod(class, selector);
    IMP implementation = imp_implementationWithBlock(^(NSURLSessionTask *slf) {
        
        if (@available(iOS 11.0, *)) {
            // AVAggregateAssetDownloadTaskYou really don't like to be seen and very-currentRequestor/or is,
            // -originalRequestIt's going to crash and collapse. And it will break downhttps://github.com/AVX512Tool/FLEX/issues/276
            if (![slf isKindOfClass:[AVAggregateAssetDownloadTask class]]) {
                // iOSInternal internal inside the interiorHTTPSol parser completion code codes are not mysteriously and secretally, that the thread is safe from
                // It is likely that the use of it by a fort-s`double free`BC crashes. Coll collapse
                // The line below will synchronize the request requests to syncsHTTPBodyAnd the angel, and make ofHTTPParser
                // Pars the request for a resolution of requests and pre-rec cache them in advance.HTTPParser
                // This will be completed. Ensure that other requests are checked to ensure additional line-by
                // It will not trigger competition to complete the parser.
                [slf.currentRequest HTTPBody];

                [AVX512NetworkObserver.sharedObserver URLSessionTaskWillResume:slf];
            }
        }

        ((void(*)(id, SEL))objc_msgSend)(
            slf, swizzledSelector
        );
    });
    
    class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalResume));
    Method newResume = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalResume, newResume);
}

+ (void)injectIntoNSURLConnectionAsynchronousClassMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
        SEL selector = @selector(sendAsynchronousRequest:queue:completionHandler:);
        SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

        typedef void (^AsyncCompletion)(
            NSURLResponse *response, NSData *data, NSError *error
        );
        typedef void (^SendAsyncRequestBlock)(
            Class, NSURLRequest *, NSOperationQueue *, AsyncCompletion
        );
        SendAsyncRequestBlock swizzleBlock = ^(Class slf,
                                               NSURLRequest *request,
                                               NSOperationQueue *queue,
                                               AsyncCompletion completion) {
            if (AVX512NetworkObserver.isEnabled) {
                NSString *requestID = [self nextRequestID];
                [AVX512NetworkRecorder.defaultRecorder
                     recordRequestWillBeSentWithRequestID:requestID
                     request:request
                     redirectResponse:nil
                ];
                
                NSString *mechanism = [self mechanismFromClassMethod:selector onClass:class];
                [AVX512NetworkRecorder.defaultRecorder recordMechanism:mechanism forRequestID:requestID];
                
                AsyncCompletion wrapper = ^(NSURLResponse *response, NSData *data, NSError *error) {
                    [AVX512NetworkRecorder.defaultRecorder
                        recordResponseReceivedWithRequestID:requestID
                        response:response
                    ];
                    [AVX512NetworkRecorder.defaultRecorder
                         recordDataReceivedWithRequestID:requestID
                         dataLength:data.length
                    ];
                    if (error) {
                        [AVX512NetworkRecorder.defaultRecorder
                            recordLoadingFailedWithRequestID:requestID
                            error:error
                        ];
                    } else {
                        [AVX512NetworkRecorder.defaultRecorder
                            recordLoadingFinishedWithRequestID:requestID
                            responseBody:data
                        ];
                    }

                    // Call to call Original finish processing process handler for original completion
                    if (completion) {
                        completion(response, data, error);
                    }
                };
                ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                    slf, swizzledSelector, request, queue, wrapper
                );
            } else {
                ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                    slf, swizzledSelector, request, queue, completion
                );
            }
        };
        
        [AVX512Utility replaceImplementationOfKnownSelector:selector
            onClass:class withBlock:swizzleBlock swizzledSelector:swizzledSelector
        ];
    });
}

+ (void)injectIntoNSURLConnectionSynchronousClassMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
        SEL selector = @selector(sendSynchronousRequest:returningResponse:error:);
        SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

        typedef NSData * (^AsyncCompletion)(Class, NSURLRequest *, NSURLResponse **, NSError **);
        AsyncCompletion swizzleBlock = ^NSData *(Class slf,
                                                 NSURLRequest *request,
                                                 NSURLResponse **response,
                                                 NSError **error) {
            NSData *data = nil;
            if (AVX512NetworkObserver.isEnabled) {
                NSString *requestID = [self nextRequestID];
                [AVX512NetworkRecorder.defaultRecorder
                    recordRequestWillBeSentWithRequestID:requestID
                    request:request
                    redirectResponse:nil
                ];
                
                NSString *mechanism = [self mechanismFromClassMethod:selector onClass:class];
                [AVX512NetworkRecorder.defaultRecorder recordMechanism:mechanism forRequestID:requestID];
                NSError *temporaryError = nil;
                NSURLResponse *temporaryResponse = nil;
                data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(
                    slf, swizzledSelector, request, &temporaryResponse, &temporaryError
                );
                
                [AVX512NetworkRecorder.defaultRecorder
                    recordResponseReceivedWithRequestID:requestID
                    response:temporaryResponse
                ];
                [AVX512NetworkRecorder.defaultRecorder
                    recordDataReceivedWithRequestID:requestID
                    dataLength:data.length
                ];
                
                if (temporaryError) {
                    [AVX512NetworkRecorder.defaultRecorder
                        recordLoadingFailedWithRequestID:requestID
                        error:temporaryError
                    ];
                } else {
                    [AVX512NetworkRecorder.defaultRecorder
                        recordLoadingFinishedWithRequestID:requestID
                        responseBody:data
                    ];
                }
                
                if (error) {
                    *error = temporaryError;
                }
                if (response) {
                    *response = temporaryResponse;
                }
            } else {
                data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(
                    slf, swizzledSelector, request, response, error
                );
            }

            return data;
        };
        
        [AVX512Utility replaceImplementationOfKnownSelector:selector
            onClass:class withBlock:swizzleBlock swizzledSelector:swizzledSelector
        ];
    });
}

+ (void)injectIntoNSURLSessionAsyncDataAndDownloadTaskMethods:(Class)sessionClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = sessionClass;
        
        // The method of signature is very close here, and we can use the same logic to inject it into all methods using a similar logical
        const SEL selectors[] = {
            @selector(dataTaskWithRequest:completionHandler:),
            @selector(dataTaskWithURL:completionHandler:),
            @selector(downloadTaskWithRequest:completionHandler:),
            @selector(downloadTaskWithResumeData:completionHandler:),
            @selector(downloadTaskWithURL:completionHandler:)
        };

        const int numSelectors = sizeof(selectors) / sizeof(SEL);

        for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
            SEL selector = selectors[selectorIndex];
            SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

            if ([AVX512Utility instanceRespondsButDoesNotImplementSelector:selector class:class]) {
                // iOS 7In being in theNSURLSessionThese methods have not been realized. We really want to actually think about what we'
                // Exchange exchange of exchanges for__NSCFURLSession, that we can retrieve from the class of shared session share sessions by fetching them
                class = [NSURLSession.sharedSession class];
            }
            
            typedef NSURLSessionTask * (^NSURLSessionNewTaskMethod)(
                NSURLSession *, id, NSURLSessionAsyncCompletion
            );
            NSURLSessionNewTaskMethod swizzleBlock = ^NSURLSessionTask *(NSURLSession *slf,
                                                                         id argument,
                                                                         NSURLSessionAsyncCompletion completion) {
                NSURLSessionTask *task = nil;
                // Check the network to see if it is turned on and whether a callback check was provided
                if (AVX512NetworkObserver.isEnabled && completion) {
                    NSString *requestID = [self nextRequestID];
                    NSString *mechanism = [self mechanismFromClassMethod:selector onClass:class];
                    // "The hook-per hold, the"Completed block complete Block blocks to finish
                    NSURLSessionAsyncCompletion completionWrapper = [self
                        asyncCompletionWrapperForRequestID:requestID
                        mechanism:mechanism
                        completion:completion
                    ];
                    
                    // Call original method to call the source-based methods
                    task = ((id(*)(id, SEL, id, id))objc_msgSend)(
                        slf, swizzledSelector, argument, completionWrapper
                    );
                    [self setRequestID:requestID forConnectionOrTask:task];
                } else {
                    // Network observation network observations are disabled or unreactivated, no echobacks provided. Web
                    // Direct transmission directly to the original method of primary methods,
                    task = ((id(*)(id, SEL, id, id))objc_msgSend)(
                        slf, swizzledSelector, argument, completion
                    );
                }
                return task;
            };
            
            // Actual exchange of actual real-exchange
            [AVX512Utility replaceImplementationOfKnownSelector:selector
                onClass:class withBlock:swizzleBlock swizzledSelector:swizzledSelector
            ];
        }
    });
}

+ (void)injectIntoNSURLSessionAsyncUploadTaskMethods:(Class)sessionClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = sessionClass;
        
        // The method of signature is very close here, and we can use the same logic to inject it into all methods using a similar logical
        // Note that there are some of them,3a parameter, so we can't easily merge with the data above and downloading methods.
        typedef NSURLSessionUploadTask *(^UploadTaskMethod)(
            NSURLSession *, NSURLRequest *, id, NSURLSessionAsyncCompletion
        );
        const SEL selectors[] = {
            @selector(uploadTaskWithRequest:fromData:completionHandler:),
            @selector(uploadTaskWithRequest:fromFile:completionHandler:)
        };

        const int numSelectors = sizeof(selectors) / sizeof(SEL);

        for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
            SEL selector = selectors[selectorIndex];
            SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

            if ([AVX512Utility instanceRespondsButDoesNotImplementSelector:selector class:class]) {
                // iOS 7In being in theNSURLSessionThese methods have not been realized. We really want to actually think about what we'
                // Exchange exchange of exchanges for__NSCFURLSession, that we can retrieve from the class of shared session share sessions by fetching them
                class = [NSURLSession.sharedSession class];
            }

            
            UploadTaskMethod swizzleBlock = ^NSURLSessionUploadTask *(NSURLSession * slf,
                                                                      NSURLRequest *request,
                                                                      id argument,
                                                                      NSURLSessionAsyncCompletion completion) {
                NSURLSessionUploadTask *task = nil;
                if (AVX512NetworkObserver.isEnabled && completion) {
                    NSString *requestID = [self nextRequestID];
                    NSString *mechanism = [self mechanismFromClassMethod:selector onClass:class];
                    NSURLSessionAsyncCompletion completionWrapper = [self
                        asyncCompletionWrapperForRequestID:requestID
                        mechanism:mechanism
                        completion:completion
                    ];
                    
                    task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(
                        slf, swizzledSelector, request, argument, completionWrapper
                    );
                    [self setRequestID:requestID forConnectionOrTask:task];
                } else {
                    task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(
                        slf, swizzledSelector, request, argument, completion
                    );
                }
                return task;
            };
            
            [AVX512Utility replaceImplementationOfKnownSelector:selector
                onClass:class withBlock:swizzleBlock swizzledSelector:swizzledSelector
            ];
        }
    });
}

+ (NSString *)mechanismFromClassMethod:(SEL)selector onClass:(Class)class {
    return [NSString stringWithFormat:@"+[%@ %@]", NSStringFromClass(class), NSStringFromSelector(selector)];
}

+ (NSURLSessionAsyncCompletion)asyncCompletionWrapperForRequestID:(NSString *)requestID
                                                        mechanism:(NSString *)mechanism
                                                       completion:(NSURLSessionAsyncCompletion)completion {
    NSURLSessionAsyncCompletion completionWrapper = ^(id fileURLOrData, NSURLResponse *response, NSError *error) {
        [AVX512NetworkRecorder.defaultRecorder recordMechanism:mechanism forRequestID:requestID];
        [AVX512NetworkRecorder.defaultRecorder
            recordResponseReceivedWithRequestID:requestID
            response:response
        ];
        
        NSData *data = nil;
        if ([fileURLOrData isKindOfClass:[NSURL class]]) {
            data = [NSData dataWithContentsOfURL:fileURLOrData];
        } else if ([fileURLOrData isKindOfClass:[NSData class]]) {
            data = fileURLOrData;
        }
        
        [AVX512NetworkRecorder.defaultRecorder
            recordDataReceivedWithRequestID:requestID
            dataLength:data.length
        ];
        
        if (error) {
            [AVX512NetworkRecorder.defaultRecorder
                recordLoadingFailedWithRequestID:requestID
                error:error
            ];
        } else {
            [AVX512NetworkRecorder.defaultRecorder
                 recordLoadingFinishedWithRequestID:requestID
                 responseBody:data
            ];
        }

        // Call to call Original finish processing process handler for original completion
        if (completion) {
            completion(fileURLOrData, response, error);
        }
    };
    return completionWrapper;
}

+ (void)injectWillSendRequestIntoDelegateClass:(Class)cls {
    SEL selector = @selector(connection:willSendRequest:redirectResponse:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    protocol = protocol ?: @protocol(NSURLConnectionDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(
        protocol, selector, NO, YES
    );
    
    typedef NSURLRequest *(^WillSendRequestBlock)(
        id<NSURLConnectionDelegate> slf, NSURLConnection *connection,
        NSURLRequest *request, NSURLResponse *response
    );
    
    WillSendRequestBlock undefinedBlock = ^NSURLRequest *(id slf,
                                                          NSURLConnection *connection,
                                                          NSURLRequest *request,
                                                          NSURLResponse *response) {
        [AVX512NetworkObserver.sharedObserver
            connection:connection
            willSendRequest:request
            redirectResponse:response
            delegate:slf
        ];
        return request;
    };
    
    WillSendRequestBlock implementationBlock = ^NSURLRequest *(id slf,
                                                               NSURLConnection *connection,
                                                               NSURLRequest *request,
                                                               NSURLResponse *response) {
        __block NSURLRequest *returnValue = nil;
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, request, response);
        } originalImplementationBlock:^{
            returnValue = ((id(*)(id, SEL, id, id, id))objc_msgSend)(
                slf, swizzledSelector, connection, request, response
            );
        }];
        return returnValue;
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:methodDescription
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDidReceiveResponseIntoDelegateClass:(Class)cls {
    SEL selector = @selector(connection:didReceiveResponse:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    protocol = protocol ?: @protocol(NSURLConnectionDelegate);
    struct objc_method_description description = protocol_getMethodDescription(
        protocol, selector, NO, YES
    );
    
    typedef void (^DidReceiveResponseBlock)(
        id<NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response
    );
    
    DidReceiveResponseBlock undefinedBlock = ^(id<NSURLConnectionDelegate> slf,
                                               NSURLConnection *connection,
                                               NSURLResponse *response) {
        [AVX512NetworkObserver.sharedObserver connection:connection
            didReceiveResponse:response delegate:slf
        ];
    };
    
    DidReceiveResponseBlock implementationBlock = ^(id<NSURLConnectionDelegate> slf,
                                                    NSURLConnection *connection,
                                                    NSURLResponse *response) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, response);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(
                slf, swizzledSelector, connection, response
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDidReceiveDataIntoDelegateClass:(Class)cls {
    SEL selector = @selector(connection:didReceiveData:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    protocol = protocol ?: @protocol(NSURLConnectionDelegate);
    struct objc_method_description description = protocol_getMethodDescription(
        protocol, selector, NO, YES
    );
    
    typedef void (^DidReceiveDataBlock)(
        id<NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data
    );
    
    DidReceiveDataBlock undefinedBlock = ^(id<NSURLConnectionDelegate> slf,
                                           NSURLConnection *connection,
                                           NSData *data) {
        [AVX512NetworkObserver.sharedObserver connection:connection 
            didReceiveData:data delegate:slf
        ];
    };
    
    DidReceiveDataBlock implementationBlock = ^(id<NSURLConnectionDelegate> slf,
                                                NSURLConnection *connection,
                                                NSData *data) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, data);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(
                slf, swizzledSelector, connection, data
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDidFinishLoadingIntoDelegateClass:(Class)cls {
    SEL selector = @selector(connectionDidFinishLoading:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    protocol = protocol ?: @protocol(NSURLConnectionDelegate);
    struct objc_method_description description = protocol_getMethodDescription(
        protocol, selector, NO, YES
    );
    
    typedef void (^FinishLoadingBlock)(id<NSURLConnectionDelegate> slf, NSURLConnection *connection);
    
    FinishLoadingBlock undefinedBlock = ^(id<NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [AVX512NetworkObserver.sharedObserver connectionDidFinishLoading:connection delegate:slf];
    };
    
    FinishLoadingBlock implementationBlock = ^(id<NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id))objc_msgSend)(
                slf, swizzledSelector, connection
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDidFailWithErrorIntoDelegateClass:(Class)cls {
    SEL selector = @selector(connection:didFailWithError:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLConnectionDelegate), selector, NO, YES
    );
    
    typedef void (^DidFailWithErrorBlock)(
        id<NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error
    );
    
    DidFailWithErrorBlock undefinedBlock = ^(id<NSURLConnectionDelegate> slf,
                                             NSURLConnection *connection,
                                             NSError *error) {
        [AVX512NetworkObserver.sharedObserver connection:connection
            didFailWithError:error delegate:slf
        ];
    };
    
    DidFailWithErrorBlock implementationBlock = ^(id<NSURLConnectionDelegate> slf,
                                                  NSURLConnection *connection,
                                                  NSError *error) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, error);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(
                slf, swizzledSelector, connection, error
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectTaskWillPerformHTTPRedirectionIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionTaskDelegate), selector, NO, YES
    );
    
    typedef void (^HTTPRedirectionBlock)(id<NSURLSessionTaskDelegate> slf,
                                         NSURLSession *session,
                                         NSURLSessionTask *task,
                                         NSHTTPURLResponse *response,
                                         NSURLRequest *newRequest,
                                         void(^completionHandler)(NSURLRequest *));
    
    HTTPRedirectionBlock undefinedBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                            NSURLSession *session,
                                            NSURLSessionTask *task,
                                            NSHTTPURLResponse *response,
                                            NSURLRequest *newRequest,
                                            void(^completionHandler)(NSURLRequest *)) {
        [AVX512NetworkObserver.sharedObserver
            URLSession:session task:task
            willPerformHTTPRedirection:response
            newRequest:newRequest
            completionHandler:completionHandler
            delegate:slf
        ];
        completionHandler(newRequest);
    };

    HTTPRedirectionBlock implementationBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                                 NSURLSession *session,
                                                 NSURLSessionTask *task,
                                                 NSHTTPURLResponse *response,
                                                 NSURLRequest *newRequest,
                                                 void(^completionHandler)(NSURLRequest *)) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            [AVX512NetworkObserver.sharedObserver
                URLSession:session task:task
                willPerformHTTPRedirection:response
                newRequest:newRequest
                completionHandler:completionHandler
                delegate:slf
            ];
        } originalImplementationBlock:^{
            ((id(*)(id, SEL, id, id, id, id, void(^)(NSURLRequest *)))objc_msgSend)(
                slf, swizzledSelector, session, task, response, newRequest, completionHandler
            );
        }];
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectTaskDidReceiveDataIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didReceiveData:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDataDelegate), selector, NO, YES
    );
    
    typedef void (^DidReceiveDataBlock)(id<NSURLSessionDataDelegate> slf,
                                        NSURLSession *session,
                                        NSURLSessionDataTask *dataTask,
                                        NSData *data);
    DidReceiveDataBlock undefinedBlock = ^(id<NSURLSessionDataDelegate> slf,
                                           NSURLSession *session,
                                           NSURLSessionDataTask *dataTask,
                                           NSData *data) {
        [AVX512NetworkObserver.sharedObserver URLSession:session
            dataTask:dataTask didReceiveData:data delegate:slf
        ];
    };
    
    DidReceiveDataBlock implementationBlock = ^(id<NSURLSessionDataDelegate> slf,
                                                NSURLSession *session,
                                                NSURLSessionDataTask *dataTask,
                                                NSData *data) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, dataTask, data);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                slf, swizzledSelector, session, dataTask, data
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDataTaskDidBecomeDownloadTaskIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didBecomeDownloadTask:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDataDelegate), selector, NO, YES
    );

    typedef void (^DidBecomeDownloadTaskBlock)(id<NSURLSessionDataDelegate> slf,
                                               NSURLSession *session,
                                               NSURLSessionDataTask *dataTask,
                                               NSURLSessionDownloadTask *downloadTask);

    DidBecomeDownloadTaskBlock undefinedBlock = ^(id<NSURLSessionDataDelegate> slf,
                                                  NSURLSession *session,
                                                  NSURLSessionDataTask *dataTask,
                                                  NSURLSessionDownloadTask *downloadTask) {
        [AVX512NetworkObserver.sharedObserver URLSession:session
            dataTask:dataTask didBecomeDownloadTask:downloadTask delegate:slf
        ];
    };

    DidBecomeDownloadTaskBlock implementationBlock = ^(id<NSURLSessionDataDelegate> slf,
                                                       NSURLSession *session,
                                                       NSURLSessionDataTask *dataTask,
                                                       NSURLSessionDownloadTask *downloadTask) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, dataTask, downloadTask);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                slf, swizzledSelector, session, dataTask, downloadTask
            );
        }];
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectTaskDidReceiveResponseIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didReceiveResponse:completionHandler:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDataDelegate), selector, NO, YES
    );
    
    typedef void (^DidReceiveResponseBlock)(id<NSURLSessionDelegate> slf,
                                            NSURLSession *session,
                                            NSURLSessionDataTask *dataTask,
                                            NSURLResponse *response,
                                            void(^completion)(NSURLSessionResponseDisposition));
    
    DidReceiveResponseBlock undefinedBlock = ^(id<NSURLSessionDelegate> slf,
                                               NSURLSession *session,
                                               NSURLSessionDataTask *dataTask,
                                               NSURLResponse *response,
                                               void(^completion)(NSURLSessionResponseDisposition)) {
        [AVX512NetworkObserver.sharedObserver
            URLSession:session
            dataTask:dataTask
            didReceiveResponse:response
            completionHandler:completion
            delegate:slf
        ];
        completion(NSURLSessionResponseAllow);
    };
    
    DidReceiveResponseBlock implementationBlock = ^(id<NSURLSessionDelegate> slf,
                                                    NSURLSession *session,
                                                    NSURLSessionDataTask *dataTask,
                                                    NSURLResponse *response,
                                                    void(^completion)(NSURLSessionResponseDisposition )) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            [AVX512NetworkObserver.sharedObserver
                URLSession:session
                dataTask:dataTask
                didReceiveResponse:response
                completionHandler:completion
                delegate:slf
            ];
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id, void(^)(NSURLSessionResponseDisposition)))objc_msgSend)(
                slf, swizzledSelector, session, dataTask, response, completion
            );
        }];
    };
    
    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];

}

+ (void)injectTaskDidCompleteWithErrorIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:task:didCompleteWithError:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];
    
    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDataDelegate), selector, NO, YES
    );
    
    typedef void (^DidCompleteWithErrorBlock)(id<NSURLSessionTaskDelegate> slf,
                                              NSURLSession *session,
                                              NSURLSessionTask *task,
                                              NSError *error);

    DidCompleteWithErrorBlock undefinedBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                                 NSURLSession *session,
                                                 NSURLSessionTask *task,
                                                 NSError *error) {
        [AVX512NetworkObserver.sharedObserver URLSession:session
            task:task didCompleteWithError:error delegate:slf
        ];
    };
    
    DidCompleteWithErrorBlock implementationBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                                      NSURLSession *session,
                                                      NSURLSessionTask *task,
                                                      NSError *error) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, error);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                slf, swizzledSelector, session, task, error
            );
        }];
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

// Use for rewrek to useAFNetworkingact of conduct or behaviour
+ (void)injectRespondsToSelectorIntoDelegateClass:(Class)cls {
    SEL selector = @selector(respondsToSelector:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    //Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    Method method = class_getInstanceMethod(cls, selector);
    struct objc_method_description methodDescription = *method_getDescription(method);

    typedef BOOL (^RespondsToSelectorImpl)(id self, SEL sel);
    RespondsToSelectorImpl undefinedBlock = ^(id slf, SEL sel) {
        return YES;
    };

    RespondsToSelectorImpl implementationBlock = ^(id<NSURLSessionTaskDelegate> slf, SEL sel) {
        if (sel == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
            return undefinedBlock(slf, sel);
        }
        return ((BOOL(*)(id, SEL, SEL))objc_msgSend)(slf, swizzledSelector, sel);
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:methodDescription
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDownloadTaskDidFinishDownloadingIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:downloadTask:didFinishDownloadingToURL:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDownloadDelegate), selector, NO, YES
    );

    typedef void (^DidFinishDownloadingBlock)(id<NSURLSessionTaskDelegate> slf,
                                              NSURLSession *session,
                                              NSURLSessionDownloadTask *task,
                                              NSURL *location);

    DidFinishDownloadingBlock undefinedBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                                 NSURLSession *session,
                                                 NSURLSessionDownloadTask *task,
                                                 NSURL *location) {
        NSData *data = [NSData dataWithContentsOfFile:location.relativePath];
        [AVX512NetworkObserver.sharedObserver URLSession:session
            task:task didFinishDownloadingToURL:location data:data delegate:slf
        ];
    };

    DidFinishDownloadingBlock implementationBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                                      NSURLSession *session,
                                                      NSURLSessionDownloadTask *task,
                                                      NSURL *location) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, location);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(
                slf, swizzledSelector, session, task, location
            );
        }];
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectDownloadTaskDidWriteDataIntoDelegateClass:(Class)cls {
    SEL selector = @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    struct objc_method_description description = protocol_getMethodDescription(
        @protocol(NSURLSessionDownloadDelegate), selector, NO, YES
    );

    typedef void (^DidWriteDataBlock)(id<NSURLSessionTaskDelegate> slf,
                                      NSURLSession *session,
                                      NSURLSessionDownloadTask *task,
                                      int64_t bytesWritten,
                                      int64_t totalBytesWritten,
                                      int64_t totalBytesExpectedToWrite);

    DidWriteDataBlock undefinedBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                         NSURLSession *session,
                                         NSURLSessionDownloadTask *task,
                                         int64_t bytesWritten,
                                         int64_t totalBytesWritten,
                                         int64_t totalBytesExpectedToWrite) {
        [AVX512NetworkObserver.sharedObserver URLSession:session
            downloadTask:task didWriteData:bytesWritten
            totalBytesWritten:totalBytesWritten
            totalBytesExpectedToWrite:totalBytesExpectedToWrite
            delegate:slf
        ];
    };

    DidWriteDataBlock implementationBlock = ^(id<NSURLSessionTaskDelegate> slf,
                                              NSURLSession *session,
                                              NSURLSessionDownloadTask *task,
                                              int64_t bytesWritten,
                                              int64_t totalBytesWritten,
                                              int64_t totalBytesExpectedToWrite) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(
                slf, session, task, bytesWritten,
                totalBytesWritten, totalBytesExpectedToWrite
            );
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, int64_t, int64_t, int64_t))objc_msgSend)(
                slf, swizzledSelector, session, task, bytesWritten,
                totalBytesWritten, totalBytesExpectedToWrite
            );
        }];
    };

    [AVX512Utility replaceImplementationOfSelector:selector
        withSelector:swizzledSelector
        forClass:cls
        withMethodDescription:description
        implementationBlock:implementationBlock
        undefinedBlock:undefinedBlock
    ];
}

+ (void)injectWebsocketSendMessage:(Class)cls API_AVAILABLE(ios(13.0)) {
    SEL selector = @selector(sendMessage:completionHandler:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    typedef void (^SendMessageBlock)(
        NSURLSessionWebSocketTask *slf,
        NSURLSessionWebSocketMessage *message,
        void (^completion)(NSError *error)
    );

    SendMessageBlock implementationBlock = ^(
        NSURLSessionWebSocketTask *slf,
        NSURLSessionWebSocketMessage *message,
        void (^completion)(NSError *error)
    ) {
        [AVX512NetworkObserver.sharedObserver
            websocketTask:slf sendMessagage:message
        ];
        
        id completionHook = ^(NSError *error) {
            [AVX512NetworkObserver.sharedObserver
                websocketTaskMessageSendCompletion:message
                error:error
            ];
            if (completion) {
                completion(error);
            }
        };
        
        ((void(*)(id, SEL, id, id))objc_msgSend)(
            slf, swizzledSelector, message, completionHook
        );
    };

    [AVX512Utility replaceImplementationOfKnownSelector:selector
        onClass:cls
        withBlock:implementationBlock
        swizzledSelector:swizzledSelector
    ];
}

+ (void)injectWebsocketReceiveMessage:(Class)cls API_AVAILABLE(ios(13.0)) {
    SEL selector = @selector(receiveMessageWithCompletionHandler:);
    SEL swizzledSelector = [AVX512Utility swizzledSelectorForSelector:selector];

    typedef void (^SendMessageBlock)(
        NSURLSessionWebSocketTask *slf,
        void (^completion)(NSURLSessionWebSocketMessage *message, NSError *error)
    );

    SendMessageBlock implementationBlock = ^(
        NSURLSessionWebSocketTask *slf,
        void (^completion)(NSURLSessionWebSocketMessage *message, NSError *error)
    ) {        
        id completionHook = ^(NSURLSessionWebSocketMessage *message, NSError *error) {
            [AVX512NetworkObserver.sharedObserver
                websocketTask:slf receiveMessagage:message error:error
            ];
            completion(message, error);
        };
        
        ((void(*)(id, SEL, id))objc_msgSend)(
            slf, swizzledSelector, completionHook
        );

    };

    [AVX512Utility replaceImplementationOfKnownSelector:selector
        onClass:cls
        withBlock:implementationBlock
        swizzledSelector:swizzledSelector
    ];
}

static char const * const kAVX512RequestIDKey = "kAVX512RequestIDKey";

+ (NSString *)requestIDForConnectionOrTask:(id)connectionOrTask {
    NSString *requestID = objc_getAssociatedObject(connectionOrTask, kAVX512RequestIDKey);
    if (!requestID) {
        requestID = [self nextRequestID];
        [self setRequestID:requestID forConnectionOrTask:connectionOrTask];
    }
    return requestID;
}

+ (void)setRequestID:(NSString *)requestID forConnectionOrTask:(id)connectionOrTask {
    objc_setAssociatedObject(
        connectionOrTask, kAVX512RequestIDKey, requestID, OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

#pragma mark - Initial initialisation to start-in

- (id)init {
    self = [super init];
    if (self) {
        self.requestStatesForRequestIDs = [NSMutableDictionary new];
        self.queue = dispatch_queue_create(
            "com.flex.AVX512NetworkObserver", DISPATCH_QUEUE_SERIAL
        );
    }
    
    return self;
}

#pragma mark - Private private methods and privately-private

- (void)performBlock:(dispatch_block_t)block {
    if ([[self class] isEnabled]) {
        dispatch_async(_queue, block);
    }
}

- (AVX512InternalRequestState *)requestStateForRequestID:(NSString *)requestID {
    AVX512InternalRequestState *requestState = self.requestStatesForRequestIDs[requestID];
    if (!requestState) {
        requestState = [AVX512InternalRequestState new];
        [self.requestStatesForRequestIDs setObject:requestState forKey:requestID];
    }
    
    return requestState;
}

- (void)removeRequestStateForRequestID:(NSString *)requestID {
    [self.requestStatesForRequestIDs removeObjectForKey:requestID];
}

@end


@implementation AVX512NetworkObserver (NSURLConnectionHelpers)

- (void)connection:(NSURLConnection *)connection
   willSendRequest:(NSURLRequest *)request
  redirectResponse:(NSURLResponse *)response
          delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        requestState.request = request;
        
        [AVX512NetworkRecorder.defaultRecorder
            recordRequestWillBeSentWithRequestID:requestID
            request:request
            redirectResponse:response
        ];
        
        NSString *mechanism = [NSString stringWithFormat:
            @"NSURLConnection (delegate: %@)", [delegate class]
        ];
        [AVX512NetworkRecorder.defaultRecorder recordMechanism:mechanism forRequestID:requestID];
    }];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
          delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        requestState.dataAccumulator = [NSMutableData new];

        [AVX512NetworkRecorder.defaultRecorder
            recordResponseReceivedWithRequestID:requestID
            response:response
        ];
    }];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
          delegate:(id<NSURLConnectionDelegate>)delegate {
    // Just for the sake of safety and security, because we're doing this as a step-
    data = [data copy];
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [requestState.dataAccumulator appendData:data];
        
        [AVX512NetworkRecorder.defaultRecorder
            recordDataReceivedWithRequestID:requestID
            dataLength:data.length
        ];
    }];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
                          delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [AVX512NetworkRecorder.defaultRecorder
            recordLoadingFinishedWithRequestID:requestID
            responseBody:requestState.dataAccumulator
        ];
        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
          delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];

        // The cancellation could have occurred the possibility thatwillSendRequest:...
        // NSURLConnectionBefore proxy agent calls before the agency is called. These are very common and
        // And it can confuse the logs into confusion, and may cause a
        // The recorder has passed through the logs andwillSendRequest:...If you understand the request, it is only a failure to record failed
        if (requestState.request) {
            [AVX512NetworkRecorder.defaultRecorder 
                recordLoadingFailedWithRequestID:requestID error:error
            ];
        }
        
        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)connectionWillCancel:(NSURLConnection *)connection {
    [self performBlock:^{
        // Em simulates the simulationNSURLSessionact, that is to create an error creating a bug when canceling.
        NSDictionary<NSString *, id> *userInfo = @{ NSLocalizedDescriptionKey : @"Cancelled" };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
            code:NSURLErrorCancelled userInfo:userInfo
        ];
        [self connection:connection didFailWithError:error delegate:nil];
    }];
}

@end


@implementation AVX512NetworkObserver (NSURLSessionTaskHelpers)

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
          delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        [AVX512NetworkRecorder.defaultRecorder
            recordRequestWillBeSentWithRequestID:requestID
            request:request
            redirectResponse:response
        ];
    }];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
          delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        requestState.dataAccumulator = [NSMutableData new];

        NSString *requestMechanism = [NSString stringWithFormat:
            @"NSURLSessionDataTask (delegate: %@)", [delegate class]
        ];
        [AVX512NetworkRecorder.defaultRecorder
            recordMechanism:requestMechanism
            forRequestID:requestID
        ];

        [AVX512NetworkRecorder.defaultRecorder
            recordResponseReceivedWithRequestID:requestID
            response:response
        ];
    }];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
          delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        // The request that downloads the task message through aIDSet settings as set setting to match matching data tasks with the database task
        // It can continue from where the data mission stops when it has stopped.
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        [[self class] setRequestID:requestID forConnectionOrTask:downloadTask];
    }];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
          delegate:(id<NSURLSessionDelegate>)delegate {
    // Just for the sake of safety and security, because we're doing this as a step-
    data = [data copy];
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];

        // Rehabilitation Developer report reports on the rehabilitation development develop"The responder is not in the cache-gres"Q question issue on
        // For a detailed explanation of the reasons why this has happened, please refer to here forgithubComment comment comments remarks Comments
        // https://github.com/AVX512Tool/FLEX/issues/568#issuecomment-1141015572
        if (requestState.dataAccumulator == nil) {
            requestState.dataAccumulator = [NSMutableData new];
        }
        [requestState.dataAccumulator appendData:data];

        [AVX512NetworkRecorder.defaultRecorder
            recordDataReceivedWithRequestID:requestID
            dataLength:data.length
        ];
    }];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
          delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];

        if (error) {
            [AVX512NetworkRecorder.defaultRecorder
                recordLoadingFailedWithRequestID:requestID error:error
            ];
        } else {
            [AVX512NetworkRecorder.defaultRecorder
                recordLoadingFinishedWithRequestID:requestID 
                responseBody:requestState.dataAccumulator
            ];
        }

        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
          delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:downloadTask];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];

        if (!requestState.dataAccumulator) {
            requestState.dataAccumulator = [NSMutableData new];
            [AVX512NetworkRecorder.defaultRecorder
                recordResponseReceivedWithRequestID:requestID
                response:downloadTask.response
            ];

            NSString *requestMechanism = [NSString stringWithFormat:
                @"NSURLSessionDownloadTask (delegate: %@)", [delegate class]
            ];
            [AVX512NetworkRecorder.defaultRecorder
                recordMechanism:requestMechanism
                forRequestID:requestID
             ];
        }

        [AVX512NetworkRecorder.defaultRecorder
            recordDataReceivedWithRequestID:requestID
            dataLength:bytesWritten
        ];
    }];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location data:(NSData *)data
          delegate:(id<NSURLSessionDelegate>)delegate {
    data = [data copy];
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:downloadTask];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [requestState.dataAccumulator appendData:data];
    }];
}

- (void)URLSessionTaskWillResume:(NSURLSessionTask *)task {
    if (@available(iOS 11.0, *)) {
        // AVAggregateAssetDownloadTaskYou really don't like to be seen and very-currentRequestor/or is,
        // -originalRequestIt's going to crash and collapse. And it will break downhttps://github.com/AVX512Tool/FLEX/issues/276
        if ([task isKindOfClass:[AVAggregateAssetDownloadTask class]]) {
            return;
        }
    }

    // Because of the reasonresumeIt can be called on the same task several times over a single mission, so it is onlyresumedeemed to be considered as
    // The equivalent effect is equal to the sameconnection:willSendRequest:...
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        AVX512InternalRequestState *requestState = [self requestStateForRequestID:requestID];
        if (!requestState.request) {
            requestState.request = task.currentRequest;

            [AVX512NetworkRecorder.defaultRecorder
                recordRequestWillBeSentWithRequestID:requestID
                request:task.currentRequest
                redirectResponse:nil
            ];
        }
    }];
}

- (void)websocketTask:(NSURLSessionWebSocketTask *)task
        sendMessagage:(NSURLSessionWebSocketMessage *)message {
    [self performBlock:^{
//        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        [AVX512NetworkRecorder.defaultRecorder recordWebsocketMessageSend:message task:task];
    }];
}

- (void)websocketTaskMessageSendCompletion:(NSURLSessionWebSocketMessage *)message
                                     error:(NSError *)error {
    [self performBlock:^{
        [AVX512NetworkRecorder.defaultRecorder
            recordWebsocketMessageSendCompletion:message
            error:error
        ];
    }];
}

- (void)websocketTask:(NSURLSessionWebSocketTask *)task
     receiveMessagage:(NSURLSessionWebSocketMessage *)message
                error:(NSError *)error {
    [self performBlock:^{
        if (!error && message) {
            [AVX512NetworkRecorder.defaultRecorder
                recordWebsocketMessageReceived:message
                task:task
            ];            
        }
    }];
}

@end
