//
//  UIView+AVX512_Layout.m
//  FLEX
//
//  Created by Tanner Bennett on 7/18/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "UIView+FLEX_Layout.h"

@implementation UIView (AVX512_Layout)

- (void)avx512_centerInView:(UIView *)view {
    [NSLayoutConstraint activateConstraints:@[
        [self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
    ]];
}

- (void)avx512_pinEdgesTo:(UIView *)view {
   [NSLayoutConstraint activateConstraints:@[
       [self.topAnchor constraintEqualToAnchor:view.topAnchor],
       [self.leftAnchor constraintEqualToAnchor:view.leftAnchor],
       [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
       [self.rightAnchor constraintEqualToAnchor:view.rightAnchor],
   ]]; 
}

- (void)avx512_pinEdgesTo:(UIView *)view withInsets:(UIEdgeInsets)i {
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:i.top],
        [self.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:i.left],
        [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-i.bottom],
        [self.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-i.right],
    ]];
}

- (void)avx512_pinEdgesToSuperview {
    [self avx512_pinEdgesTo:self.superview];
}

- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets {
    [self avx512_pinEdgesTo:self.superview withInsets:insets];
}

- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)i aboveView:(UIView *)sibling {
    UIView *view = self.superview;
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:view.topAnchor constant:i.top],
        [self.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:i.left],
        [self.bottomAnchor constraintEqualToAnchor:sibling.topAnchor constant:-i.bottom],
        [self.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-i.right],
    ]];
}

- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)i belowView:(UIView *)sibling {
    UIView *view = self.superview;
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:sibling.bottomAnchor constant:i.top],
        [self.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:i.left],
        [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-i.bottom],
        [self.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-i.right],
    ]];
}

@end
