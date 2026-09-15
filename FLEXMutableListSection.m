//
//  AVX512MutableListSection.m
//  FLEX
//
//  Created by Tanner on 3/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXMutableListSection.h"
#import "FLEXMacros.h"

@interface AVX512MutableListSection ()
@property (nonatomic, readonly) AVX512MutableListCellForElement configureCell;
@end

@implementation AVX512MutableListSection
@synthesize cellRegistrationMapping = _cellRegistrationMapping;

#pragma mark - Initialization

+ (instancetype)list:(NSArray *)list
   cellConfiguration:(AVX512MutableListCellForElement)cellConfig
       filterMatcher:(BOOL(^)(NSString *, id))filterBlock {
    return [[self alloc] initWithList:list configurationBlock:cellConfig filterMatcher:filterBlock];
}

- (id)initWithList:(NSArray *)list
configurationBlock:(AVX512MutableListCellForElement)cellConfig
     filterMatcher:(BOOL(^)(NSString *, id))filterBlock {
    self = [super init];
    if (self) {
        _configureCell = cellConfig;

        self.list = list.mutableCopy;
        self.customFilter = filterBlock;
        self.hideSectionTitle = YES;
    }

    return self;
}


#pragma mark - Public

- (NSArray *)list {
    return (id)_collection;
}

- (void)setList:(NSMutableArray *)list {
    NSParameterAssert(list);
    _collection = (id)list;

    [self reloadData];
}

- (NSArray *)filteredList {
    return (id)_cachedCollection;
}

- (void)mutate:(void (^)(NSMutableArray *))block {
    block((NSMutableArray *)_collection);
    [self reloadData];
}


#pragma mark - Overrides

- (void)setCustomTitle:(NSString *)customTitle {
    super.customTitle = customTitle;
    self.hideSectionTitle = customTitle == nil;
}

- (BOOL)canSelectRow:(NSInteger)row {
    return self.selectionHandler != nil;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return nil;
}

- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    if (self.selectionHandler) { weakify(self)
        return ^(UIViewController *host) { strongify(self)
            if (self) {
                self.selectionHandler(host, self.filteredList[row]);
            }
        };
    }

    return nil;
}

- (void)configureCell:(__kindof UITableViewCell *)cell forRow:(NSInteger)row {
    self.configureCell(cell, self.filteredList[row], row);
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    if (self.cellRegistrationMapping.count) {
        return self.cellRegistrationMapping.allKeys.firstObject;
    }

    return [super reuseIdentifierForRow:row];
}

- (void)setCellRegistrationMapping:(NSDictionary<NSString *,Class> *)cellRegistrationMapping {
    NSParameterAssert(cellRegistrationMapping.count <= 1);
    _cellRegistrationMapping = cellRegistrationMapping;
}

@end
