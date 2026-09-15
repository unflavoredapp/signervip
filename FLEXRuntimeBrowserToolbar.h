//
//  AVX512RuntimeBrowserToolbar.h
//  FLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXKeyboardToolbar.h"
#import "FLEXRuntimeKeyPath.h"

@interface AVX512RuntimeBrowserToolbar : AVX512KeyboardToolbar

+ (instancetype)toolbarWithHandler:(AVX512KBToolbarAction)tapHandler suggestions:(NSArray<NSString *> *)suggestions;

- (void)setKeyPath:(AVX512RuntimeKeyPath *)keyPath suggestions:(NSArray<NSString *> *)suggestions;

@end
