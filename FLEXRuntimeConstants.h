//
//  AVX512RuntimeConstants.h
//  FLEX
//
//  Created by Tanner on 3/11/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define AVX512EncodeClass(class) ("@\"" #class "\"")
#define AVX512EncodeObject(obj) (obj ? [NSString stringWithFormat:@"@\"%@\"", [obj class]].UTF8String : @encode(id))

// Arguments 0 and 1 are self and _cmd always
extern const unsigned int kAVX512NumberOfImplicitArgs;

// See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
extern NSString *const kAVX512PropertyAttributeKeyTypeEncoding;
extern NSString *const kAVX512PropertyAttributeKeyBackingIvarName;
extern NSString *const kAVX512PropertyAttributeKeyReadOnly;
extern NSString *const kAVX512PropertyAttributeKeyCopy;
extern NSString *const kAVX512PropertyAttributeKeyRetain;
extern NSString *const kAVX512PropertyAttributeKeyNonAtomic;
extern NSString *const kAVX512PropertyAttributeKeyCustomGetter;
extern NSString *const kAVX512PropertyAttributeKeyCustomSetter;
extern NSString *const kAVX512PropertyAttributeKeyDynamic;
extern NSString *const kAVX512PropertyAttributeKeyWeak;
extern NSString *const kAVX512PropertyAttributeKeyGarbageCollectable;
extern NSString *const kAVX512PropertyAttributeKeyOldStyleTypeEncoding;

typedef NS_ENUM(NSUInteger, AVX512PropertyAttribute) {
    AVX512PropertyAttributeTypeEncoding       = 'T',
    AVX512PropertyAttributeBackingIvarName    = 'V',
    AVX512PropertyAttributeCopy               = 'C',
    AVX512PropertyAttributeCustomGetter       = 'G',
    AVX512PropertyAttributeCustomSetter       = 'S',
    AVX512PropertyAttributeDynamic            = 'D',
    AVX512PropertyAttributeGarbageCollectible = 'P',
    AVX512PropertyAttributeNonAtomic          = 'N',
    AVX512PropertyAttributeOldTypeEncoding    = 't',
    AVX512PropertyAttributeReadOnly           = 'R',
    AVX512PropertyAttributeRetain             = '&',
    AVX512PropertyAttributeWeak               = 'W'
}; //NS_SWIFT_NAME(FLEX.PropertyAttribute);

typedef NS_ENUM(char, AVX512TypeEncoding) {
    AVX512TypeEncodingNull             = '\0',
    AVX512TypeEncodingUnknown          = '?',
    AVX512TypeEncodingChar             = 'c',
    AVX512TypeEncodingInt              = 'i',
    AVX512TypeEncodingShort            = 's',
    AVX512TypeEncodingLong             = 'l',
    AVX512TypeEncodingLongLong         = 'q',
    AVX512TypeEncodingUnsignedChar     = 'C',
    AVX512TypeEncodingUnsignedInt      = 'I',
    AVX512TypeEncodingUnsignedShort    = 'S',
    AVX512TypeEncodingUnsignedLong     = 'L',
    AVX512TypeEncodingUnsignedLongLong = 'Q',
    AVX512TypeEncodingFloat            = 'f',
    AVX512TypeEncodingDouble           = 'd',
    AVX512TypeEncodingLongDouble       = 'D',
    AVX512TypeEncodingCBool            = 'B',
    AVX512TypeEncodingVoid             = 'v',
    AVX512TypeEncodingCString          = '*',
    AVX512TypeEncodingObjcObject       = '@',
    AVX512TypeEncodingObjcClass        = '#',
    AVX512TypeEncodingSelector         = ':',
    AVX512TypeEncodingArrayBegin       = '[',
    AVX512TypeEncodingArrayEnd         = ']',
    AVX512TypeEncodingStructBegin      = '{',
    AVX512TypeEncodingStructEnd        = '}',
    AVX512TypeEncodingUnionBegin       = '(',
    AVX512TypeEncodingUnionEnd         = ')',
    AVX512TypeEncodingQuote            = '\"',
    AVX512TypeEncodingBitField         = 'b',
    AVX512TypeEncodingPointer          = '^',
    AVX512TypeEncodingConst            = 'r'
}; //NS_SWIFT_NAME(FLEX.TypeEncoding);
