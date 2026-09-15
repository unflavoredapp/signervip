//
//  AVX512RuntimeKeyPath.m
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXRuntimeKeyPath.h"
#import "FLEXRuntimeClient.h"

@interface AVX512RuntimeKeyPath () {
    NSString *avx512_description;
}
@end

@implementation AVX512RuntimeKeyPath

+ (instancetype)empty {
    static AVX512RuntimeKeyPath *empty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AVX512SearchToken *any = AVX512SearchToken.any;

        empty = [self new];
        empty->_bundleKey = any;
        empty->avx512_description = @"";
    });

    return empty;
}

+ (instancetype)bundle:(AVX512SearchToken *)bundle
                 class:(AVX512SearchToken *)cls
                method:(AVX512SearchToken *)method
            isInstance:(NSNumber *)instance
                string:(NSString *)keyPathString {
    AVX512RuntimeKeyPath *keyPath  = [self new];
    keyPath->_bundleKey = bundle;
    keyPath->_classKey  = cls;
    keyPath->_methodKey = method;

    keyPath->_instanceMethods = instance;

    // Remove irrelevant trailing '*' for equality purposes
    if ([keyPathString hasSuffix:@"*"]) {
        keyPathString = [keyPathString substringToIndex:keyPathString.length];
    }
    keyPath->avx512_description = keyPathString;
    
    if (bundle.isAny && cls.isAny && method.isAny) {
        [AVX512RuntimeClient initializeWebKitLegacy];
    }

    return keyPath;
}

- (NSString *)description {
    return avx512_description;
}

- (NSUInteger)hash {
    return avx512_description.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AVX512RuntimeKeyPath class]]) {
        AVX512RuntimeKeyPath *kp = object;
        return [avx512_description isEqualToString:kp->avx512_description];
    }

    return NO;
}

@end
