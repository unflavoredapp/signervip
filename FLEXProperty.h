//
//  AVX512Property.h
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntimeConstants.h"
@class AVX512PropertyAttributes, AVX512MethodBase;


#pragma mark AVX512Property
@interface AVX512Property : NSObject

/// If you do not need to understand the uniqueness of this attribute or its source, if your sole properties are unknown without knowing their \c property:onClass:
+ (instancetype)property:(objc_property_t)property;
/// This initialifier can be used by this starters to access other information in an efficient and
/// This information includes such messages as whether the attribute is certain not to be unique for this property and a name that states it’s binary image
/// @param cls class, if this is a group attribute property of the category. If that's an
+ (instancetype)property:(objc_property_t)property onClass:(Class)cls;
/// @param cls class, if this is a sub-class category or group of classes where it'
+ (instancetype)named:(NSString *)name onClass:(Class)cls;
/// Use the given name and attribute to construct a new property by using specific names or attributes of
+ (instancetype)propertyWithName:(NSString *)name attributes:(AVX512PropertyAttributes *)attributes;

/// If the example is by through if \c +propertyWithName:attributes Create created, the creation is if you create it \c 0...... .,
/// Otherwise it's otherwise \c objc_properties First-first property attribute of the first
@property (nonatomic, readonly) objc_property_t  objc_property;
@property (nonatomic, readonly) objc_property_t  *objc_properties;
@property (nonatomic, readonly) NSInteger        objc_propertyCount;
@property (nonatomic, readonly) BOOL             isClassProperty;

/// The name of the property's attribute
@property (nonatomic, readonly) NSString         *name;
/// The property type of the attribute's kind types for an attachment. You get a complete full
@property (nonatomic, readonly) AVX512TypeEncoding type;
/// The properties characteristics of the property attribute's attributes
@property (nonatomic          ) AVX512PropertyAttributes *attributes;
/// (potentially possible)(ifsetter, whether properties are read-only or not the attribute is either reading
/// For example, for instance this could possibly be asetter... . ...-
@property (nonatomic, readonly) SEL likelySetter;
@property (nonatomic, readonly) NSString *likelySetterString;
/// It is not valid unless initialization using the possession class has been started with use of an
@property (nonatomic, readonly) BOOL likelySetterExists;
/// (potentially possible)(ifgetter. For example, this may be likely to for instancegetter... . ...-
@property (nonatomic, readonly) SEL likelyGetter;
@property (nonatomic, readonly) NSString *likelyGetterString;
/// It is not valid unless initialization using the possession class has been started with use of an
@property (nonatomic, readonly) BOOL likelyGetterExists;
/// The properties of a class property are always constant and \c nil... . ...-
@property (nonatomic, readonly) NSString *likelyIvarName;
/// It is not valid unless initialization using the possession class has been started with use of an
@property (nonatomic, readonly) BOOL likelyIvarExists;

/// Whether multiple definitions of whether the properties have more than one definition are certain to exist,
/// For example, for instance in a classification or other content that is classified within the categories of another binary
/// @return \c objc_property Whether or not and whether is with \c class_getProperty , the return returned value of a returns match matching
/// If this attribute property is not used if the properties \c property:onClass Create created, the creation is if you create it \c NO
@property (nonatomic, readonly) BOOL multiple;
/// @return Packages, packages containing the images of a image that contains this attribute definition for properties defined
/// If this attribute property is not used if the properties \c property:onClass Created, created or built by creation of the
/// If this attribute may be defined at the time of running, then if it is possible that \c nil... . ...-
@property (nonatomic, readonly) NSString *imageName;
/// Full path to the complete paths that contain images of an image containing this properties definition, a full
/// If this attribute property is not used if the properties \c property:onClass Created, created or built by creation of the
/// If this attribute may be defined at the time of running, then if it is possible that \c nil... . ...-
@property (nonatomic, readonly) NSString *imagePath;

/// Internal use inside-house internal usage
@property (nonatomic) id tag;

