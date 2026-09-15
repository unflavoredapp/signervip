#import "FLEXHookDetector+RuntimeBrowser.h"
#import <dlfcn.h>

@implementation AVX512HookDetector (RuntimeBrowser)

- (NSDictionary *)getDetailedHookAnalysis {
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    // Base base, foundation basis Hook Information InfoInfo information
    analysis[@"hookedMethods"] = [self getAllHookedMethods];
    
    // Test to detect known, well-known Hook Framework framework frame of the
    analysis[@"hookingFrameworks"] = [self getKnownHookingFrameworks];
    
    // Statistical information statistical data statistics: Statistics
    NSUInteger totalHookedMethods = 0;
    for (NSString *className in analysis[@"hookedMethods"]) {
        NSArray *methods = analysis[@"hookedMethods"][className];
        totalHookedMethods += methods.count;
    }
    
    analysis[@"statistics"] = @{
        @"totalHookedClasses": @([analysis[@"hookedMethods"] count]),
        @"totalHookedMethods": @(totalHookedMethods)
    };
    
    // Exchange of detection method exchange for test-
    analysis[@"methodSwizzling"] = [self detectMethodSwizzling];
    
    return analysis;
}

- (NSArray *)getSwizzledMethodsForClass:(Class)cls {
    NSMutableArray *swizzled = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        
        if ([self isMethodSwizzled:selector inClass:cls]) {
            [swizzled addObject:@{
                @"selector": NSStringFromSelector(selector),
                @"originalIMP": [NSString stringWithFormat:@"%p", method_getImplementation(method)]
            }];
        }
    }
    
    free(methods);
    return swizzled;
}

- (BOOL)isMethodSwizzled:(SEL)selector inClass:(Class)cls {
    Method method = class_getInstanceMethod(cls, selector);
    if (!method) return NO;
    
    IMP imp = method_getImplementation(method);
    IMP classImp = class_getMethodImplementation(cls, selector);
    
    // Check whether it has been achieved or replaced to check if
    return imp != classImp;
}

- (NSArray *)getKnownHookingFrameworks {
    NSMutableArray *frameworks = [NSMutableArray array];
    
    // To detect common and commonly used tests to Hook Framework framework frame of the
    NSArray *knownFrameworks = @[
        @"fishhook",
        @"MSHookFunction",
        @"CydiaSubstrate",
        @"libffi",
        @"Aspects"
    ];
    
    for (NSString *framework in knownFrameworks) {
        void *handle = dlopen(framework.UTF8String, RTLD_NOLOAD);
        if (handle) {
            [frameworks addObject:@{
                @"name": framework,
                @"loaded": @YES,
                @"path": @(dladdr(handle, NULL) ? "" : "unknown")
            }];
            dlclose(handle);
        }
    }
    
    return frameworks;
}

- (NSDictionary *)detectMethodSwizzling {
    NSMutableDictionary *swizzling = [NSMutableDictionary dictionary];
    
    // Check to check that common and often used persons are Swizzle of a class group, or the
    NSArray *commonTargets = @[
        @"UIViewController",
        @"UIView",
        @"NSObject",
        @"UIApplication",
        @"NSURLSession"
    ];
    
    for (NSString *className in commonTargets) {
        Class cls = NSClassFromString(className);
        if (cls) {
            NSArray *swizzledMethods = [self getSwizzledMethodsForClass:cls];
            if (swizzledMethods.count > 0) {
                swizzling[className] = swizzledMethods;
            }
        }
    }
    
    return swizzling;
}

@end