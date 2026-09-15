//
//  AVX512ImageShortcuts.h
//  FLEX
//
//  Created by Tanner Bennett on 8/29/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXShortcutsSection.h"

/// Provides "view image" and "save image" shortcuts for UIImage objects
@interface AVX512ImageShortcuts : AVX512ShortcutsSection

+ (instancetype)forObject:(UIImage *)image;

@end
