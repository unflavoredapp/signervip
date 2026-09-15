//
//  AVX512SearchToken.m
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXSearchToken.h"

@interface AVX512SearchToken () {
    NSString *avx512_description;
}
@end

@implementation AVX512SearchToken

+ (instancetype)any {
    static AVX512SearchToken *any = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        any = [self string:nil options:TBWildcardOptionsAny];
    });

    return any;
}

+ (instancetype)string:(NSString *)string options:(TBWildcardOptions)options {
    AVX512SearchToken *token  = [self new];
    token->_string  = string;
    token->_options = options;
    return token;
}

- (BOOL)isAbsolute {
    return _options == TBWildcardOptionsNone;
}

- (BOOL)isAny {
    return _options == TBWildcardOptionsAny;
}

- (BOOL)isEmpty {
    return self.isAny && self.string.length == 0;
}

- (NSString *)description {
    if (avx512_description) {
        return avx512_description;
    }

    switch (_options) {
        case TBWildcardOptionsNone:
            avx512_description = _string;
            break;
        case TBWildcardOptionsAny:
            avx512_description = @"*";
            break;
        default: {
            NSMutableString *desc = [NSMutableString new];
            if (_options & TBWildcardOptionsPrefix) {
                [desc appendString:@"*"];
            }
            [desc appendString:_string];
            if (_options & TBWildcardOptionsSuffix) {
                [desc appendString:@"*"];
            }
            avx512_description = desc;
        }
    }

    return avx512_description;
}

- (NSUInteger)hash {
    return self.description.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AVX512SearchToken class]]) {
        AVX512SearchToken *token = object;
        return [_string isEqualToString:token->_string] && _options == token->_options;
    }

    return NO;
}

@end
