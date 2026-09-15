//
//  UIBarButtonItem+FLEX.h
//  FLEX
//
//  Created by Tanner on 2/4/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AVX512BarButtonItem(title, tgt, sel) \
    [UIBarButtonItem avx512_itemWithTitle:title target:tgt action:sel]
#define AVX512BarButtonItemSystem(item, tgt, sel) \
    [UIBarButtonItem avx512_systemItem:UIBarButtonSystemItem##item target:tgt action:sel]

@interface UIBarButtonItem (FLEX)

@property (nonatomic, readonly, class) UIBarButtonItem *avx512_flexibleSpace;
@property (nonatomic, readonly, class) UIBarButtonItem *avx512_fixedSpace;

+ (instancetype)avx512_itemWithCustomView:(UIView *)customView;
+ (instancetype)avx512_backItemWithTitle:(NSString *)title;

+ (instancetype)avx512_systemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action;

+ (instancetype)avx512_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)avx512_doneStyleitemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)avx512_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)avx512_disabledSystemItem:(UIBarButtonSystemItem)item;
+ (instancetype)avx512_disabledItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;
+ (instancetype)avx512_disabledItemWithImage:(UIImage *)image;

/// @return the receiver
- (UIBarButtonItem *)avx512_withTintColor:(UIColor *)tint;

- (void)_setWidth:(CGFloat)width;

@end
