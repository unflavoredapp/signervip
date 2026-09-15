//
//  AVX512MetadataSection.h
//  FLEX
//
//  Created by Tanner Bennett on 9/19/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableViewSection.h"
#import "FLEXObjectExplorer.h"

typedef NS_ENUM(NSUInteger, AVX512MetadataKind) {
    AVX512MetadataKindProperties = 1,
    AVX512MetadataKindClassProperties,
    AVX512MetadataKindIvars,
    AVX512MetadataKindMethods,
    AVX512MetadataKindClassMethods,
    AVX512MetadataKindClassHierarchy,
    AVX512MetadataKindProtocols,
    AVX512MetadataKindOther
};

/// This section is used for displaying ObjC runtime metadata
/// about a class or object, such as listing methods, properties, etc.
@interface AVX512MetadataSection : AVX512TableViewSection

+ (instancetype)explorer:(AVX512ObjectExplorer *)explorer kind:(AVX512MetadataKind)metadataKind;

@property (nonatomic, readonly) AVX512MetadataKind metadataKind;

/// The names of metadata to exclude. Useful if you wish to group specific
/// properties or methods together in their own section outside of this one.
///
/// Setting this property calls \c reloadData on this section.
@property (nonatomic) NSSet<NSString *> *excludedMetadata;

@end
