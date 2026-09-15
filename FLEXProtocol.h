//
//  AVX512Protocol.h
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntimeConstants.h"
@class AVX512Property, AVX512MethodDescription;

NS_ASSUME_NONNULL_BEGIN

#pragma mark AVX512Protocol
@interface AVX512Protocol : NSObject

/// All agreements registered at running run-time and all protocols that
+ (NSArray<AVX512Protocol *> *)allProtocols;
+ (instancetype)protocol:(Protocol *)protocol;

/// Bottom protocol data structure.
@property (nonatomic, readonly) Protocol *objc_protocol;

/// The name of the agreement. Agreement is
@property (nonatomic, readonly) NSString *name;
/// The necessary method (if any) of the agreement is required for an agreed protocol to be used, ifgetterandsettermethod. The methodology of the approach
@property (nonatomic, readonly) NSArray<AVX512MethodDescription *> *requiredMethods;
/// The optional method (if any) of the agreement is an option by protocol, if available. This includes attributesgetterandsettermethod. The methodology of the approach
@property (nonatomic, readonly) NSArray<AVX512MethodDescription *> *optionalMethods;
/// All agreements (if if any) upon which the agreement is based are all
@property (nonatomic, readonly) NSArray<AVX512Protocol *> *protocols;
/// Complete path to the full paths, complete pathways of mirrors that contain images defined by this protocol
/// If this agreement may be defined at the time of operation if it is likely to have been \c nil... . ...-
@property (nonatomic, readonly, nullable) NSString *imagePath;

/// The attributes (if if any) in an agreement are the properties of aiOS 10+is the Tops up of first \c nil
@property (nonatomic, readonly, nullable) NSArray<AVX512Property *> *properties API_DEPRECATED("Use a more specific accesser below for the following, and", ios(2.0, 10.0));

/// The requisite attributes (if available if any) that are required to be properties
@property (nonatomic, readonly) NSArray<AVX512Property *> *requiredProperties API_AVAILABLE(ios(10.0));
/// optional attributes (if if any) of the agreement are options that can be selected properties
@property (nonatomic, readonly) NSArray<AVX512Property *> *optionalProperties API_AVAILABLE(ios(10.0));

/// Internal use inside-house internal usage
@property (nonatomic) id tag;

/// Don't ever do \c -conformsToProtocol: Conf confusion, which refers to the current situation at present
/// \c AVX512Protocol An example, not an instance of the bottom floor instead \c Protocol object of the objects. Object to
- (BOOL)conformsTo:(Protocol *)protocol;

@end


#pragma mark A methodological description of methodology describe method
@interface AVX512MethodDescription : NSObject

+ (instancetype)description:(struct objc_method_description)description;
+ (instancetype)description:(struct objc_method_description)description instance:(BOOL)isInstance;

/// Bottom bottom methods describe the underlying approach to describing data structure of
@property (nonatomic, readonly) struct objc_method_description objc_description;
/// method to select the choicer of methods. The
@property (nonatomic, readonly) SEL selector;
/// , method. The type-type encoding of the
@property (nonatomic, readonly) NSString *typeEncoding;
/// method. The type of returned return to the approach(
@property (nonatomic, readonly) AVX512TypeEncoding returnType;
/// \c YES If this is an ex example approach, if it\c NO If a class-based method, or if the \c nil If if it has not been designated
@property (nonatomic, readonly) NSNumber *instance;
@end

NS_ASSUME_NONNULL_END
