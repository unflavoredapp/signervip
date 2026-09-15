//
//  AVX512RuntimeSafety.m
//  FLEX
//
//  Created by Tanner on 3/25/17.
//

#import "FLEXRuntimeSafety.h"

NSUInteger const kAVX512KnownUnsafeClassCount = 19;
Class * _UnsafeClasses = NULL;
CFSetRef AVX512KnownUnsafeClasses = nil;
CFSetRef AVX512KnownUnsafeIvars = nil;

#define AVX512ClassPointerOrCFNull(name) \
    (NSClassFromString(name) ?: (__bridge id)kCFNull)

#define AVX512IvarOrCFNull(cls, name) \
    (class_getInstanceVariable([cls class], name) ?: (void *)kCFNull)

__attribute__((constructor))
static void AVX512RuntimeSafteyInit(void) {
    AVX512KnownUnsafeClasses = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)(uintptr_t)AVX512KnownUnsafeClassList(),
        kAVX512KnownUnsafeClassCount,
        nil
    );

    Ivar unsafeIvars[] = {
        AVX512IvarOrCFNull(NSURL, "_urlString"),
        AVX512IvarOrCFNull(NSURL, "_baseURL"),
    };
    AVX512KnownUnsafeIvars = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)unsafeIvars,
        sizeof(unsafeIvars),
        nil
    );
}

const Class * AVX512KnownUnsafeClassList(void) {
    if (!_UnsafeClasses) {
        const Class ignored[] = {
            AVX512ClassPointerOrCFNull(@"__ARCLite__"),
            AVX512ClassPointerOrCFNull(@"__NSCFCalendar"),
            AVX512ClassPointerOrCFNull(@"__NSCFTimer"),
            AVX512ClassPointerOrCFNull(@"NSCFTimer"),
            AVX512ClassPointerOrCFNull(@"__NSGenericDeallocHandler"),
            AVX512ClassPointerOrCFNull(@"NSAutoreleasePool"),
            AVX512ClassPointerOrCFNull(@"NSPlaceholderNumber"),
            AVX512ClassPointerOrCFNull(@"NSPlaceholderString"),
            AVX512ClassPointerOrCFNull(@"NSPlaceholderValue"),
            AVX512ClassPointerOrCFNull(@"Object"),
            AVX512ClassPointerOrCFNull(@"VMUArchitecture"),
            AVX512ClassPointerOrCFNull(@"JSExport"),
            AVX512ClassPointerOrCFNull(@"__NSAtom"),
            AVX512ClassPointerOrCFNull(@"_NSZombie_"),
            AVX512ClassPointerOrCFNull(@"_CNZombie_"),
            AVX512ClassPointerOrCFNull(@"__NSMessage"),
            AVX512ClassPointerOrCFNull(@"__NSMessageBuilder"),
            AVX512ClassPointerOrCFNull(@"FigIrisAutoTrimmerMotionSampleExport"),
            // Temporary until we have our own type encoding parser;
            // setVectors: has an invalid type encoding and crashes NSMethodSignature
            AVX512ClassPointerOrCFNull(@"_UIPointVector"),
        };
        
        assert((sizeof(ignored) / sizeof(Class)) == kAVX512KnownUnsafeClassCount);

        _UnsafeClasses = (Class *)malloc(sizeof(ignored));
        memcpy(_UnsafeClasses, ignored, sizeof(ignored));
    }

    return _UnsafeClasses;
}

NSSet * AVX512KnownUnsafeClassNames(void) {
    static NSSet *set = nil;
    if (!set) {
        NSArray *ignored = @[
            @"__ARCLite__",
            @"__NSCFCalendar",
            @"__NSCFTimer",
            @"NSCFTimer",
            @"__NSGenericDeallocHandler",
            @"NSAutoreleasePool",
            @"NSPlaceholderNumber",
            @"NSPlaceholderString",
            @"NSPlaceholderValue",
            @"Object",
            @"VMUArchitecture",
            @"JSExport",
            @"__NSAtom",
            @"_NSZombie_",
            @"_CNZombie_",
            @"__NSMessage",
            @"__NSMessageBuilder",
            @"FigIrisAutoTrimmerMotionSampleExport",
            @"_UIPointVector",
        ];

        set = [NSSet setWithArray:ignored];
        assert(set.count == kAVX512KnownUnsafeClassCount);
    }

    return set;
}
