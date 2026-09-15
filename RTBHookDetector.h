#import <Foundation/Foundation.h>

@interface RTBHookDetector : NSObject

+ (instancetype)sharedDetector;

// Complete complete full-completeHookDetect function to detect the detection
- (NSDictionary *)getAllHookedMethods;
- (NSDictionary *)getAllSwizzledMethods;
- (NSArray *)getHookedMethodsForClass:(Class)cls;
- (BOOL)isMethodHooked:(SEL)selector inClass:(Class)cls;
- (NSArray *)getKnownHookingFrameworks;

@end