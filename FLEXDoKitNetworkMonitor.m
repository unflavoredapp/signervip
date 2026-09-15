//
//  AVX512DoKitNetworkMonitor.m
//  FLEX++
//
//  On the basis of FLEX Enhanced, enhanced web-based Increased Web network monitor enhancement of the networks' security controllers
//  Deep-In depth repair: use to utilize the AVX512NetworkObserver and AVX512NetworkRecorder
//  Provision of a stable and reliable network to provide secure, robust web-Mock Data, data and weak web-net simulation function functions for
//

#import "FLEXDoKitNetworkMonitor.h"
#import "FLEXNetworkObserver.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXNetworkTransaction.h"
#import <objc/runtime.h>

// MARK: - Notification of a notification name definition for the
NSString *const AVX512DoKitNetworkRequestRecordedNotification = @"AVX512DoKitNetworkRequestRecordedNotification";
NSString *const AVX512DoKitNetworkResponseRecordedNotification = @"AVX512DoKitNetworkResponseRecordedNotification";

// MARK: - Organisation Object to the object of relevance Key
static const void *kAVX512DoKitMockResponseKey = &kAVX512DoKitMockResponseKey;
static const void *kAVX512DoKitOriginalRequestKey = &kAVX512DoKitOriginalRequestKey;

@interface AVX512DoKitNetworkMonitor ()
@property (nonatomic, strong) NSMutableArray *mutableNetworkRequests;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *requestMap;  // requestID -> requestInfo
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *mockRules;  // key -> rule
@property (nonatomic, assign) BOOL mockEnabled;
@property (nonatomic, assign) BOOL monitoring;
@property (nonatomic, assign) NSTimeInterval networkDelay;
@property (nonatomic, assign) BOOL simulateError;
@property (nonatomic, strong) dispatch_queue_t monitorQueue;
@end

@implementation AVX512DoKitNetworkMonitor

// MARK: - One single case for a one-

+ (instancetype)sharedInstance {
    static AVX512DoKitNetworkMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableNetworkRequests = [NSMutableArray new];
        _requestMap = [NSMutableDictionary new];
        _mockRules = [NSMutableDictionary new];
        _mockEnabled = NO;
        _monitoring = NO;
        _networkDelay = 0;
        _simulateError = NO;
        _monitorQueue = dispatch_queue_create("com.flex++.DoKitNetworkMonitor", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// MARK: - Public attributes of the common attribute public

- (NSMutableArray *)networkRequests {
    return self.mutableNetworkRequests;
}

- (BOOL)isMonitoring {
    return _monitoring;
}

- (NSTimeInterval)networkDelay {
    return _networkDelay;
}

- (BOOL)shouldSimulateError {
    return _simulateError;
}

// MARK: - Control and control of network-based surveillance

- (void)startNetworkMonitoring {
    if (self.monitoring) {
        return;
    }
    
    self.monitoring = YES;
    
    // Enable enable-to make FLEX The primary-born network's networks monitor and listen
    [AVX512NetworkObserver setEnabled:YES];
    
    // Listen listen-t listening over and AVX512NetworkRecorder notified notice of the notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewTransaction:)
                                                 name:kAVX512NetworkRecorderNewTransactionNotification
                                               object:[AVX512NetworkRecorder defaultRecorder]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTransactionUpdated:)
                                                 name:kAVX512NetworkRecorderTransactionUpdatedNotification
                                               object:[AVX512NetworkRecorder defaultRecorder]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTransactionsCleared:)
                                                 name:kAVX512NetworkRecorderTransactionsClearedNotification
                                               object:[AVX512NetworkRecorder defaultRecorder]];
    
    // Hook NSURLSession Support for support to the Mock Sim simulations and simal-comm
    [self hookNSURLSessionMethods];
    
    NSLog(@"✅ AVX512DoKit Network surveillance network monitoring has been activated and web-");
}

