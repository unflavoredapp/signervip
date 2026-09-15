//
//  AVX512ObjectRef.h
//  FLEX
//
//  Created by Tanner Bennett on 7/24/18.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVX512ObjectRef : NSObject

/// A reference to an object does not affect the life-cycle of a given subject without affecting its lifetime, nor do you generate
+ (instancetype)unretained:(__unsafe_unretained id)object;
+ (instancetype)unretained:(__unsafe_unretained id)object ivar:(NSString *)ivarName;

/// References an object to and controls the life cycle of a given objects,
+ (instancetype)retained:(id)object;
+ (instancetype)retained:(id)object ivar:(NSString *)ivarName;

/// To refer to an object and select with some conditional choice whether or not it should be retained.
+ (instancetype)referencing:(__unsafe_unretained id)object retained:(BOOL)retain;
+ (instancetype)referencing:(__unsafe_unretained id)object ivar:(NSString *)ivarName retained:(BOOL)retain;

+ (NSArray<AVX512ObjectRef *> *)referencingAll:(NSArray *)objects retained:(BOOL)retain;
/// Category does not have a summary of the category. The reference is merely to name
+ (NSArray<AVX512ObjectRef *> *)referencingClasses:(NSArray<Class> *)classes;

/// e. for example,"NSString 0x1d4085d0"or/or is,"NSLayoutConstraint _object"
@property (nonatomic, readonly) NSString *reference;
/// For example examples, this is the case-[AVX512RuntimeUtility summaryForObject:]the outcome of outcomes and
/// For categories, there is no summary.
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly, unsafe_unretained) id object;

/// If the object to which reference was invoked has not been retained, if it is maintained
- (void)retainObject;
/// If the object to which reference is invoked has been retained, release it if
- (void)releaseObject;

@end
