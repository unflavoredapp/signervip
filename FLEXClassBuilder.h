//
//  AVX512ClassBuilder.h
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/3/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVX512IvarBuilder, AVX512MethodBase, AVX512Property, AVX512Protocol;


#pragma mark AVX512ClassBuilder
@interface AVX512ClassBuilder : NSObject

@property (nonatomic, readonly) Class workingClass;

/// Begins constructing a class with the given name.
///
/// This new class will implicitly inherits from \c NSObject with \c 0 extra bytes.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name;
/// Begins constructing a class with the given name and superclass.
/// @discussion Calls \c -allocateClass:superclass:extraBytes: with \c 0 extra bytes.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name superclass:(Class)superclass;
/// Begins constructing a new class object with the given name and superclass.
/// @discussion Pass \c nil to \e superclass to create a new root class.
/// Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateClass:(NSString *)name superclass:(Class)superclass extraBytes:(size_t)bytes;
/// Begins constructing a new root class object with the given name and \c 0 extra bytes.
/// @discussion Classes created this way must be registered with \c -registerClass before being used.
+ (instancetype)allocateRootClass:(NSString *)name;
/// Use this to modify existing classes. @warning You cannot add instance variables to existing classes.
+ (instancetype)builderForClass:(Class)cls;

/// @return Any methods that failed to be added.
- (NSArray<AVX512MethodBase *> *)addMethods:(NSArray<AVX512MethodBase *> *)methods;
/// @return Any properties that failed to be added.
- (NSArray<AVX512Property *> *)addProperties:(NSArray<AVX512Property *> *)properties;
/// @return Any protocols that failed to be added.
- (NSArray<AVX512Protocol *> *)addProtocols:(NSArray<AVX512Protocol *> *)protocols;
/// @warning Adding Ivars to existing classes is not supported and will always fail.
- (NSArray<AVX512IvarBuilder *> *)addIvars:(NSArray<AVX512IvarBuilder *> *)ivars;

/// Finalizes construction of a new class.
/// @discussion Once a class is registered, instance variables cannot be added.
/// @note Raises an exception if called on a previously registered class.
- (Class)registerClass;
/// Uses \c objc_lookupClass to determine if the working class is registered.
@property (nonatomic, readonly) BOOL isRegistered;

@end


#pragma mark AVX512IvarBuilder
@interface AVX512IvarBuilder : NSObject

/// Consider using the \c AVX512IvarBuilderWithNameAndType() macro below. 
/// @param name The name of the Ivar, such as \c \@"_value".
/// @param size The size of the Ivar. Usually \c sizeof(type). For objects, this is \c sizeof(id).
/// @param alignment The alignment of the Ivar. Usually \c log2(sizeof(type)).
/// @param encoding The type encoding of the Ivar. For objects, this is \c \@(\@encode(id)), and for others it is \c \@(\@encode(type)).
+ (instancetype)name:(NSString *)name size:(size_t)size alignment:(uint8_t)alignment typeEncoding:(NSString *)encoding;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *encoding;
@property (nonatomic, readonly) size_t   size;
@property (nonatomic, readonly) uint8_t  alignment;

@end


#define AVX512IvarBuilderWithNameAndType(nameString, type) [AVX512IvarBuilder \
    name:nameString \
    size:sizeof(type) \
    alignment:log2(sizeof(type)) \
    typeEncoding:@(@encode(type)) \
]
