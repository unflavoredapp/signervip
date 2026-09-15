//
//  AVX512CollectionContentSection.m
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXCollectionContentSection.h"
#import "FLEXUtility.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXSubtitleTableViewCell.h"
#import "FLEXTableView.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXDefaultEditorViewController.h"

typedef NS_ENUM(NSUInteger, AVX512CollectionType) {
    AVX512UnsupportedCollection,
    AVX512OrderedCollection,
    AVX512UnorderedCollection,
    AVX512KeyedCollection
};

@interface NSArray (AVX512Collection) <AVX512Collection> @end
@interface NSSet (AVX512Collection) <AVX512Collection> @end
@interface NSOrderedSet (AVX512Collection) <AVX512Collection> @end
@interface NSDictionary (AVX512Collection) <AVX512Collection> @end

@interface NSMutableArray (AVX512MutableCollection) <AVX512MutableCollection> @end
@interface NSMutableSet (AVX512MutableCollection) <AVX512MutableCollection> @end
@interface NSMutableOrderedSet (AVX512MutableCollection) <AVX512MutableCollection> @end
@interface NSMutableDictionary (AVX512MutableCollection) <AVX512MutableCollection>
- (void)filterUsingPredicate:(NSPredicate *)predicate;
@end

@interface AVX512CollectionContentSection ()
/// From all from the \c collectionFuture or/or is, \c collection To generate the generation of
@property (nonatomic, copy) id<AVX512Collection> cachedCollection;
/// To show, the normal static state at a collection of
@property (nonatomic, readonly) id<AVX512Collection> collection;
/// A collection that may change over time with a possible combination of potential changes in times, can call for new data
@property (nonatomic, readonly) AVX512CollectionContentFuture collectionFuture;
@property (nonatomic, readonly) AVX512CollectionType collectionType;
@property (nonatomic, readonly) BOOL isMutable;
@end

@implementation AVX512CollectionContentSection
@synthesize filterText = _filterText;

#pragma mark Initial initialisation to start-in

+ (instancetype)forObject:(id)object {
    return [self forCollection:object];
}

+ (id)forCollection:(id<AVX512Collection>)collection {
    AVX512CollectionContentSection *section = [self new];
    section->_collectionType = [self typeForCollection:collection];
    section->_collection = collection;
    section.cachedCollection = collection;
    section->_isMutable = [collection respondsToSelector:@selector(filterUsingPredicate:)];
    return section;
}

+ (id)forReusableFuture:(AVX512CollectionContentFuture)collectionFuture {
    AVX512CollectionContentSection *section = [self new];
    section->_collectionFuture = collectionFuture;
    section.cachedCollection = (id<AVX512Collection>)collectionFuture(section);
    section->_collectionType = [self typeForCollection:section.cachedCollection];
    section->_isMutable = [section->_cachedCollection respondsToSelector:@selector(filterUsingPredicate:)];
    return section;
}


#pragma mark - Miscellaneous, miscellaneous and other

+ (AVX512CollectionType)typeForCollection:(id<AVX512Collection>)collection {
    // The order of the sequence here is important because itNSDictionaryIt's key-valued but it also responds toallObjects
    if ([collection respondsToSelector:@selector(objectAtIndex:)]) {
        return AVX512OrderedCollection;
    }
    if ([collection respondsToSelector:@selector(objectForKey:)]) {
        return AVX512KeyedCollection;
    }
    if ([collection respondsToSelector:@selector(allObjects)]) {
        return AVX512UnorderedCollection;
    }

    [NSException raise:NSInvalidArgumentException
                format:@"A given collection has not been correctly followed in the proper manner of itsAVX512CollectionAgreement to and agreement between"];
    return AVX512UnsupportedCollection;
}

/// row heading under the title
/// - In an orderly and organized manner,: Index indexes to the
/// - In a series, un-s: Object object objects to the
/// - The key pool of set-key values: Key key keys to the
- (NSString *)titleForRow:(NSInteger)row {
    switch (self.collectionType) {
        case AVX512OrderedCollection:
            if (!self.hideOrderIndexes) {
                return @(row).stringValue;
            }
            // Fall-through
        case AVX512UnorderedCollection:
            return [self describe:[self objectForRow:row]];
        case AVX512KeyedCollection:
            return [self describe:self.cachedCollection.allKeys[row]];

        case AVX512UnsupportedCollection:
            return nil;
    }
}

