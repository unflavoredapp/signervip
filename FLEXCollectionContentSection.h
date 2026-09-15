//
//  AVX512CollectionContentSection.h
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableViewSection.h"
#import "FLEXObjectInfoSection.h"
@class AVX512CollectionContentSection, AVX512TableViewCell;
@protocol AVX512Collection, AVX512MutableCollection;

/// Any foundation collection implicitly conforms to AVX512Collection.
/// This future should return one. We don't explicitly put AVX512Collection
/// here because making generic collections conform to AVX512Collection breaks
/// compile-time features of generic arrays, such as \c someArray[0].property
typedef id<NSObject, NSFastEnumeration /* AVX512Collection */>(^AVX512CollectionContentFuture)(__kindof AVX512CollectionContentSection *section);

#pragma mark Collection
/// A protocol that enables \c AVX512CollectionContentSection to operate on any arbitrary collection.
/// \c NSArray, \c NSDictionary, \c NSSet, and \c NSOrderedSet all conform to this protocol.
@protocol AVX512Collection <NSObject, NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;

- (id)copy;
- (id)mutableCopy;

@optional

/// Unordered, unkeyed collections must implement this
@property (nonatomic, readonly) NSArray *allObjects;
/// Keyed collections must implement this and \c objectForKeyedSubscript:
@property (nonatomic, readonly) NSArray *allKeys;

/// Ordered, indexed collections must implement this.
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
/// Keyed, unordered collections must implement this and \c allKeys
- (id)objectForKeyedSubscript:(id)idx;

@end

@protocol AVX512MutableCollection <AVX512Collection>
- (void)filterUsingPredicate:(NSPredicate *)predicate;
@end


#pragma mark - AVX512CollectionContentSection
/// A custom section for viewing collection elements.
///
/// Tapping on a row pushes an object explorer for that element.
@interface AVX512CollectionContentSection<__covariant ObjectType> : AVX512TableViewSection <AVX512ObjectInfoSection> {
    @protected
    /// Unused if initialized with a future
    id<AVX512Collection> _collection;
    /// Unused if initialized with a collection
    AVX512CollectionContentFuture _collectionFuture;
    /// The filtered collection from \c _collection or \c _collectionFuture
    id<AVX512Collection> _cachedCollection;
}

+ (instancetype)forCollection:(id)collection;
/// The future given should be safe to call more than once.
/// The result of calling this future multiple times may yield
/// different results each time if the data is changing by nature.
+ (instancetype)forReusableFuture:(AVX512CollectionContentFuture)collectionFuture;

/// Defaults to \c NO
@property (nonatomic) BOOL hideSectionTitle;
/// Defaults to \c nil
@property (nonatomic, copy) NSString *customTitle;
/// Defaults to \c NO
///
/// Settings this to \c NO will not display the element index for ordered collections.
/// This property only applies to \c NSArray or \c NSOrderedSet and their subclasses.
@property (nonatomic) BOOL hideOrderIndexes;

/// Set this property to provide a custom filter matcher.
///
/// By default, the collection will filter on the title and subtitle of the row.
/// So if you don't ever call \c configureCell: for example, you will need to set
/// this property so that your filter logic will match how you're setting up the cell. 
@property (nonatomic) BOOL (^customFilter)(NSString *filterText, ObjectType element);

/// Get the object in the collection associated with the given row.
/// For dictionaries, this returns the value, not the key.
- (ObjectType)objectForRow:(NSInteger)row;

/// Subclasses may override.
- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row;

@end