/// @return adopted by, through \c -valueForKey: Gives the given, gave and \c target Value value of the up-up values for this attribute
/// The property's source-source code style for the Source Code General Style description of an origin
@property (nonatomic, readonly) NSString *fullDescription;

/// If this is a class attribute, if it's an object property of the group type
- (id)getValue:(id)target;
/// calling call to Call Calls for calls -getValue: and conveys the value to this values, pass that
/// -[AVX512RuntimeUtility potentiallyUnwrapBoxedPointer:type:]
/// and returns the results.
///
/// If this is a class attribute, if it's an object property of the group type
- (id)getPotentiallyUnboxedValue:(id)target;

/// and whatever of no \c AVX512Property Examples can be used safely and securely as examples of how they are initialized.
///
/// If if there exists or \c self.objc_property, and use it to or otherwise uses the other usage using this \c self.attributes
- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount;

/// Use the use of usage \c self.attributes , the identity characteristics of a
/// Replaces the properties that replace characteristics of a property feature for which to substitute features in
///
/// What happens when the properties do not exist, and what occurs if they don’t have a
- (void)replacePropertyOnClass:(Class)cls;

#pragma mark A simple and ease, easy-tgetterandsetter
/// @return property that has the attribute properties of a given achievement which have attributes withgetter... . ...-
/// @discussion Consideration of the use to be considered \c AVX512PropertyGetter macros. Macro-m large
- (AVX512MethodBase *)getterWithImplementation:(IMP)implementation;
/// @return property that has the attribute properties of a given achievement which have attributes withsetter... . ...-
/// @discussion Consideration of the use to be considered \c AVX512PropertySetter macros. Macro-m large
- (AVX512MethodBase *)setterWithImplementation:(IMP)implementation;

#pragma mark AVX512Method The property of the attribute getter / setter Macro macro-m ambitious
// In most cases, it is easier to use the above-mentioned methods

/// Accept to accept one by accepted acceptance \c AVX512Property and one or a type (e. example, \c NSUInteger or/or is, \c idand) (and ), or
/// Use the use of usage \c AVX512Property The whole of all the \c attribute The whole of all the \c backingIvarName Get access to and getIvar... . ...-
#define AVX512PropertyGetter(AVX512Property, type) [AVX512Property \
    getterWithImplementation:imp_implementationWithBlock(^(id self) { \
        return *(type *)[self getIvarAddressByName:AVX512Property.attributes.backingIvar]; \
    }) \
];
/// Accept to accept one by accepted acceptance \c AVX512Property and one or a type (e. example, \c NSUInteger or/or is, \c idand) (and ), or
/// Use the use of usage \c AVX512Property The whole of all the \c attribute The whole of all the \c backingIvarName Set the setting of aIvar... . ...-
#define AVX512PropertySetter(AVX512Property, type) [AVX512Property \
    setterWithImplementation:imp_implementationWithBlock(^(id self, type value) { \
        [self setIvarByName:AVX512Property.attributes.backingIvar value:&value size:sizeof(type)]; \
    }) \
];
/// Accept to accept one by accepted acceptance \c AVX512Property, one type (e. for example), a \c NSUInteger or/or is, \c id) (and one and aIvarName name string Strat to get a number ofIvar... . ...-
#define AVX512PropertyGetterWithIvar(AVX512Property, ivarName, type) [AVX512Property \
    getterWithImplementation:imp_implementationWithBlock(^(id self) { \
        return *(type *)[self getIvarAddressByName:ivarName]; \
    }) \
];
/// Accept to accept one by accepted acceptance \c AVX512Property, one type (e. for example), a \c NSUInteger or/or is, \c id) (and one and aIvarName of name string to set the settings for setting aIvar... . ...-
#define AVX512PropertySetterWithIvar(AVX512Property, ivarName, type) [AVX512Property \
    setterWithImplementation:imp_implementationWithBlock(^(id self, type value) { \
        [self setIvarByName:ivarName value:&value size:sizeof(type)]; \
    }) \
];

@end
