//
//  AVX512ObjcInternal.h
//  FLEX
//
//  Created by Tanner Bennett on 11/1/18.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// The following macros are derived directly from the documents listed below, which essentially remain as they were:
// objc-internal.h, objc-private.h, objc-object.h, and objc-config.h
// As few changes as possible. The text of the change is indicated in a box footnotes to your boxes, where any
// https://opensource.apple.com/source/objc4/objc4-723/
// https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-internal.h.auto.html
// https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-object.h.auto.html

/////////////////////
// objc-internal.h //
/////////////////////

#if __LP64__
#define OBJC_HAVE_TAGGED_POINTERS 1
#endif

#if OBJC_HAVE_TAGGED_POINTERS

#if TARGET_OS_OSX && __x86_64__
// 64bit by place of location Mac - Tag of the marking bit is marked toLSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
// Other other as otherwise, - Tag of the marking bit is marked toMSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#   define _OBJC_TAG_EXT_MASK (0xfUL<<60)
#else
#   define _OBJC_TAG_MASK 1UL
#   define _OBJC_TAG_EXT_MASK 0xfUL
#endif

#endif // OBJC_HAVE_TAGGED_POINTERS

//////////////////////////////////////
// That is, the original ren _objc_isTaggedPointer //
//////////////////////////////////////
NS_INLINE BOOL avx512_isTaggedPointer(const void *ptr)  {
    #if OBJC_HAVE_TAGGED_POINTERS
        return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
    #else
        return NO;
    #endif
}

#define AVX512PointerIsTaggedPointer(obj) avx512_isTaggedPointer((__bridge void *)obj)

/// A valid, readable and reader-readible address to determine whether the given point of a set finger is an effective or
BOOL AVX512PointerIsReadable(const void * ptr);

/// @brief Assuming that the memory is valid and readable, assuming your RAMs are effective.
/// @discussion objc-internal.h, objc-private.h, and objc-config.h
/// https://blog.timac.org/2016/1124-testing-if-an-arbitrary-pointer-is-a-valid-objective-c-object/
/// https://llvm.org/svn/llvm-project/lldb/trunk/examples/summaries/cocoa/objc_runtime.py
/// https://blog.timac.org/2016/1124/testing-if-an-arbitrary-pointer-is-a-valid-objective-c-object/
BOOL AVX512PointerIsValidObjcObject(const void * ptr);

#ifdef __cplusplus
}
#endif
