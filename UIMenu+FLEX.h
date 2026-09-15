//
//  UIMenu+FLEX.h
//  FLEX
//
//  Created by Tanner on 1/28/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMenu (FLEX)

+ (instancetype)avx512_inlineMenuWithTitle:(NSString *)title
                                   image:(UIImage *)image
                                children:(NSArray<UIMenuElement *> *)children;

- (instancetype)avx512_collapsed;

@end