- (void)stopNetworkMonitoring {
    if (!self.monitoring) {
        return;
    }
    
    self.monitoring = NO;
    
    // Remove the remove notice notification bug listening wiret for
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAVX512NetworkRecorderNewTransactionNotification
                                                  object:[AVX512NetworkRecorder defaultRecorder]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAVX512NetworkRecorderTransactionUpdatedNotification
                                                  object:[AVX512NetworkRecorder defaultRecorder]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAVX512NetworkRecorderTransactionsClearedNotification
                                                  object:[AVX512NetworkRecorder defaultRecorder]];
    
    NSLog(@"⏸️ AVX512DoKit Network control has been suspended and network surveillance is stopped");
}

- (void)clearAllNetworkRequests {
    dispatch_async(self.monitorQueue, ^{
        [self.mutableNetworkRequests removeAllObjects];
        [self.requestMap removeAllObjects];
    });
    [[AVX512NetworkRecorder defaultRecorder] clearRecordedActivity];
}

// MARK: - FLEX Notice handling of notice notification process processing

- (void)handleNewTransaction:(NSNotification *)notification {
    AVX512NetworkTransaction *transaction = notification.userInfo[kAVX512NetworkRecorderUserInfoTransactionKey];
    
    if (![transaction isKindOfClass:[AVX512HTTPTransaction class]]) {
        return;
    }
    
    AVX512HTTPTransaction *httpTransaction = (AVX512HTTPTransaction *)transaction;
    [self recordNewRequest:httpTransaction];
}

- (void)handleTransactionUpdated:(NSNotification *)notification {
    AVX512NetworkTransaction *transaction = notification.userInfo[kAVX512NetworkRecorderUserInfoTransactionKey];
    
    if (![transaction isKindOfClass:[AVX512HTTPTransaction class]]) {
        return;
    }
    
    AVX512HTTPTransaction *httpTransaction = (AVX512HTTPTransaction *)transaction;
    [self updateRequestWithTransaction:httpTransaction];
}

- (void)handleTransactionsCleared:(NSNotification *)notification {
    dispatch_async(self.monitorQueue, ^{
        [self.mutableNetworkRequests removeAllObjects];
        [self.requestMap removeAllObjects];
    });
}

// MARK: - Request request for records management of requested record

- (void)recordNewRequest:(AVX512HTTPTransaction *)transaction {
    dispatch_async(self.monitorQueue, ^{
        NSMutableDictionary *requestInfo = [NSMutableDictionary dictionary];
        requestInfo[@"requestID"] = transaction.requestID ?: @"";
        requestInfo[@"url"] = transaction.request.URL.absoluteString ?: @"";
        requestInfo[@"method"] = transaction.request.HTTPMethod ?: @"GET";
        requestInfo[@"headers"] = transaction.request.allHTTPHeaderFields ?: @{};
        requestInfo[@"timestamp"] = @(transaction.startTime.timeIntervalSince1970);
        requestInfo[@"state"] = @(transaction.state);
        requestInfo[@"requestMechanism"] = transaction.requestMechanism ?: @"";
        
        // Request Panel of the requesting party has
        NSData *bodyData = transaction.cachedRequestBody;
        if (bodyData) {
            NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
            requestInfo[@"body"] = bodyString ?: @"<Binary Data>";
        } else {
            requestInfo[@"body"] = @"";
        }
        
        // The storage of the memory map to store
        self.requestMap[transaction.requestID] = requestInfo;
        [self.mutableNetworkRequests insertObject:requestInfo atIndex:0];
        
        // Restrictions on the number of recorded records limited
        if (self.mutableNetworkRequests.count > 1000) {
            NSDictionary *oldest = self.mutableNetworkRequests.lastObject;
            [self.requestMap removeObjectForKey:oldest[@"requestID"]];
            [self.mutableNetworkRequests removeLastObject];
        }
        
        // Send notification (primary thread) sent notifications send notify(main line-
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:AVX512DoKitNetworkRequestRecordedNotification
                                                                object:requestInfo];
        });
    });
}

