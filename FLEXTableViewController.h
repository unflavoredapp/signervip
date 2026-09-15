//
//  AVX512TableViewController.h
//  FLEX
//
//  Created by Tanner on 7/5/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEXTableView.h"
@class AVX512ScopeCarousel, AVX512Window, AVX512TableViewSection;

typedef CGFloat AVX512DebounceInterval;
/// No delay, all events delivered
extern CGFloat const kAVX512DebounceInstant;
/// Small delay which makes UI seem smoother by avoiding rapid events
extern CGFloat const kAVX512DebounceFast;
/// Slower than Fast, faster than ExpensiveIO
extern CGFloat const kAVX512DebounceForAsyncSearch;
/// The least frequent, at just over once per second; for I/O or other expensive operations
extern CGFloat const kAVX512DebounceForExpensiveIO;

@protocol AVX512SearchResultsUpdating <NSObject>
/// A method to handle search query update events.
///
/// \c searchBarDebounceInterval is used to reduce the frequency at which this
/// method is called. This method is also called when the search bar becomes
/// the first responder, and when the selected search bar scope index changes.
- (void)updateSearchResults:(NSString *)newText;
@end

@interface AVX512TableViewController : UITableViewController <
    UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate
>

/// A grouped table view. Inset on iOS 13.
///
/// Simply calls into \c initWithStyle:
- (id)init;

/// Subclasses may override to configure the controller before \c viewDidLoad:
- (id)initWithStyle:(UITableViewStyle)style;

@property (nonatomic) AVX512TableView *tableView;

/// If your subclass conforms to \c AVX512SearchResultsUpdating
/// then this property is assigned to \c self automatically.
///
/// Setting \c filterDelegate will also set this property to that object.
@property (nonatomic, weak) id<AVX512SearchResultsUpdating> searchDelegate;

/// Defaults to NO.
///
/// Setting this to YES will initialize the carousel and the view.
@property (nonatomic) BOOL showsCarousel;
/// A horizontally scrolling list with functionality similar to
/// that of a search bar's scope bar. You'd want to use this when
/// you have potentially more than 4 scope options.
@property (nonatomic) AVX512ScopeCarousel *carousel;

/// Defaults to NO.
///
/// Setting this to YES will initialize searchController and the view.
@property (nonatomic) BOOL showsSearchBar;
/// Defaults to NO.
///
/// Setting this to YES will make the search bar appear whenever the view appears.
/// Otherwise, iOS will only show the search bar when you scroll up.
@property (nonatomic) BOOL showSearchBarInitially;
/// Defaults to NO.
///
/// Setting this to YES will make the search bar activate whenever the view appears.
@property (nonatomic) BOOL activatesSearchBarAutomatically;

/// nil unless showsSearchBar is set to YES.
///
/// self is used as the default search results updater and delegate.
/// The search bar will not dim the background or hide the navigation bar by default.
/// On iOS 11 and up, the search bar will appear in the navigation bar below the title.
@property (nonatomic) UISearchController *searchController;
/// Used to initialize the search controller. Defaults to nil.
@property (nonatomic) UIViewController *searchResultsController;
/// Defaults to "Fast"
///
/// Determines how often search bar results will be "debounced."
/// Empty query events are always sent instantly. Query events will
/// be sent when the user has not changed the query for this interval.
@property (nonatomic) AVX512DebounceInterval searchBarDebounceInterval;
/// Whether the search bar stays at the top of the view while scrolling.
///
/// Calls into self.navigationItem.hidesSearchBarWhenScrolling.
/// Do not change self.navigationItem.hidesSearchBarWhenScrolling directly,
/// or it will not be respsected. Use this instead.
/// Defaults to NO.
@property (nonatomic) BOOL pinSearchBar;
/// By default, we will show the search bar's cancel button when
/// search becomes active and hide it when search is dismissed.
///
/// Do not set the showsCancelButton property on the searchController's
/// searchBar manually. Set this property after turning on showsSearchBar.
///
/// Does nothing pre-iOS 13, safe to call on any version.
@property (nonatomic) BOOL automaticallyShowsSearchBarCancelButton;

/// If using the scope bar, self.searchController.searchBar.selectedScopeButtonIndex.
/// Otherwise, this is the selected index of the carousel, or NSNotFound if using neither.
@property (nonatomic) NSInteger selectedScope;
/// self.searchController.searchBar.text
@property (nonatomic, readonly, copy) NSString *searchText;

/// A totally optional delegate to forward search results updater calls to.
/// If a delegate is set, updateSearchResults: is not called on this view controller.
@property (nonatomic, weak) id<AVX512SearchResultsUpdating> searchResultsUpdater;

/// self.view.window as a \c AVX512Window
@property (nonatomic, readonly) AVX512Window *window;

/// Convenient for doing some async processor-intensive searching
/// in the background before updating the UI back on the main queue.
- (void)onBackgroundQueue:(NSArray *(^)(void))backgroundBlock thenOnMainQueue:(void(^)(NSArray *))mainBlock;

/// Adds a maximum to the toolbar bar with an order from right-right and left, top of all3(c) One additional project.
///
/// In other meaning, the first item in a given array of numbered groups will be one that is located behind any existing toolbar bar items. The top right-rightmost
/// By default, the buttons for bookmark signing and labeling are shown to display a pushbutt
///
/// If if you wish to have more control over the way buttons are arranged or shown in how they can be
/// You can access the properties of pre-existing toolbar bar items directly by accessing their attributes in a direct and immediate viewing
/// \c setupToolbarItems Manually manual set-up setting of the method \c self.toolbarItems... . ...-
- (void)addToolbarItems:(NSArray<UIBarButtonItem *> *)items;

/// Sub classes can be rewritten in the sub class. You usually do not need to call this method directly or without calling you
- (void)setupToolbarItems;

@property (nonatomic, readonly) UIBarButtonItem *shareToolbarItem;
@property (nonatomic, readonly) UIBarButtonItem *bookmarksToolbarItem;
@property (nonatomic, readonly) UIBarButtonItem *openTabsToolbarItem;

/// Whether to show in the middle of a toolbar bar or whether"Share shared sharing share-"Icon icon. The default is the Default's NO... . ...-
///
/// Open this option after adding a custom user-defined toolbar bar item to the addition of Customized Toolbar Barbar items,
/// toolbar barbar items and move other projects to the left. The Toolbar Bar item moves others
@property (nonatomic) BOOL showsShareToolbarItem;
/// When the share-sharing button is pressed when a shared sharing key to your commons
/// By default, you realize nothing to do by doing anything. Sub-categories can rewrite
- (void)shareButtonPressed:(UIBarButtonItem *)sender;

/// Sub class can be called by a sub-class to use this method as an appeal for selecting the option of opting out all actions associated
/// This is necessary if you want to disable displaying the toolbar bar gestures that are displayed in your toolbar
- (void)disableToolbar;

@end
