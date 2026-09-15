//
//  AVX512RuntimeSafety.h
//  FLEX
//
//  Created by Tanner on 3/25/17.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - Classes

extern NSUInteger const kAVX512KnownUnsafeClassCount;
extern const Class * AVX512KnownUnsafeClassList(void);
extern NSSet * AVX512KnownUnsafeClassNames(void);
extern CFSetRef AVX512KnownUnsafeClasses;

static Class cNSObject = nil, cNSProxy = nil;

__attribute__((constructor))
static void AVX512InitKnownRootClasses(void) {
    cNSObject = [NSObject class];
    cNSProxy = [NSProxy class];
}

static inline BOOL AVX512ClassIsSafe(Class cls) {
    // Is it nil or known to be unsafe?
    if (!cls || CFSetContainsValue(AVX512KnownUnsafeClasses, (__bridge void *)cls)) {
        return NO;
    }
    
    // Is it a known root class?
    if (!class_getSuperclass(cls)) {
        return cls == cNSObject || cls == cNSProxy;
    }
    
    // Probably safe
    return YES;
}

static inline BOOL AVX512ClassNameIsSafe(NSString *cls) {
    if (!cls) return NO;
    
    NSSet *ignored = AVX512KnownUnsafeClassNames();
    return ![ignored containsObject:cls];
}

#pragma mark - Ivars

extern CFSetRef AVX512KnownUnsafeIvars;

static inline BOOL AVX512IvarIsSafe(Ivar ivar) {
    if (!ivar) return NO;

    return !CFSetContainsValue(AVX512KnownUnsafeIvars, ivar);
}
