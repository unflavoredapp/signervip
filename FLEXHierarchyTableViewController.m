//
//  AVX512HierarchyTableViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-01.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXColor.h"
#import "FLEXHierarchyTableViewController.h"
#import "NSMapTable+FLEX_Subscripting.h"
#import "FLEXUtility.h"
#import "FLEXHierarchyTableViewCell.h"
#import "FLEXObjectExplorerViewController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXResources.h"
#import "FLEXWindow.h"

typedef NS_ENUM(NSUInteger, AVX512HierarchyScope) {
    AVX512HierarchyScopeFullHierarchy,
    AVX512HierarchyScopeViewsAtTap
};

@interface AVX512HierarchyTableViewController ()

@property (nonatomic) NSArray<UIView *> *allViews;
/// View the view address where a views location is seen to map at its depth
/// @((uintptr_t)(__bridge void *)view) -> depth
@property (nonatomic) NSMapTable<NSNumber *, NSNumber *> *depthsForViews;
@property (nonatomic) NSArray<UIView *> *viewsAtTap;
@property (nonatomic) NSArray<UIView *> *displayedViews;
@property (nonatomic, readonly) BOOL showScopeBar;

@end

@implementation AVX512HierarchyTableViewController

+ (instancetype)windows:(NSArray<UIWindow *> *)allWindows
             viewsAtTap:(NSArray<UIView *> *)viewsAtTap
           selectedView:(UIView *)selected {
    NSParameterAssert(allWindows.count);

    NSArray *allViews = [self allViewsInHierarchy:allWindows];
    NSMapTable *depths = [self hierarchyDepthsForViews:allViews];
    return [[self alloc] initWithViews:allViews viewsAtTap:viewsAtTap selectedView:selected depths:depths];
}

- (instancetype)initWithViews:(NSArray<UIView *> *)allViews
                   viewsAtTap:(NSArray<UIView *> *)viewsAtTap
                 selectedView:(UIView *)selectedView
                       depths:(NSMapTable<NSNumber *, NSNumber *> *)depthsForViews {
    NSParameterAssert(allViews);
    NSParameterAssert(depthsForViews.count == allViews.count);

    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.allViews = allViews;
        self.depthsForViews = depthsForViews;
        self.viewsAtTap = viewsAtTap;
        self.selectedView = selectedView;
        
        self.title = @"View viewing the horizontal-level structure of a";
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Keep the selected selection status between different scenes and from one scenario to
    self.clearsSelectionOnViewWillAppear = NO;
    
    // More spatial space to provide cells with more
    self.tableView.rowHeight = 50.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Splits a line to split the lines' indentation by dividing an addition of its
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.showsSearchBar = YES;
    self.showSearchBarInitially = YES;
    // The use of a fixed search bar on this screenscreen using the Fixed
    // Strange visual effects are strangely visible. The next pushed push-in view window controller with a View control
    //
    // self.pinSearchBar = YES;
    self.searchBarDebounceInterval = kAVX512DebounceInstant;
    self.automaticallyShowsSearchBarCancelButton = NO;
    if (self.showScopeBar) {
        self.searchController.searchBar.showsScopeBar = YES;
        self.searchController.searchBar.scopeButtonTitles = @[@"A complete layer-level structure of a", @"The current selection check view of the currently"];
        self.selectedScope = AVX512HierarchyScopeViewsAtTap;
    }
    
    [self updateDisplayedViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self disableToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self trySelectCellForSelectedView];
}


#pragma mark - The hierarchical structure of the hierarchy-level structural at

+ (NSArray<UIView *> *)allViewsInHierarchy:(NSArray<UIWindow *> *)windows {
    return [windows avx512_flatmapped:^id(UIWindow *window, NSUInteger idx) {
        if (![window isKindOfClass:[AVX512Window class]]) {
            return [self viewWithRecursiveSubviews:window];
        }

        return nil;
    }];
}

+ (NSArray<UIView *> *)viewWithRecursiveSubviews:(UIView *)view {
    NSMutableArray<UIView *> *subviews = [NSMutableArray arrayWithObject:view];
    for (UIView *subview in view.subviews) {
        [subviews addObjectsFromArray:[self viewWithRecursiveSubviews:subview]];
    }

    return subviews;
}

