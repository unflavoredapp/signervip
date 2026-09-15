//
//  AVX512ProtocolBuilder.h
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 7/4/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVX512Property, AVX512Protocol, Protocol;

@interface AVX512ProtocolBuilder : NSObject

/// Starts to build a new agreement with the given name. Starting construction of an additional protocol
/// @discussion You must be required to use your
/// \c registerProtocol The method by which you register the agreement is used to use it.
+ (instancetype)allocateProtocol:(NSString *)name;

/// Adds properties to the protocol. The property is added
/// @param property The properties to be added. Properties that you want
/// @param isRequired Whether the attribute is necessary to achieve an agreement. Is that
- (void)addProperty:(AVX512Property *)property isRequired:(BOOL)isRequired;
/// Adds a method to the agreement.
/// @param selector Selector selects the method to be added. Choose
/// @param typeEncoding The type of method to be added for the methods that you
/// @param isRequired Is this approach necessary to achieve an agreement? This method is
/// @param isInstanceMethod \c YES If if the method is by way of an illustrative\c NO If the methods are sub-category methodologies
- (void)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
       isRequired:(BOOL)isRequired
 isInstanceMethod:(BOOL)isInstanceMethod;
/// The reception agreement is made in conformity with the given agreements.
- (void)addProtocol:(Protocol *)protocol;

/// Registers and returns the reception protocol that was previously being constructed. The receipt agreement, which
- (AVX512Protocol *)registerProtocol;
/// Whether the agreement is still under construction or registered in a build-up building. Are
@property (nonatomic, readonly) BOOL isRegistered;

@end
