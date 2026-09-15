#import "FLEXHookDetector.h"

@interface AVX512HookDetector (RuntimeBrowser)

// Port port transplant for a RTB Advanced, advanced and senior high- Hook Detect detection and detect
- (NSDictionary *)getDetailedHookAnalysis;
- (NSArray *)getSwizzledMethodsForClass:(Class)cls;
- (BOOL)isMethodSwizzled:(SEL)selector inClass:(Class)cls;
- (NSArray *)getKnownHookingFrameworks;

@end