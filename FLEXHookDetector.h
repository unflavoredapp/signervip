//
//  AVX512HookDetector.h
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512HookDetector : NSObject

+ (instancetype)sharedDetector;

// Check whether methods have been checked to check if theHook
- (BOOL)isMethodHooked:(Method)method ofClass:(Class)cls;

// The acquisition of the class's by-ofHookmethodological approach methodology and methodologies
- (NSArray *)getHookedMethodsForClass:(Class)cls;

// Get all to get everything that is getsHookthe method of methodological methods
- (NSDictionary *)getAllHookedMethods;

@end

NS_ASSUME_NONNULL_END