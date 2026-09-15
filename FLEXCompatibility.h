#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// iOSVersion version to check versions of the revision
#define AVX512_AT_LEAST_IOS11 (@available(iOS 11.0, *))
#define AVX512_AT_LEAST_IOS13 (@available(iOS 13.0, *))
#define AVX512_AT_LEAST_IOS14 (@available(iOS 14.0, *))

// System colour color compatibility for system-system Color comp
#define AVX512SystemBackgroundColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemBackgroundColor] : [UIColor whiteColor])

#define AVX512SystemBlueColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemBlueColor] : [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0])

#define AVX512SystemRedColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemRedColor] : [UIColor redColor])

#define AVX512SystemGreenColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemGreenColor] : [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0])

#define AVX512SystemOrangeColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemOrangeColor] : [UIColor orangeColor])

#define AVX512SystemGrayColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemGrayColor] : [UIColor colorWithWhite:0.6 alpha:1.0])

#define AVX512SystemYellowColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemYellowColor] : [UIColor yellowColor])

#define AVX512SystemPurpleColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemPurpleColor] : [UIColor purpleColor])

#define AVX512SystemPinkColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemPinkColor] : [UIColor colorWithRed:1.0 green:0.176 blue:0.333 alpha:1.0])

#define AVX512SystemTealColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemTealColor] : [UIColor colorWithRed:0.353 green:0.784 blue:0.98 alpha:1.0])

#define AVX512SystemIndigoColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemIndigoColor] : [UIColor colorWithRed:0.345 green:0.337 blue:0.839 alpha:1.0])

// Text colour text color compatibility with the overall macro-m
#define AVX512LabelColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor labelColor] : [UIColor blackColor])

#define AVX512SecondaryLabelColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor secondaryLabelColor] : [UIColor colorWithWhite:0.6 alpha:1.0])

#define AVX512TertiaryLabelColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor tertiaryLabelColor] : [UIColor colorWithWhite:0.7 alpha:1.0])

#define AVX512QuaternaryLabelColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor quaternaryLabelColor] : [UIColor colorWithWhite:0.8 alpha:1.0])

// Background background for context color colour to compatibility with the
#define AVX512SecondarySystemBackgroundColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor secondarySystemBackgroundColor] : [UIColor colorWithWhite:0.95 alpha:1.0])

#define AVX512TertiarySystemBackgroundColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor tertiarySystemBackgroundColor] : [UIColor colorWithWhite:0.9 alpha:1.0])

#define AVX512SystemGroupedBackgroundColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor systemGroupedBackgroundColor] : [UIColor colorWithWhite:0.94 alpha:1.0])

#define AVX512SecondarySystemGroupedBackgroundColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor secondarySystemGroupedBackgroundColor] : [UIColor whiteColor])

// The Sepa line color to separate the lines colours of
#define AVX512SeparatorColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor separatorColor] : [UIColor colorWithWhite:0.8 alpha:1.0])

#define AVX512OpaqueSeparatorColor \
    (AVX512_AT_LEAST_IOS13 ? [UIColor opaqueSeparatorColor] : [UIColor colorWithWhite:0.7 alpha:1.0])

// A secure regional security area compatibility compatible function for a safe
static inline NSLayoutYAxisAnchor *AVX512SafeAreaTopAnchor(UIViewController *viewController) {
    if (AVX512_AT_LEAST_IOS11) {
        return viewController.view.safeAreaLayoutGuide.topAnchor;
    } else {
        return viewController.topLayoutGuide.bottomAnchor;
    }
}

static inline NSLayoutYAxisAnchor *AVX512SafeAreaBottomAnchor(UIViewController *viewController) {
    if (AVX512_AT_LEAST_IOS11) {
        return viewController.view.safeAreaLayoutGuide.bottomAnchor;
    } else {
        return viewController.bottomLayoutGuide.topAnchor;
    }
}

static inline NSLayoutXAxisAnchor *AVX512SafeAreaLeadingAnchor(UIViewController *viewController) {
    if (AVX512_AT_LEAST_IOS11) {
        return viewController.view.safeAreaLayoutGuide.leadingAnchor;
    } else {
        return viewController.view.leadingAnchor;
    }
}

static inline NSLayoutXAxisAnchor *AVX512SafeAreaTrailingAnchor(UIViewController *viewController) {
    if (AVX512_AT_LEAST_IOS11) {
        return viewController.view.safeAreaLayoutGuide.trailingAnchor;
    } else {
        return viewController.view.trailingAnchor;
    }
}

// The font Font compatibility-compability compatible to the
#define AVX512SystemFontOfSize(size) [UIFont systemFontOfSize:size]
#define AVX512BoldSystemFontOfSize(size) [UIFont boldSystemFontOfSize:size]

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#define AVX512MonospacedSystemFontOfSize(size) \
    (AVX512_AT_LEAST_IOS13 ? [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular] : [UIFont fontWithName:@"Courier" size:size])
#else
#define AVX512MonospacedSystemFontOfSize(size) [UIFont fontWithName:@"Courier" size:size]
#endif

// Controls control style version of the controls GUI Con compatibility compatible
#define AVX512TableViewStyleInsetGrouped \
    (AVX512_AT_LEAST_IOS13 ? UITableViewStyleInsetGrouped : UITableViewStyleGrouped)

// The window-winding style pop windowshows to support
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#define AVX512AlertControllerStyleActionSheet \
    (AVX512_AT_LEAST_IOS13 ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleActionSheet)
#else
#define AVX512AlertControllerStyleActionSheet UIAlertControllerStyleActionSheet
#endif

// Blu fu blur effect compatibility compatible effects for inclusion-comp
#define AVX512BlurEffectStyleSystemMaterial \
    (AVX512_AT_LEAST_IOS13 ? UIBlurEffectStyleSystemMaterial : UIBlurEffectStyleLight)

#define AVX512BlurEffectStyleSystemThinMaterial \
    (AVX512_AT_LEAST_IOS13 ? UIBlurEffectStyleSystemThinMaterial : UIBlurEffectStyleExtraLight)

// Keyboard appearance look to the keyboard out-of key disk interface compatible
#define AVX512KeyboardAppearanceDefault \
    (AVX512_AT_LEAST_IOS13 ? UIKeyboardAppearanceDefault : UIKeyboardAppearanceDefault)

// The Status Bar status bar and the State of Q-
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#define AVX512StatusBarStyleDefault \
    (AVX512_AT_LEAST_IOS13 ? UIStatusBarStyleDefault : UIStatusBarStyleDefault)
#else
#define AVX512StatusBarStyleDefault UIStatusBarStyleDefault
#endif