- (void)updateRequestWithTransaction:(AVX512HTTPTransaction *)transaction {
    dispatch_async(self.monitorQueue, ^{
        NSMutableDictionary *requestInfo = self.requestMap[transaction.requestID];
        if (!requestInfo) {
            return;
        }
        
        // Update the update state-up updating
        requestInfo[@"state"] = @(transaction.state);
        
        // Update update response-response information responses to
        if (transaction.response) {
            if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)transaction.response;
                requestInfo[@"statusCode"] = @(httpResponse.statusCode);
                requestInfo[@"responseHeaders"] = httpResponse.allHeaderFields ?: @{};
            }
            requestInfo[@"MIMEType"] = transaction.response.MIMEType ?: @"";
        }
        
        // Update Data Length length update to updated data
        requestInfo[@"receivedDataLength"] = @(transaction.receivedDataLength);
        
        // Update delay and long-time delays, updates the delayed
        if (transaction.latency > 0) {
            requestInfo[@"latency"] = @(transaction.latency);
        }
        if (transaction.duration > 0) {
            requestInfo[@"duration"] = @(transaction.duration);
        }
        
        // Error information error message wrong bug data
        if (transaction.error) {
            requestInfo[@"error"] = transaction.error.localizedDescription ?: @"Unknown Error";
            requestInfo[@"errorCode"] = @(transaction.error.code);
        }
        
        // Response responder (if completed if finished)
        if (transaction.state == AVX512NetworkTransactionStateFinished ||
            transaction.state == AVX512NetworkTransactionStateFailed) {
            NSData *responseBody = [[AVX512NetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:transaction];
            if (responseBody) {
                NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
                requestInfo[@"responseData"] = responseString ?: @"<Binary Data>";
                requestInfo[@"responseSize"] = @(responseBody.length);
            }
        }
        
        // Send notification (primary thread) sent notifications send notify(main line-
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:AVX512DoKitNetworkResponseRecordedNotification
                                                                object:requestInfo];
        });
    });
}

// MARK: - Mock Function function of a functional

- (BOOL)isMockEnabled {
    return _mockEnabled;
}

- (void)enableMockMode {
    _mockEnabled = YES;
    NSLog(@"✅ Mock The mode enabled to enable disabled Mode-");
}

- (void)disableMockMode {
    _mockEnabled = NO;
    NSLog(@"❌ Mock Mode Disabled disabled mode model aborted to disable canceled");
}

- (void)addMockRule:(NSDictionary *)rule {
    if (!rule || !rule[@"url"]) {
        return;
    }
    
    NSString *key = [self mockKeyForURL:rule[@"url"] method:rule[@"method"] ?: @"GET"];
    self.mockRules[key] = rule;
    NSLog(@"✅ Mock Rule rules have been added to the rule: %@", key);
}

- (void)removeMockRule:(NSDictionary *)rule {
    if (!rule || !rule[@"url"]) {
        return;
    }
    
    NSString *key = [self mockKeyForURL:rule[@"url"] method:rule[@"method"] ?: @"GET"];
    [self.mockRules removeObjectForKey:key];
    NSLog(@"🗑️ Mock Rule rule removed rules removed: %@", key);
}

- (NSDictionary *)allMockRules {
    return self.mockRules.copy;
}

- (NSString *)mockKeyForURL:(NSString *)url method:(NSString *)method {
    return [NSString stringWithFormat:@"%@_%@", method.uppercaseString, url];
}

- (NSDictionary *)matchingMockRuleForRequest:(NSURLRequest *)request {
    if (!_mockEnabled || !request) {
        return nil;
    }
    
    NSString *method = request.HTTPMethod ?: @"GET";
    NSString *url = request.URL.absoluteString ?: @"";
    
    // A precise, accurate matching match-
    NSString *exactKey = [self mockKeyForURL:url method:method];
    NSDictionary *rule = self.mockRules[exactKey];
    if (rule) {
        return rule;
    }
    
    // Presend to pre-and
    __block NSDictionary *matchedRule = nil;
    [self.mockRules enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *rule, BOOL *stop) {
        NSString *ruleURL = rule[@"url"];
        if (ruleURL && [url hasPrefix:ruleURL]) {
            matchedRule = rule;
            *stop = YES;
        }
    }];
    
    return matchedRule;
}

