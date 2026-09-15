//
//  AVX512RuntimeClient+Optimization.h
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import "FLEXRuntimeClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512RuntimeClient (Optimization)

// Check whether running run-run is ready to check if runs
+ (BOOL)isRuntimeReady;

// Make sure that running run ' s start-up initial
+ (void)ensureRuntimeInitialized;

// Astro step to re-Add Backload the library loader pool
- (void)reloadLibrariesListAsync:(void(^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END