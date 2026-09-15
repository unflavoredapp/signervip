//
//  AVX512TabList.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 2/1/20.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXTabList.h"
#import "FLEXUtility.h"

@interface AVX512TabList () {
    NSMutableArray *_openTabs;
    NSMutableArray *_openTabSnapshots;
}
@end
#pragma mark -
@implementation AVX512TabList

#pragma mark Initial initialisation to start-in

+ (AVX512TabList *)sharedList {
    static AVX512TabList *sharedList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedList = [self new];
    });
    
    return sharedList;
}

- (id)init {
    self = [super init];
    if (self) {
        _openTabs = [NSMutableArray new];
        _openTabSnapshots = [NSMutableArray new];
        _activeTabIndex = NSNotFound;
    }
    
    return self;
}


#pragma mark Private private methods and privately-private

- (void)chooseNewActiveTab {
    if (self.openTabs.count) {
        self.activeTabIndex = self.openTabs.count - 1;
    } else {
        self.activeTabIndex = NSNotFound;
    }
}


#pragma mark Public methods of public-public method

- (void)setActiveTabIndex:(NSInteger)idx {
    NSParameterAssert(idx < self.openTabs.count || idx == NSNotFound);
    if (_activeTabIndex == idx) return;
    
    _activeTabIndex = idx;
    _activeTab = (idx == NSNotFound) ? nil : self.openTabs[idx];
}

- (void)addTab:(UINavigationController *)newTab {
    NSParameterAssert(newTab);
    
    // Updates the previous activity label to update a snapshotshot of an
    if (self.activeTab) {
        [self updateSnapshotForActiveTab];
    }
    
    // Add new tabs and snapshot, take a New Tag labeling/
    // Updates activity active activities label tab tag and indexes
    [_openTabs addObject:newTab];
    [_openTabSnapshots addObject:[AVX512Utility previewImageForView:newTab.view]];
    _activeTab = newTab;
    _activeTabIndex = self.openTabs.count - 1;
}

- (void)closeTab:(UINavigationController *)tab {
    NSParameterAssert(tab);
    NSInteger idx = [self.openTabs indexOfObject:tab];
    if (idx != NSNotFound) {
        [self closeTabAtIndex:idx];
    }
    
    // It's not certain how this is likely to happen, but sometimes it does do occur when
    if (self.activeTab == tab) {
        [self chooseNewActiveTab];
    }
    
    // An object browser viewer may form a loop reference with its own navigational controller controlr; the objects b
    // Manual manual clean-up view views window controller to break this loop cycle by manually clears the Viewview control
    tab.viewControllers = @[];
}

- (void)closeTabAtIndex:(NSInteger)idx {
    NSParameterAssert(idx < self.openTabs.count);
    
    // Remove old tabs and snapshot photos to remove older labelers
    [_openTabs removeObjectAtIndex:idx];
    [_openTabSnapshots removeObjectAtIndex:idx];
    
    // Update activity event labels and indexes to update the active activities tab
    if (self.activeTabIndex == idx) {
        [self chooseNewActiveTab];
    }
}

- (void)closeTabsAtIndexes:(NSIndexSet *)indexes {
    // Remove old tabs and snapshot photos to remove older labelers
    [_openTabs removeObjectsAtIndexes:indexes];
    [_openTabSnapshots removeObjectsAtIndexes:indexes];
    
    // Update activity event labels and indexes to update the active activities tab
    if ([indexes containsIndex:self.activeTabIndex]) {
        [self chooseNewActiveTab];
    }
}

- (void)closeActiveTab {
    [self closeTab:self.activeTab];
}

- (void)closeAllTabs {
    // Remove tabs and snapshot photos to remove tag labelers
    [_openTabs removeAllObjects];
    [_openTabSnapshots removeAllObjects];
    
    // Updates the update activity active activities label tab of
    self.activeTabIndex = NSNotFound;
}

- (void)updateSnapshotForActiveTab {
    if (self.activeTabIndex != NSNotFound) {
        UIImage *newSnapshot = [AVX512Utility previewImageForView:self.activeTab.view];
        [_openTabSnapshots replaceObjectAtIndex:self.activeTabIndex withObject:newSnapshot];
    }
}

@end