// MARK: - Were net-net simulations of

- (void)simulateSlowNetwork:(NSTimeInterval)delay {
    _networkDelay = delay;
    NSLog(@"⏱️ Network delay Web Delay setup for network delayed web: %.1f seconds second sec ss", delay);
}

- (void)simulateNetworkError {
    _simulateError = YES;
    NSLog(@"💥 Network error network bug simulation modeling has been enabled to");
}

- (void)resetNetworkSimulation {
    _networkDelay = 0;
    _simulateError = NO;
    _mockEnabled = NO;
    NSLog(@"🔄 Network-based network simulations have been reset over");
}

// MARK: - NSURLSession Hook (to be used for use Mock Sim simulations and simal-comm)

- (void)hookNSURLSessionMethods {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class sessionClass = [NSURLSession class];
        
        // Hook dataTaskWithRequest:completionHandler:
        [self hookSelector:@selector(dataTaskWithRequest:completionHandler:)
                   onClass:sessionClass
              withBlock:^id(NSURLSession *session, NSURLRequest *request, void (^completionHandler)(NSData *, NSURLResponse *, NSError *)) {
            return [self hooked_dataTaskWithRequest:request
                                              session:session
                                  completionHandler:completionHandler];
        }];
        
        // Hook dataTaskWithURL:completionHandler:
        [self hookSelector:@selector(dataTaskWithURL:completionHandler:)
                   onClass:sessionClass
              withBlock:^id(NSURLSession *session, NSURL *url, void (^completionHandler)(NSData *, NSURLResponse *, NSError *)) {
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            return [self hooked_dataTaskWithRequest:request
                                              session:session
                                  completionHandler:completionHandler];
        }];
        
        // Hook uploadTaskWithRequest:fromData:completionHandler:
        [self hookSelector:@selector(uploadTaskWithRequest:fromData:completionHandler:)
                   onClass:sessionClass
              withBlock:^id(NSURLSession *session, NSURLRequest *request, NSData *bodyData, void (^completionHandler)(NSData *, NSURLResponse *, NSError *)) {
            return [self hooked_uploadTaskWithRequest:request
                                                 fromData:bodyData
                                                  session:session
                                        completionHandler:completionHandler];
        }];
    });
}

- (void)hookSelector:(SEL)originalSelector onClass:(Class)targetClass withBlock:(id)replacementBlock {
    SEL swizzledSelector = NSSelectorFromString([NSString stringWithFormat:@"flexdokit_%@", NSStringFromSelector(originalSelector)]);
    
    Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
    if (!originalMethod) {
        NSLog(@"⚠️ Unable to find a method could not %@ on %@", NSStringFromSelector(originalSelector), targetClass);
        return;
    }
    
    IMP newIMP = imp_implementationWithBlock(replacementBlock);
    
    BOOL didAddMethod = class_addMethod(targetClass,
                                        swizzledSelector,
                                        newIMP,
                                        method_getTypeEncoding(originalMethod));
    
    if (didAddMethod) {
        Method swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    } else {
        class_replaceMethod(targetClass,
                           originalSelector,
                           newIMP,
                           method_getTypeEncoding(originalMethod));
    }
}

