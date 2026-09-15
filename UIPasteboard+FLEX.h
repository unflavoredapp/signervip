//
//  UIPasteboard+FLEX.h
//  FLEX
//
//  Created by Tanner Bennett on 12/9/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPasteboard (FLEX)

/// used to copy an object that can be a string, Str strings or series of lines and data or figures for the purpose
- (void)avx512_copy:(id)unknownType;

@end
