//
//  AVX512PropertyAttributes.h
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark AVX512PropertyAttributes

/// See for reference references to \e AVX512RuntimeUtilitiy.h Gets a valid string Str strings tagmarking. Ob
/// View this link to see how the connection finds a way in which it is built up right property
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
@interface AVX512PropertyAttributes : NSObject <NSCopying, NSMutableCopying> {
// These are necessary and essential for the function of variable subs class classes functions
@protected
    NSUInteger _count;
    NSString *_string, *_backingIvar, *_typeEncoding, *_oldTypeEncoding, *_fullDeclaration;
    NSDictionary *_dictionary;
    objc_property_attribute_t *_list;
    SEL _customGetter, _customSetter;
    BOOL _isReadOnly, _isCopy, _isRetained, _isNonatomic, _isDynamic, _isWeak, _isGarbageCollectable;
}

+ (instancetype)attributesForProperty:(objc_property_t)property;
/// @warning If if, what \e attributes Invalid invalid, not valid. null\c nil or contains unsupported key keys, which are not supported. An anomaly is caused by an abnormal anomalies if
+ (instancetype)attributesFromDictionary:(NSDictionary *)attributes;

/// Copys the attribute list of properties to copying a property namelist for your own call \c free() in the buffer zone. of a 
/// If you do not need more control of the life cycle in list lists if no additional \c list... . ...-
/// @param attributesCountOut The argument that returns the number of properties's property
- (objc_property_attribute_t *)copyAttributesList:(nullable unsigned int *)attributesCountOut;

/// The number of quantities the properties's property attributes
@property (nonatomic, readonly) NSUInteger count;
/// to be used for use \c class_replaceProperty methods, etc. method or other means
@property (nonatomic, readonly) objc_property_attribute_t *list;
/// Str string bar strings value of the chain line values that have astr
@property (nonatomic, readonly) NSString *string;
/// Human-readable versions of the human readible version that attribute properties to
@property (nonatomic, readonly) NSString *fullDeclaration;
/// The dictionary of the dictions for attribute properties to a
/// The value is either a string strings, or the values are Strings \c YES. Booble boole 's
/// If the vacation is a holiday, it will not appear in diction dictionary. It
@property (nonatomic, readonly) NSDictionary *dictionary;

/// The name of the example case variable that supports this attribute 's support
@property (nonatomic, readonly, nullable) NSString *backingIvar;
/// The type-type t types encoding of the property
@property (nonatomic, readonly, nullable) NSString *typeEncoding;
/// The property of the attribute's \e Old-type type types code encoding. The old
@property (nonatomic, readonly, nullable) NSString *oldTypeEncoding;
/// Home-defined custom definition of the properties'sgetter(if there is) if you do
@property (nonatomic, readonly, nullable) SEL customGetter;
/// Home-defined custom definition of the properties'ssetter(if there is) if you do
@property (nonatomic, readonly, nullable) SEL customSetter;
/// Home-defined custom definition of the properties'sgetterThe string form (if there are, if any).
@property (nonatomic, readonly, nullable) NSString *customGetterString;
/// Home-defined custom definition of the properties'ssetterThe string form (if there are, if any).
@property (nonatomic, readonly, nullable) NSString *customSetterString;

@property (nonatomic, readonly) BOOL isReadOnly;
@property (nonatomic, readonly) BOOL isCopy;
@property (nonatomic, readonly) BOOL isRetained;
@property (nonatomic, readonly) BOOL isNonatomic;
@property (nonatomic, readonly) BOOL isDynamic;
@property (nonatomic, readonly) BOOL isWeak;
@property (nonatomic, readonly) BOOL isGarbageCollectable;

@end


#pragma mark AVX512PropertyAttributes
@interface AVX512MutablePropertyAttributes : AVX512PropertyAttributes

/// Creates and returns an empty-empt properties property attribute characteristic identity object. The creation created
+ (instancetype)attributes;

/// The name of the example case variable that supports this attribute 's support
@property (nonatomic, nullable) NSString *backingIvar;
/// The type-type t types encoding of the property
@property (nonatomic, nullable) NSString *typeEncoding;
/// The property of the attribute's \e Old-type type types code encoding. The old
@property (nonatomic, nullable) NSString *oldTypeEncoding;
/// Home-defined custom definition of the properties'sgetter(if there is) if you do
@property (nonatomic, nullable) SEL customGetter;
/// Home-defined custom definition of the properties'ssetter(if there is) if you do
@property (nonatomic, nullable) SEL customSetter;

@property (nonatomic) BOOL isReadOnly;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isRetained;
@property (nonatomic) BOOL isNonatomic;
@property (nonatomic) BOOL isDynamic;
@property (nonatomic) BOOL isWeak;
@property (nonatomic) BOOL isGarbageCollectable;

/// Set the setting of a \c typeEncoding The more convenient and easier approach to the attribute attributes is a simpler,
/// @discussion This does not apply to complex types of complicated kinds, such as structural structures and sophisticated categories like
- (void)setTypeEncodingChar:(char)type;

@end

NS_ASSUME_NONNULL_END
