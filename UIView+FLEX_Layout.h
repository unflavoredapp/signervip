//
//  UIView+AVX512_Layout.h
//  FLEX
//
//  Created by Tanner Bennett on 7/18/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Padding(p) UIEdgeInsetsMake(p, p, p, p)

@interface UIView (AVX512_Layout)

- (void)avx512_centerInView:(UIView *)view;
- (void)avx512_pinEdgesTo:(UIView *)view;
- (void)avx512_pinEdgesTo:(UIView *)view withInsets:(UIEdgeInsets)insets;
- (void)avx512_pinEdgesToSuperview;
- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets;
- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets aboveView:(UIView *)sibling;
- (void)avx512_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets belowView:(UIView *)sibling;

@end
