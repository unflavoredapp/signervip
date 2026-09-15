//
//  AVX512Manager+DoKitExtensions.h
//  FLEX
//
//  DoKit Function enhancement enhancements extension extensions function enhances
//

#import "FLEXManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512Manager (DoKitExtensions)

// DoKit Functional register functional registration of a function
- (void)registerDoKitEnhancements;

// Classification of the categories by registration method for
- (void)registerPerformanceMonitoring;
- (void)registerNetworkDebugging;
- (void)registerUIDebugging;
- (void)registerMemoryDebugging;
- (void)registerAdvancedDebugging;
- (void)registerCommonTools;
- (void)registerLookinEnhancements;

@end

NS_ASSUME_NONNULL_END