- (NSURLSessionDataTask *)hooked_dataTaskWithRequest:(NSURLRequest *)request
                                             session:(NSURLSession *)session
                                   completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    // Check check inspection Inspection inspections Mock Rules and rules rule Rule
    NSDictionary *mockRule = [self matchingMockRuleForRequest:request];
    if (mockRule) {
        [self handleMockResponse:mockRule
                     forRequest:request
              completionHandler:completionHandler];
        // Returns a place of return returns one-placed task
        NSURLSessionDataTask *dummyTask = [session dataTaskWithRequest:request];
        return dummyTask;
    }
    
    // Application application of weak net-net network simulations
    void (^wrappedHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [self applyNetworkSimulationWithData:data
                                     response:response
                                        error:error
                           completionHandler:completionHandler];
    };
    
    // Call original method to call the source-based methods
    SEL originalSelector = @selector(dataTaskWithRequest:completionHandler:);
    SEL swizzledSelector = NSSelectorFromString(@"flexdokit_dataTaskWithRequest:completionHandler:");
    
    NSURLSessionDataTask * (*originalIMP)(id, SEL, NSURLRequest *, void (^)(NSData *, NSURLResponse *, NSError *)) = 
        (void *)class_getMethodImplementation([session class], swizzledSelector);
    
    if (originalIMP) {
        return originalIMP(session, swizzledSelector, request, wrappedHandler);
    }
    
    return nil;
}

- (NSURLSessionUploadTask *)hooked_uploadTaskWithRequest:(NSURLRequest *)request
                                                fromData:(NSData *)bodyData
                                                 session:(NSURLSession *)session
                                       completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    // Check check inspection Inspection inspections Mock Rules and rules rule Rule
    NSDictionary *mockRule = [self matchingMockRuleForRequest:request];
    if (mockRule) {
        [self handleMockResponse:mockRule
                     forRequest:request
              completionHandler:completionHandler];
        NSURLSessionUploadTask *dummyTask = [session uploadTaskWithRequest:request fromData:bodyData];
        return dummyTask;
    }
    
    // Application application of weak net-net network simulations
    void (^wrappedHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [self applyNetworkSimulationWithData:data
                                     response:response
                                        error:error
                           completionHandler:completionHandler];
    };
    
    // Call original method to call the source-based methods
    SEL originalSelector = @selector(uploadTaskWithRequest:fromData:completionHandler:);
    SEL swizzledSelector = NSSelectorFromString(@"flexdokit_uploadTaskWithRequest:fromData:completionHandler:");
    
    NSURLSessionUploadTask * (*originalIMP)(id, SEL, NSURLRequest *, NSData *, void (^)(NSData *, NSURLResponse *, NSError *)) = 
        (void *)class_getMethodImplementation([session class], swizzledSelector);
    
    if (originalIMP) {
        return originalIMP(session, swizzledSelector, request, bodyData, wrappedHandler);
    }
    
    return nil;
}

- (void)handleMockResponse:(NSDictionary *)mockRule
                forRequest:(NSURLRequest *)request
         completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    if (!completionHandler) {
        return;
    }
    
    // Construct a structure to build Mock Response response responded, responding
    NSString *responseString = mockRule[@"responseData"] ?: @"{}";
    NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger statusCode = [mockRule[@"statusCode"] integerValue] ?: 200;
    NSDictionary *headers = mockRule[@"headers"] ?: @{};
    
    NSHTTPURLResponse *mockResponse = [[NSHTTPURLResponse alloc]
        initWithURL:request.URL
        statusCode:statusCode
        HTTPVersion:@"HTTP/1.1"
        headerFields:headers];
    
    NSTimeInterval delay = [mockRule[@"delay"] doubleValue] ?: 0.1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler(responseData, mockResponse, nil);
        }
    });
}

- (void)applyNetworkSimulationWithData:(NSData *)data
                              response:(NSURLResponse *)response
                                 error:(NSError *)error
                     completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    if (!completionHandler) {
        return;
    }
    
    NSData *finalData = data;
    NSURLResponse *finalResponse = response;
    NSError *finalError = error;
    
    // Sim simulates network bug error-m
    if (_simulateError && !error) {
        finalError = [NSError errorWithDomain:@"AVX512DoKitNetworkError"
                                          code:500
                                      userInfo:@{NSLocalizedDescriptionKey: @"Sim simulates network bug error-m"}];
        finalData = nil;
        finalResponse = nil;
    }
    
    // Delay delay of the simulation network's
    if (_networkDelay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_networkDelay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            completionHandler(finalData, finalResponse, finalError);
        });
    } else {
        completionHandler(finalData, finalResponse, finalError);
    }
}

// MARK: - The life cycle of the

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