/// under subtitled by subhead title
/// - In an orderly and organized manner,: Object object objects to the
/// - In a series, un-s: No, no nothing
/// - The key pool of set-key values: Value value of the values
- (NSString *)subtitleForRow:(NSInteger)row {
    switch (self.collectionType) {
        case AVX512OrderedCollection:
            if (!self.hideOrderIndexes) {
                nil;
            }
            // Fall-through
        case AVX512KeyedCollection:
            return [self describe:[self objectForRow:row]];
        case AVX512UnorderedCollection:
            return nil;

        case AVX512UnsupportedCollection:
            return nil;
    }
}

- (NSString *)describe:(id)object {
    return [AVX512RuntimeUtility summaryForObject:object];
}

- (id)objectForRow:(NSInteger)row {
    switch (self.collectionType) {
        case AVX512OrderedCollection:
            return self.cachedCollection[row];
        case AVX512UnorderedCollection:
            return self.cachedCollection.allObjects[row];
        case AVX512KeyedCollection:
            return self.cachedCollection[self.cachedCollection.allKeys[row]];

        case AVX512UnsupportedCollection:
            return nil;
    }
}

- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row {
    return UITableViewCellAccessoryDisclosureIndicator;
//    return self.isMutable ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
}


#pragma mark - Re-rewn rewritten

- (NSString *)title {
    if (!self.hideSectionTitle) {
        if (self.customTitle) {
            return self.customTitle;
        }
        
        return AVX512PluralString(self.cachedCollection.count, @"Entry entry entries in the", @"Entry entry entries in the");
    }
    
    return nil;
}

- (NSInteger)numberOfRows {
    return self.cachedCollection.count;
}

- (void)setFilterText:(NSString *)filterText {
    super.filterText = filterText;
    
    if (filterText.length) {
        BOOL (^matcher)(id, id) = self.customFilter ?: ^BOOL(NSString *query, id obj) {
            return [[self describe:obj] localizedCaseInsensitiveContainsString:query];
        };
        
        NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return matcher(filterText, obj);
        }];
        
        id<AVX512MutableCollection> tmp = self.cachedCollection.mutableCopy;
        [tmp filterUsingPredicate:filter];
        self.cachedCollection = tmp;
    } else {
        self.cachedCollection = self.collection ?: (id<AVX512Collection>)self.collectionFuture(self);
    }
}

- (void)reloadData {
    if (self.collectionFuture) {
        self.cachedCollection = (id<AVX512Collection>)self.collectionFuture(self);
    } else {
        self.cachedCollection = self.collection.copy;
    }
}

- (BOOL)canSelectRow:(NSInteger)row {
    return YES;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return [AVX512ObjectExplorerFactory explorerViewControllerForObject:[self objectForRow:row]];
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    return kAVX512DetailCell;
}

- (void)configureCell:(__kindof AVX512TableViewCell *)cell forRow:(NSInteger)row {
    cell.titleLabel.text = [self titleForRow:row];
    cell.subtitleLabel.text = [self subtitleForRow:row];
    cell.accessoryType = [self accessoryTypeForRow:row];
}

@end


#pragma mark - NSMutableDictionary

@implementation NSMutableDictionary (AVX512MutableCollection)

- (void)filterUsingPredicate:(NSPredicate *)predicate {
    id test = ^BOOL(id key, NSUInteger idx, BOOL *stop) {
        if ([predicate evaluateWithObject:key]) {
            return NO;
        }
        
        return ![predicate evaluateWithObject:self[key]];
    };
    
    NSArray *keys = self.allKeys;
    NSIndexSet *remove = [keys indexesOfObjectsPassingTest:test];
    
    [self removeObjectsForKeys:[keys objectsAtIndexes:remove]];
}

@end
