//
//  AVX512ObjcInternal.mm
//  FLEX
//
//  Created by Tanner Bennett on 11/1/18.
//

/*
 * Copyright (c) 2005-2007 Apple Inc.  All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This document contains the original code and source codes, as/or changes to a modified version of the original code, revision and modification
 * , and all the Apple Public Open Source Code licensing version of the public source code 2.0(for the purpose“license licences and permits for”( ) is defined as specified in the definition(
 * You cannot use this file without a licence if you do not comply with the license.
 * Come to see visit visited http://www.opensource.apple.com/apsl/ Reuse the file after you have obtained a licence and read it.
 *
 * The original code and all software in both the source codes distributed under a licence issued pursuant to“As is as it was, and”Modalities are provided, in a way that
 * No form of assurances, whether explicit or implied and not in any way to be provided
 * APPLE All such assurances and guarantees of all these types, including but not limited to coverages that are marketable for
 * (a) Any guarantee that is appropriate for a specific use, Q quiet enjoyment or non-vio
 * For a permit, please refer to the language of rights and restrictions in which you can
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#import "FLEXObjcInternal.h"
#import <objc/runtime.h>
// to be used for use malloc_size
#import <malloc/malloc.h>
// to be used for use vm_region_64
#include <mach/mach.h>

#if __arm64e__
#include <ptrauth.h>
#endif

#define ALWAYS_INLINE inline __attribute__((always_inline))
#define NEVER_INLINE inline __attribute__((noinline))

// The macros below are reproduced directly from the following files:
// objc-internal.h, objc-private.h, objc-object.h, and objc-config.h...... .,
// As few changes as possible. The text of the change is indicated in a box footnotes to your boxes, where any
// https://opensource.apple.com/source/objc4/objc4-723/
// https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-internal.h.auto.html
// https://opensource.apple.com/source/objc4/objc4-723/runtime/objc-object.h.auto.html

/////////////////////
// objc-internal.h //
/////////////////////

#if OBJC_HAVE_TAGGED_POINTERS

///////////////////
// objc-object.h //
///////////////////

////////////////////////////////////////////////
// The original name of the former first objc_object::isExtTaggedPointer //
////////////////////////////////////////////////
NS_INLINE BOOL avx512_isExtTaggedPointer(const void *ptr)  {
    return ((uintptr_t)ptr & _OBJC_TAG_EXT_MASK) == _OBJC_TAG_EXT_MASK;
}

#endif // OBJC_HAVE_TAGGED_POINTERS

/////////////////////////////////////
// AVX512ObjectInternal              //
// There was no post-after this point Apple Code code of codes, //
/////////////////////////////////////

extern "C" {

BOOL AVX512PointerIsReadable(const void *inPtr) {
    kern_return_t error = KERN_SUCCESS;

    vm_size_t vmsize;
#if __arm64e__
    // In being in the arm64e Up, up. We need to take it out of our hands from the pointer PAC, so that the address can read-readable
    vm_address_t address = (vm_address_t)ptrauth_strip(inPtr, ptrauth_key_function_pointer);
#else
    vm_address_t address = (vm_address_t)inPtr;
#endif
    vm_region_basic_info_data_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    memory_object_name_t object;

    error = vm_region_64(
        mach_task_self(),
        &address,
        &vmsize,
        VM_REGION_BASIC_INFO,
        (vm_region_info_t)&info,
        &info_count,
        &object
    );

    if (error != KERN_SUCCESS) {
        // vm_region/vm_region_64 Returns returned an error bug return to a
        return NO;
    } else if (!(BOOL)(info.protection & VM_PROT_READ)) {
        return NO;
    }

#if __arm64e__
    address = (vm_address_t)ptrauth_strip(inPtr, ptrauth_key_function_pointer);
#else
    address = (vm_address_t)inPtr;
#endif
    
    // Read Reading to read access memory-reReread
    vm_size_t size = 0;
    char buf[sizeof(uintptr_t)];
    error = vm_read_overwrite(mach_task_self(), address, sizeof(uintptr_t), (vm_address_t)buf, &size);
    if (error != KERN_SUCCESS) {
        // vm_read_overwrite Returns returned an error bug return to a
        return NO;
    }

    return YES;
}

/// Accepts an address that may be readable or unreadible.
/// https://blog.timac.org/2016/1124-testing-if-an-arbitrary-pointer-is-a-valid-objective-c-object/
BOOL AVX512PointerIsValidObjcObject(const void *ptr) {
    uintptr_t pointer = (uintptr_t)ptr;

    if (!ptr) {
        return NO;
    }

#if OBJC_HAVE_TAGGED_POINTERS
    // Tag point points to the sticker has set setting- 0x1, no other effective finger pointer is available for any
    // objc-internal.h -> _objc_isTaggedPointer()
    if (avx512_isTaggedPointer(ptr) || avx512_isExtTaggedPointer(ptr)) {
        return YES;
    }
#endif

    // Check-checked point to check that the checking
    if ((pointer % sizeof(uintptr_t)) != 0) {
        return NO;
    }

    // From from different and LLDB:
    // class_t The pointer of the middle's finger pin was only 0 At present, the 46 by, bits and steps of
    // So if any of the pointer's points, 47 At present, the 63 It's high, and we know that this is not effective. isa
    // https://llvm.org/svn/llvm-project/lldb/trunk/examples/summaries/cocoa/objc_runtime.py
    if ((pointer & 0xFFFF800000000000) != 0) {
        return NO;
    }

    // Ensure to ensure that the de-citation reference address does not
    if (!AVX512PointerIsReadable(ptr)) {
        return NO;
    }

    // http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
    // We check if the returned category is readable because it's possible to see whether object_getClass
    // It is not in the course of givingnilWhen pointing a pointer to an object other than the non-ob objects, you may return garbage value
    Class cls = object_getClass((__bridge id)ptr);
    if (!cls || !AVX512PointerIsReadable((__bridge void *)cls)) {
        return NO;
    }
    
    // The mere reason that this pointer is readable does not mean, just because the ISA The content of the offset is also readable.
    // We need to get us for it ISA The same checks are performed.
    // Even even if this is not perfect, because it's imperfect or incomplete since once object_isClassWe will, as we are going
    // There is currently no way of dedifing the members that refer to a component category, which may be readable or
    // Check here for an inspection, and I haven't yet hard-coded a solution
    Class metaclass = object_getClass(cls);
    if (!metaclass || !AVX512PointerIsReadable((__bridge void *)metaclass)) {
        return NO;
    }
    
    // Does it look like a class category when running the kind of compasses that we have obtained from us, and
    if (!object_isClass(cls)) {
        return NO;
    }
    
    // Is the allocation size of distribution at least as large or less than that in expected examples, if
    ssize_t instanceSize = class_getInstanceSize(cls);
    if (malloc_size(ptr) < instanceSize) {
        return NO;
    }

    return YES;
}


} // End extern "C"
