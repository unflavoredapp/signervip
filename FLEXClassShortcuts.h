//
//  AVX512ClassShortcuts.h
//  FLEX
//
//  Created by Tanner Bennett on 11/22/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXShortcutsSection.h"

/// Provides handy shortcuts for class objects.
/// This is the default section used for all class objects.
@interface AVX512ClassShortcuts : AVX512ShortcutsSection

+ (instancetype)forObject:(Class)cls;

@end
