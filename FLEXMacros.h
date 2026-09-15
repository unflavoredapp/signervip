//
//  AVX512Macros.h
//  FLEX
//
//  Created by Tanner on 3/12/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#ifndef AVX512Macros_h
#define AVX512Macros_h

#ifndef __cplusplus
#ifndef auto
#define auto __auto_type
#endif
#endif

#define avx512_keywordify class NSObject;
#define ctor avx512_keywordify __attribute__((constructor)) void __flex_ctor_##__LINE__()
#define dtor avx512_keywordify __attribute__((destructor)) void __flex_dtor_##__LINE__()

#ifndef strongify

#define weakify(var) __weak __typeof(var) __weak__##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = __weak__##var; \
_Pragma("clang diagnostic pop")

#endif

// A macro to check if we are running in a test environment
#define AVX512_IS_TESTING() (NSClassFromString(@"XCTest") != nil)

/// Whether we want the majority of constructors to run upon load or not.
extern BOOL AVX512ConstructorsShouldRun(void);

/// A macro to return from the current procedure if we don't want to run constructors
#define AVX512_EXIT_IF_NO_CTORS() if (!AVX512ConstructorsShouldRun()) return;

/// Rounds down to the nearest "point" coordinate
NS_INLINE CGFloat AVX512Floor(CGFloat x) {
    return floor(UIScreen.mainScreen.scale * (x)) / UIScreen.mainScreen.scale;
}

/// Returns the given number of points in pixels
NS_INLINE CGFloat AVX512PointsToPixels(CGFloat points) {
    return points / UIScreen.mainScreen.scale;
}

/// Creates a CGRect with all members rounded down to the nearest "point" coordinate
NS_INLINE CGRect AVX512RectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(AVX512Floor(x), AVX512Floor(y), AVX512Floor(width), AVX512Floor(height));
}

/// Adjusts the origin of an existing rect
NS_INLINE CGRect AVX512RectSetOrigin(CGRect r, CGPoint origin) {
    r.origin = origin; return r;
}

/// Adjusts the size of an existing rect
NS_INLINE CGRect AVX512RectSetSize(CGRect r, CGSize size) {
    r.size = size; return r;
}

/// Adjusts the origin.x of an existing rect
NS_INLINE CGRect AVX512RectSetX(CGRect r, CGFloat x) {
    r.origin.x = x; return r;
}

/// Adjusts the origin.y of an existing rect
NS_INLINE CGRect AVX512RectSetY(CGRect r, CGFloat y) {
    r.origin.y = y ; return r;
}

/// Adjusts the size.width of an existing rect
NS_INLINE CGRect AVX512RectSetWidth(CGRect r, CGFloat width) {
    r.size.width = width; return r;
}

/// Adjusts the size.height of an existing rect
NS_INLINE CGRect AVX512RectSetHeight(CGRect r, CGFloat height) {
    r.size.height = height; return r;
}

#define AVX512PluralString(count, plural, singular) [NSString \
    stringWithFormat:@"%@ %@", @(count), (count == 1 ? singular : plural) \
]

#define AVX512PluralFormatString(count, pluralFormat, singularFormat) [NSString \
    stringWithFormat:(count == 1 ? singularFormat : pluralFormat), @(count)  \
]

#define avx512_dispatch_after(nSeconds, onQueue, block) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, \
    (int64_t)(nSeconds * NSEC_PER_SEC)), onQueue, block)

#endif /* AVX512Macros_h */
