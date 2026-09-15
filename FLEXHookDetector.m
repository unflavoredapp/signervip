//
//  AVX512HookDetector.m
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import "FLEXHookDetector.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>

@implementation AVX512HookDetector

+ (instancetype)sharedDetector {
    static AVX512HookDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[self alloc] init];
    });
    return detector;
}

- (BOOL)isMethodHooked:(Method)method ofClass:(Class)cls {
    if (!method || !cls) return NO;
    
    SEL selector = method_getName(method);
    IMP imp = class_getMethodImplementation(cls, selector);
    IMP originalImp = method_getImplementation(method);
    
    // From all from the RTBHookDetector The logic to detect logical of the check-log
    
    // Check check inspection Inspection inspections IMP If the address is not in an executable non-ex
    Dl_info info;
    if (dladdr((void *)imp, &info)) {
        // If if, what IMP It is not in the original library, it may be possible hook
        if (strstr(info.dli_fname, "hook") || strstr(info.dli_fname, "substrate")) {
            return YES;
        }
    }
    
    // Check whether the method is achieved by checking if it has been
    return (imp != originalImp);
}

- (NSArray *)getHookedMethodsForClass:(Class)cls {
    if (!cls) return @[];
    
    NSMutableArray *hookedMethods = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        if ([self isMethodHooked:method ofClass:cls]) {
            SEL selector = method_getName(method);
            IMP imp = class_getMethodImplementation(cls, selector);
            IMP originalImp = method_getImplementation(method);
            
            // From all from the RTB Detailed information-gathering on the details of transplant
            Dl_info hookInfo;
            NSString *hookLocation = @"Unknown";
            if (dladdr((void *)imp, &hookInfo) && hookInfo.dli_fname) {
                hookLocation = @(hookInfo.dli_fname);
            }
            
            [hookedMethods addObject:@{
                @"selector": NSStringFromSelector(selector),
                @"currentAddress": [NSString stringWithFormat:@"%p", imp],
                @"originalAddress": [NSString stringWithFormat:@"%p", originalImp],
                @"hookLocation": hookLocation,
                @"typeEncoding": @(method_getTypeEncoding(method) ?: "")
            }];
        }
    }
    
    free(methods);
    return hookedMethods;
}

- (NSDictionary *)getAllHookedMethods {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = classes[i];
        NSArray *hookedMethods = [self getHookedMethodsForClass:cls];
        
        if (hookedMethods.count > 0) {
            result[NSStringFromClass(cls)] = hookedMethods;
        }
    }
    
    free(classes);
    return result;
}

@end