//
//  UIBarButtonItem+FLEX.m
//  FLEX
//
//  Created by Tanner on 2/4/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "UIBarButtonItem+FLEX.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIBarButtonItem (FLEX)

+ (UIBarButtonItem *)avx512_flexibleSpace {
    return [self avx512_systemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

+ (UIBarButtonItem *)avx512_fixedSpace {
    UIBarButtonItem *fixed = [self avx512_systemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 60;
    return fixed;
}

+ (instancetype)avx512_systemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action {
    return [[self alloc] initWithBarButtonSystemItem:item target:target action:action];
}

+ (instancetype)avx512_itemWithCustomView:(UIView *)customView {
    return [[self alloc] initWithCustomView:customView];
}

+ (instancetype)avx512_backItemWithTitle:(NSString *)title {
    return [self avx512_itemWithTitle:title target:nil action:nil];
}

+ (instancetype)avx512_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)avx512_doneStyleitemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:target action:action];
}

+ (instancetype)avx512_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [[self alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)avx512_disabledSystemItem:(UIBarButtonSystemItem)system {
    UIBarButtonItem *item = [self avx512_systemItem:system target:nil action:nil];
    item.enabled = NO;
    return item;
}

+ (instancetype)avx512_disabledItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style {
    UIBarButtonItem *item = [self avx512_itemWithTitle:title target:nil action:nil];
    item.enabled = NO;
    return item;
}

+ (instancetype)avx512_disabledItemWithImage:(UIImage *)image {
    UIBarButtonItem *item = [self avx512_itemWithImage:image target:nil action:nil];
    item.enabled = NO;
    return item;
}

- (UIBarButtonItem *)avx512_withTintColor:(UIColor *)tint {
    self.tintColor = tint;
    return self;
}

@end
