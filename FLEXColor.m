//
//  AVX512Color.m
//  FLEX
//
//  Created by Benny Wong on 6/18/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXColor.h"
#import "FLEXUtility.h"

#define AVX512DynamicColor(dynamic, static) ({ \
    UIColor *c; \
    if (@available(iOS 13.0, *)) { \
        c = [UIColor dynamic]; \
    } else { \
        c = [UIColor static]; \
    } \
    c; \
});

@implementation AVX512Color

#pragma mark - Background Colors

+ (UIColor *)primaryBackgroundColor {
    return AVX512DynamicColor(systemBackgroundColor, whiteColor);
}

+ (UIColor *)primaryBackgroundColorWithAlpha:(CGFloat)alpha {
    return [[self primaryBackgroundColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)secondaryBackgroundColor {
    return AVX512DynamicColor(
        secondarySystemBackgroundColor,
        colorWithHue:2.0/3.0 saturation:0.02 brightness:0.97 alpha:1
    );
}

+ (UIColor *)secondaryBackgroundColorWithAlpha:(CGFloat)alpha {
    return [[self secondaryBackgroundColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)tertiaryBackgroundColor {
    // All the background/fill colors are varying shades
    // of white and black with really low alpha levels.
    // We use systemGray4Color instead to avoid alpha issues.
    return AVX512DynamicColor(systemGray4Color, lightGrayColor);
}

+ (UIColor *)tertiaryBackgroundColorWithAlpha:(CGFloat)alpha {
    return [[self tertiaryBackgroundColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)groupedBackgroundColor {
    return AVX512DynamicColor(
        systemGroupedBackgroundColor,
        colorWithHue:2.0/3.0 saturation:0.02 brightness:0.97 alpha:1
    );
}

+ (UIColor *)groupedBackgroundColorWithAlpha:(CGFloat)alpha {
    return [[self groupedBackgroundColor] colorWithAlphaComponent:alpha];
}

+ (UIColor *)secondaryGroupedBackgroundColor {
    return AVX512DynamicColor(secondarySystemGroupedBackgroundColor, whiteColor);
}

+ (UIColor *)secondaryGroupedBackgroundColorWithAlpha:(CGFloat)alpha {
    return [[self secondaryGroupedBackgroundColor] colorWithAlphaComponent:alpha];
}

#pragma mark - Text colors

+ (UIColor *)primaryTextColor {
    return AVX512DynamicColor(labelColor, blackColor);
}

+ (UIColor *)deemphasizedTextColor {
    return AVX512DynamicColor(secondaryLabelColor, lightGrayColor);
}

#pragma mark - UI Element Colors

+ (UIColor *)tintColor {
    #if AVX512_AT_LEAST_IOS13_SDK
    if (@available(iOS 13.0, *)) {
        return UIColor.systemBlueColor;
    } else {
        return UIApplication.sharedApplication.keyWindow.tintColor;
    }
    #else
    return UIApplication.sharedApplication.keyWindow.tintColor;
    #endif
}

+ (UIColor *)scrollViewBackgroundColor {
    return AVX512DynamicColor(
        systemGroupedBackgroundColor,
        colorWithHue:2.0/3.0 saturation:0.02 brightness:0.95 alpha:1
    );
}

+ (UIColor *)iconColor {
    return AVX512DynamicColor(labelColor, blackColor);
}

+ (UIColor *)borderColor {
    return [self primaryBackgroundColor];
}

+ (UIColor *)toolbarItemHighlightedColor {
    return AVX512DynamicColor(
        quaternaryLabelColor,
        colorWithHue:2.0/3.0 saturation:0.1 brightness:0.25 alpha:0.6
    );
}

+ (UIColor *)toolbarItemSelectedColor {
    return AVX512DynamicColor(
        secondaryLabelColor,
        colorWithHue:2.0/3.0 saturation:0.1 brightness:0.25 alpha:0.68
    );
}

+ (UIColor *)hairlineColor {
    return AVX512DynamicColor(systemGray3Color, colorWithWhite:0.75 alpha:1);
}

+ (UIColor *)destructiveColor {
    return AVX512DynamicColor(systemRedColor, redColor);
}

@end