+ (NSMapTable<UIView *, NSNumber *> *)hierarchyDepthsForViews:(NSArray<UIView *> *)views {
    NSMapTable<UIView *, NSNumber *> *depths = [NSMapTable strongToStrongObjectsMapTable];
    for (UIView *view in views) {
        NSInteger depth = 0;
        UIView *tryView = view;
        while (tryView.superview) {
            tryView = tryView.superview;
            depth++;
        }
        depths[@((uintptr_t)(__bridge void *)view)] = @(depth);
    }

    return depths;
}


#pragma mark Selection and Filter filtering support methods to select, selection

- (void)trySelectCellForSelectedView {
    NSUInteger selectedViewIndex = [self.displayedViews indexOfObject:self.selectedView];
    if (selectedViewIndex != NSNotFound) {
        UITableViewScrollPosition scrollPosition = UITableViewScrollPositionMiddle;
        NSIndexPath *selectedViewIndexPath = [NSIndexPath indexPathForRow:selectedViewIndex inSection:0];
        [self.tableView selectRowAtIndexPath:selectedViewIndexPath animated:YES scrollPosition:scrollPosition];
    }
}

- (void)updateDisplayedViews {
    NSArray<UIView *> *candidateViews = nil;
    if (self.showScopeBar) {
        if (self.selectedScope == AVX512HierarchyScopeViewsAtTap) {
            candidateViews = self.viewsAtTap;
        } else if (self.selectedScope == AVX512HierarchyScopeFullHierarchy) {
            candidateViews = self.allViews;
        }
    } else {
        candidateViews = self.allViews;
    }
    
    if (self.searchText.length) {
        self.displayedViews = [candidateViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *candidateView, NSDictionary<NSString *, id> *bindings) {
            NSString *title = [AVX512Utility descriptionForView:candidateView includingFrame:NO];
            NSString *candidateViewPointerAddress = [NSString stringWithFormat:@"%p", candidateView];
            BOOL matchedViewPointerAddress = [candidateViewPointerAddress rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
            BOOL matchedViewTitle = [title rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
            return matchedViewPointerAddress || matchedViewTitle;
        }]];
    } else {
        self.displayedViews = candidateViews;
    }
    
    [self.tableView reloadData];
}

- (void)setSelectedView:(UIView *)selectedView {
    _selectedView = selectedView;
    if (self.isViewLoaded) {
        [self trySelectCellForSelectedView];
    }
}


#pragma mark - Search search column for the search / range barbar column of the area

- (BOOL)showScopeBar {
    return self.viewsAtTap.count > 0;
}

- (void)updateSearchResults:(NSString *)newText {
    [self updateDisplayedViews];
    
    // If the search bar text field is in active status if you are looking for column-text fields where there's an activity situation, do not
    // You want to continue entering. Otherwise, you can scroll and make the selected cells visible in your selection cell
    if (!self.searchController.searchBar.isFirstResponder) {
        [self trySelectCellForSelectedView];
    }
}


#pragma mark - Data source sources from the data-source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedViews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    AVX512HierarchyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[AVX512HierarchyTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    UIView *view = self.displayedViews[indexPath.row];

    cell.textLabel.text = [AVX512Utility descriptionForView:view includingFrame:NO];
    cell.detailTextLabel.text = [AVX512Utility detailDescriptionForView:view];
    cell.randomColorTag = [AVX512Utility consistentRandomColorForObject:view];
    cell.viewDepth = self.depthsForViews[@((uintptr_t)(__bridge void *)view)].integerValue;
    cell.indicatedViewColor = view.backgroundColor;

    if (view.isHidden || view.alpha < 0.01) {
        cell.textLabel.textColor = AVX512Color.deemphasizedTextColor;
        cell.detailTextLabel.textColor = AVX512Color.deemphasizedTextColor;
    } else {
        cell.textLabel.textColor = AVX512Color.primaryTextColor;
        cell.detailTextLabel.textColor = AVX512Color.primaryTextColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedView = self.displayedViews[indexPath.row]; // Don't scroll, avoid setter
    if (self.didSelectRowAction) {
        self.didSelectRowAction(_selectedView);
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UIView *drillInView = self.displayedViews[indexPath.row];
    AVX512ObjectExplorerViewController *viewExplorer = [AVX512ObjectExplorerFactory explorerViewControllerForObject:drillInView];
    [self.navigationController pushViewController:viewExplorer animated:YES];
}

@end
