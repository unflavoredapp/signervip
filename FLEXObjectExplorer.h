//
//  AVX512ObjectExplorer.h
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntime+UIKitHelpers.h"

/// Carries state about the current user defaults settings
@interface AVX512ObjectExplorerDefaults : NSObject
+ (instancetype)canEdit:(BOOL)editable wantsPreviews:(BOOL)showPreviews;

/// Only \c YES for properties and ivars
@property (nonatomic, readonly) BOOL isEditable;
/// Only affects properties and ivars
@property (nonatomic, readonly) BOOL wantsDynamicPreviews;
@end

@interface AVX512ObjectExplorer : NSObject

+ (instancetype)forObject:(id)objectOrClass;

+ (void)configureDefaultsForItems:(NSArray<id<AVX512ObjectExplorerItem>> *)items;

@property (nonatomic, readonly) id object;
/// Subclasses can override to provide a more useful description
@property (nonatomic, readonly) NSString *objectDescription;

/// @return \c YES if \c object is an instance of a class,
/// or \c NO if \c object is a class itself.
@property (nonatomic, readonly) BOOL objectIsInstance;

/// An index into the `classHierarchy` array.
///
/// This property determines which set of data comes out of the metadata arrays below
/// For example, \c properties contains the properties of the selected class scope,
/// while \c allProperties is an array of arrays where each array is a set of
/// properties for a class in the class hierarchy of the current object.
@property (nonatomic) NSInteger classScope;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Property *> *> *allProperties;
@property (nonatomic, readonly) NSArray<AVX512Property *> *properties;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Property *> *> *allClassProperties;
@property (nonatomic, readonly) NSArray<AVX512Property *> *classProperties;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Ivar *> *> *allIvars;
@property (nonatomic, readonly) NSArray<AVX512Ivar *> *ivars;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Method *> *> *allMethods;
@property (nonatomic, readonly) NSArray<AVX512Method *> *methods;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Method *> *> *allClassMethods;
@property (nonatomic, readonly) NSArray<AVX512Method *> *classMethods;

@property (nonatomic, readonly) NSArray<Class> *classHierarchyClasses;
@property (nonatomic, readonly) NSArray<AVX512StaticMetadata *> *classHierarchy;

@property (nonatomic, readonly) NSArray<NSArray<AVX512Protocol *> *> *allConformedProtocols;
@property (nonatomic, readonly) NSArray<AVX512Protocol *> *conformedProtocols;

@property (nonatomic, readonly) NSArray<AVX512StaticMetadata *> *allInstanceSizes;
@property (nonatomic, readonly) AVX512StaticMetadata *instanceSize;

@property (nonatomic, readonly) NSArray<AVX512StaticMetadata *> *allImageNames;
@property (nonatomic, readonly) AVX512StaticMetadata *imageName;

- (void)reloadMetadata;
- (void)reloadClassHierarchy;

@end


@interface AVX512ObjectExplorer (Reflex)

/// Do not enable this property manually; Reflex will flip the switch when it is loaded.
/// If you wish, you may \e disable it manually.
@property (nonatomic, class) BOOL reflexAvailable;

@end
