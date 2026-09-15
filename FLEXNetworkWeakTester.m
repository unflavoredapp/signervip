//
//  AVX512NetworkWeakTester.m
//  FLEX
//
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import "FLEXNetworkWeakTester.h"
#import <objc/runtime.h>

@interface NSURLSessionConfiguration (AVX512NetworkWeak)
@property (nonatomic, assign) AVX512NetworkWeakType avx512_weakType;
@end

@implementation NSURLSessionConfiguration (AVX512NetworkWeak)

- (void)setFlex_weakType:(AVX512NetworkWeakType)avx512_weakType {
    objc_setAssociatedObject(self, @selector(avx512_weakType), @(avx512_weakType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVX512NetworkWeakType)avx512_weakType {
    return [objc_getAssociatedObject(self, @selector(avx512_weakType)) integerValue];
}

@end

@interface AVX512NetworkWeakTester ()

@property (nonatomic, assign) AVX512NetworkWeakType currentWeakType;
@property (nonatomic, assign) BOOL isSwizzled;
@property (nonatomic, assign) Method originalMethod;
@property (nonatomic, assign) Method swizzledMethod;

@end

@implementation AVX512NetworkWeakTester

+ (instancetype)sharedInstance {
    static AVX512NetworkWeakTester *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AVX512NetworkWeakTester alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentWeakType = AVX512NetworkWeakTypeNone;
        _isSwizzled = NO;
    }
    return self;
}

- (void)startWeakNetworkWithType:(AVX512NetworkWeakType)type {
    self.currentWeakType = type;
    
    if (!self.isSwizzled) {
        [self swizzleNetworkMethods];
        self.isSwizzled = YES;
    }
}

- (void)stopWeakNetwork {
    self.currentWeakType = AVX512NetworkWeakTypeNone;
    
    if (self.isSwizzled) {
        [self unswizzleNetworkMethods];
        self.isSwizzled = NO;
    }
}

- (void)swizzleNetworkMethods {
    // Exchange exchange of exchanges for NSURLSessionConfiguration The whole of all the defaultSessionConfiguration methodological approach methodology and methodologies
    Class class = [NSURLSessionConfiguration class];
    SEL originalSelector = @selector(defaultSessionConfiguration);
    SEL swizzledSelector = @selector(avx512_defaultSessionConfiguration);
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    self.originalMethod = originalMethod;
    self.swizzledMethod = swizzledMethod;
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)unswizzleNetworkMethods {
    // The restoration of the original seed was achieved
    if (self.originalMethod && self.swizzledMethod) {
        method_exchangeImplementations(self.swizzledMethod, self.originalMethod);
    }
}

+ (NSURLSessionConfiguration *)avx512_defaultSessionConfiguration {
    // Call the original method to call raw methods (after exchange) using a primary
    NSURLSessionConfiguration *config = [self avx512_defaultSessionConfiguration];
    
    AVX512NetworkWeakType weakType = [AVX512NetworkWeakTester sharedInstance].currentWeakType;
    config.avx512_weakType = weakType;
    
    // Set the network parameter for web parameters to set a Web-
    switch (weakType) {
        case AVX512NetworkWeakTypeSlow2G:
            config.timeoutIntervalForRequest = 20.0;
            config.timeoutIntervalForResource = 30.0;
            config.HTTPMaximumConnectionsPerHost = 1;
            break;
            
        case AVX512NetworkWeakType2G:
            config.timeoutIntervalForRequest = 10.0;
            config.timeoutIntervalForResource = 20.0;
            config.HTTPMaximumConnectionsPerHost = 2;
            break;
            
        case AVX512NetworkWeakType3G:
            config.timeoutIntervalForRequest = 6.0;
            config.timeoutIntervalForResource = 15.0;
            config.HTTPMaximumConnectionsPerHost = 4;
            break;
            
        case AVX512NetworkWeakType4G:
            config.timeoutIntervalForRequest = 4.0;
            config.timeoutIntervalForResource = 10.0;
            config.HTTPMaximumConnectionsPerHost = 6;
            break;
            
        case AVX512NetworkWeakTypeWifi:
            config.timeoutIntervalForRequest = 3.0;
            config.timeoutIntervalForResource = 8.0;
            config.HTTPMaximumConnectionsPerHost = 8;
            break;
            
        case AVX512NetworkWeakTypeDisconnect:
            // Sets an existing non-existent proxy agent server to set a default, which does not
            config.connectionProxyDictionary = @{
                @"HTTPEnable": @YES,
                @"HTTPProxy": @"127.0.0.1",
                @"HTTPPort": @"1",
            };
            break;
            
        case AVX512NetworkWeakTypeNone:
        default:
            // Keeps the default settings setting to maintain
            break;
    }
    
    return config;
}

@end