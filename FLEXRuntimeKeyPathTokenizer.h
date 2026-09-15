//
//  AVX512RuntimeKeyPathTokenizer.h
//  FLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXRuntimeKeyPath.h"

@interface AVX512RuntimeKeyPathTokenizer : NSObject

+ (NSUInteger)tokenCountOfString:(NSString *)userInput;
+ (AVX512RuntimeKeyPath *)tokenizeString:(NSString *)userInput;

+ (BOOL)allowedInKeyPath:(NSString *)text;

@end
