//
//  AVX512TableViewController.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 7/5/19.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXTableViewController.h"
#import "FLEXExplorerViewController.h"
#import "FLEXBookmarksViewController.h"
#import "FLEXTabsViewController.h"
#import "FLEXScopeCarousel.h"
#import "FLEXTableView.h"
#import "FLEXUtility.h"
#import "FLEXResources.h"
#import "UIBarButtonItem+FLEX.h"
#import <objc/runtime.h>

@interface Block : NSObject
- (void)invoke;
@end

CGFloat const kAVX512DebounceInstant = 0.f;
CGFloat const kAVX512DebounceFast = 0.05;
CGFloat const kAVX512DebounceForAsyncSearch = 0.15;
CGFloat const kAVX512DebounceForExpensiveIO = 0.5;

@interface AVX512TableViewController ()
@property (nonatomic) NSTimer *debounceTimer;
@property (nonatomic) BOOL didInitiallyRevealSearchBar;
@property (nonatomic) UITableViewStyle style;

@property (nonatomic) BOOL hasAppeared;
@property (nonatomic, readonly) UIView *tableHeaderViewContainer;

@property (nonatomic, readonly) BOOL manuallyDeactivateSearchOnDisappear;

@property (nonatomic) UIBarButtonItem *middleToolbarItem;
@property (nonatomic) UIBarButtonItem *middleLeftToolbarItem;
@property (nonatomic) UIBarButtonItem *leftmostToolbarItem;
@end

@implementation AVX512TableViewController
@dynamic tableView;
@synthesize showsShareToolbarItem = _showsShareToolbarItem;
@synthesize tableHeaderViewContainer = _tableHeaderViewContainer;
@synthesize automaticallyShowsSearchBarCancelButton = _automaticallyShowsSearchBarCancelButton;

#pragma mark - Initial initialisation to start-in

- (id)init {
    if (@available(iOS 13.0, *)) {
        self = [self initWithStyle:UITableViewStyleInsetGrouped];
    } else {
        self = [self initWithStyle:UITableViewStyleGrouped];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        _searchBarDebounceInterval = kAVX512DebounceFast;
        _showSearchBarInitially = YES;
        _style = style;
        _manuallyDeactivateSearchOnDisappear = (
            NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11
        );
        
        // If we achieve this method, if that is the way to do it by doing so
        if ([self respondsToSelector:@selector(updateSearchResults:)]) {
            self.searchDelegate = (id)self;
        }
    }
    
    return self;
}


#pragma mark - Public methods of public-public method

- (AVX512Window *)window {
    return (id)self.view.window;
}

- (void)setShowsSearchBar:(BOOL)showsSearchBar {
    if (_showsSearchBar == showsSearchBar) return;
    _showsSearchBar = showsSearchBar;
    
    if (showsSearchBar) {
        UIViewController *results = self.searchResultsController;
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:results];
        self.searchController.searchBar.placeholder = @"Filters filter Screening for";
        self.searchController.searchResultsUpdater = (id)self;
        self.searchController.delegate = (id)self;
        if (@available(iOS 9.1, *)) {
            self.searchController.obscuresBackgroundDuringPresentation = NO;
        } else {
            self.searchController.dimsBackgroundDuringPresentation = NO;
        }
        self.searchController.hidesNavigationBarDuringPresentation = NO;
        /// iOS 13Medium does not need to be required; medium isiOS 13Remove this option when removing the minimum deployment target if it has become a
        self.searchController.searchBar.delegate = self;

        self.automaticallyShowsSearchBarCancelButton = YES;

        if (@available(iOS 13, *)) {
            self.searchController.automaticallyShowsScopeBar = NO;
        }
        
        [self addSearchController:self.searchController];
    } else {
        // Search search has been shown and just created to look for the already displayedNO, so as to remove it removed and therefore
        [self removeSearchController:self.searchController];
    }
}

- (void)setShowsCarousel:(BOOL)showsCarousel {
    if (_showsCarousel == showsCarousel) return;
    _showsCarousel = showsCarousel;
    
    if (showsCarousel) {
        _carousel = ({ weakify(self)
            
            AVX512ScopeCarousel *carousel = [AVX512ScopeCarousel new];
            carousel.selectedIndexChangedAction = ^(NSInteger idx) { strongify(self);
                [self.searchDelegate updateSearchResults:self.searchText];
            };

            // UITableViewThe table head size will not be updated unless the first surface front view is re-sets, and
            [carousel registerBlockForDynamicTypeChanges:^(AVX512ScopeCarousel *_) { strongify(self);
                [self layoutTableHeaderIfNeeded];
            }];

            carousel;
        });
        [self addCarousel:_carousel];
    } else {
        // The loop play has been shown and just was set to be created as theNO, so as to remove it removed and therefore
        [self removeCarousel:_carousel];
    }
}

- (NSInteger)selectedScope {
    if (self.searchController.searchBar.showsScopeBar) {
        return self.searchController.searchBar.selectedScopeButtonIndex;
    } else if (self.showsCarousel) {
        return self.carousel.selectedIndex;
    } else {
        return 0;
    }
}

- (void)setSelectedScope:(NSInteger)selectedScope {
    if (self.searchController.searchBar.showsScopeBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = selectedScope;
    } else if (self.showsCarousel) {
        self.carousel.selectedIndex = selectedScope;
    }

    [self.searchDelegate updateSearchResults:self.searchText];
}

- (NSString *)searchText {
    return self.searchController.searchBar.text;
}

- (BOOL)automaticallyShowsSearchBarCancelButton {
    if (@available(iOS 13, *)) {
        return self.searchController.automaticallyShowsCancelButton;
    }

    return _automaticallyShowsSearchBarCancelButton;
}

- (void)setAutomaticallyShowsSearchBarCancelButton:(BOOL)value {
    if (@available(iOS 13, *)) {
        self.searchController.automaticallyShowsCancelButton = value;
    }

    _automaticallyShowsSearchBarCancelButton = value;
}

- (void)onBackgroundQueue:(NSArray *(^)(void))backgroundBlock thenOnMainQueue:(void(^)(NSArray *))mainBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *items = backgroundBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            mainBlock(items);
        });
    });
}

- (void)setsShowsShareToolbarItem:(BOOL)showsShareToolbarItem {
    _showsShareToolbarItem = showsShareToolbarItem;
    if (self.isViewLoaded) {
        [self setupToolbarItems];
    }
}

- (void)disableToolbar {
    self.navigationController.toolbarHidden = YES;
    self.navigationController.hidesBarsOnSwipe = NO;
    self.toolbarItems = nil;
}


#pragma mark - View controller view handler 's life-life

- (void)loadView {
    self.view = [AVX512TableView style:self.style];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.estimatedRowHeight = 10;
    
    _shareToolbarItem = AVX512BarButtonItemSystem(Action, self, @selector(shareButtonPressed:));
    _bookmarksToolbarItem = [UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.bookmarksIcon target:self action:@selector(showBookmarks)
    ];
    _openTabsToolbarItem = [UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.openTabsIcon target:self action:@selector(showTabSwitcher)
    ];
    
    self.leftmostToolbarItem = UIBarButtonItem.avx512_fixedSpace;
    self.middleLeftToolbarItem = UIBarButtonItem.avx512_fixedSpace;
    self.middleToolbarItem = UIBarButtonItem.avx512_fixedSpace;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // Toolbar toolbar bar to, toolbar
    self.navigationController.toolbarHidden = self.toolbarItems.count > 0;
    self.navigationController.hidesBarsOnSwipe = YES;

    // In being in theiOS 13Up, in any case the Root View view controller displays its search bar. The root-view handler
    // Close this option to avoid closing off the program so that you can prevent your navigation bar fromnavigationItem.hidesSearchBarWhenScrolling
    // There are some weird flashes that come out of the switch when you turn off. The blinking still happens on a follow-up view control controller, and
    // But at least, we can prevent it from appearing on the root-view view controller control
    if (@available(iOS 13, *)) {
        if (self.navigationController.viewControllers.firstObject == self) {
            _showSearchBarInitially = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        // Back back when retreats, bring the searchbar to re-reappear instead rather than
        if ((self.pinSearchBar || self.showSearchBarInitially) && !self.didInitiallyRevealSearchBar) {
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
        }
    }
    
    // Makes the keyboard drive appear to be appearing faster and appears more quickly
    if (self.activatesSearchBarAutomatically) {
        [self makeKeyboardAppearNow];
    }

    [self setupToolbarItems];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Allows a rolling close-down search bar to allow scrolling of the closed wrap field, but only when we do not
    if (@available(iOS 11.0, *)) {
        if (self.showSearchBarInitially && !self.pinSearchBar && !self.didInitiallyRevealSearchBar) {
            // All of all these cumbersome and bureaucratic operations are meant to solveiOS 13to the date of this13.2an error in one of the errors
            // Q Fast Switch to switch fast-navigationItem.hidesSearchBarWhenScrollingTo make the search bar Search Bar to
            // The initial appearance at the beginning will lead to an error in search bar that would cause errors of a searching field, make transparent transparency and move on
            [UIView animateWithDuration:0.2 animations:^{
                self.navigationItem.hidesSearchBarWhenScrolling = YES;
                [self.navigationController.view setNeedsLayout];
                [self.navigationController.view layoutIfNeeded];
            }];
        }
    }
    
    if (self.activatesSearchBarAutomatically) {
        // The keyboard has appeared, and now we're calling this because the search bar is about to appear on our Search Bar as
        [self removeDummyTextField];
        
        // Act to activate the active activated search for
        dispatch_async(dispatch_get_main_queue(), ^{
            // Unless the packaging of packing in thisdispatch_asyncIn calling in, or otherwise this is not working. This doesn'
            [self.searchController.searchBar becomeFirstResponder];
        });
    }

    // We just want to show the search bar when a view controller first appears in your views control device. All
    self.didInitiallyRevealSearchBar = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.manuallyDeactivateSearchOnDisappear && self.searchController.isActive) {
        self.searchController.active = NO;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    // Reset this option because we are re-reemaling under the new parent views view controller control, as it is being
    // It needs to be shown again if it is need
    self.didInitiallyRevealSearchBar = NO;
}


#pragma mark - Toolbar toolbars, public methods of general-public method

- (void)setupToolbarItems {
    if (!self.isViewLoaded) {
        return;
    }
    
    self.toolbarItems = @[
        self.leftmostToolbarItem,
        UIBarButtonItem.avx512_flexibleSpace,
        self.middleLeftToolbarItem,
        UIBarButtonItem.avx512_flexibleSpace,
        self.middleToolbarItem,
        UIBarButtonItem.avx512_flexibleSpace,
        self.bookmarksToolbarItem,
        UIBarButtonItem.avx512_flexibleSpace,
        self.openTabsToolbarItem,
    ];
    
    for (UIBarButtonItem *item in self.toolbarItems) {
        [item _setWidth:60];
        // This does not work for any item other than fixed space, except in a stationable
        // item.width = 60;
    }
    
    // It is not for the discretion orFLEXExplorerViewControllerDisimply disable label 's completely de disabled tab tag
    UIViewController *presenter = self.navigationController.presentingViewController;
    if (![presenter isKindOfClass:[AVX512ExplorerViewController class]]) {
        self.openTabsToolbarItem.enabled = NO;
    }
}

- (void)addToolbarItems:(NSArray<UIBarButtonItem *> *)items {
    if (self.showsShareToolbarItem) {
        // Share Sharing buttons sharing the share-button to be shared in middle, skip
        if (items.count > 0) {
            self.middleLeftToolbarItem = items[0];
        }
        if (items.count > 1) {
            self.leftmostToolbarItem = items[1];
        }
    } else {
        // From right to left, from the Right-right through
        if (items.count > 0) {
            self.middleToolbarItem = items[0];
        }
        if (items.count > 1) {
            self.middleLeftToolbarItem = items[1];
        }
        if (items.count > 2) {
            self.leftmostToolbarItem = items[2];
        }
    }
    
    [self setupToolbarItems];
}

- (void)setShowsShareToolbarItem:(BOOL)showShare {
    if (_showsShareToolbarItem != showShare) {
        _showsShareToolbarItem = showShare;
        
        if (showShare) {
            // To the left-leftmost to most Left 's
            self.leftmostToolbarItem = self.middleLeftToolbarItem;
            self.middleLeftToolbarItem = self.middleToolbarItem;
            
            // Use sharing share-sharing in the middle
            self.middleToolbarItem = self.shareToolbarItem;
        } else {
            // Remove share sharing to remove the shared shares, move custom-defined entry items right by moving
            self.middleToolbarItem = self.middleLeftToolbarItem;
            self.middleLeftToolbarItem = self.leftmostToolbarItem;
            self.leftmostToolbarItem = UIBarButtonItem.avx512_fixedSpace;
        }
    }
    
    [self setupToolbarItems];
}

- (void)shareButtonPressed:(UIBarButtonItem *)sender {

}


#pragma mark - Private private methods and privately-private

- (void)debounce:(void(^)(void))block {
    [self.debounceTimer invalidate];
    
    self.debounceTimer = [NSTimer
        scheduledTimerWithTimeInterval:self.searchBarDebounceInterval
        target:block
        selector:@selector(invoke)
        userInfo:nil
        repeats:NO
    ];
}

- (void)layoutTableHeaderIfNeeded {
    if (self.showsCarousel) {
        self.carousel.frame = AVX512RectSetHeight(
            self.carousel.frame, self.carousel.intrinsicContentSize.height
        );
    }
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)addCarousel:(AVX512ScopeCarousel *)carousel {
    if (@available(iOS 11.0, *)) {
        self.tableView.tableHeaderView = carousel;
    } else {
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        CGRect frame = self.tableHeaderViewContainer.frame;
        CGRect subviewFrame = carousel.frame;
        subviewFrame.origin.y = 0;
        
        // If searchbar already exists if the Search bar does exist, play a wheeled round at below bottom of your
        if (self.showsSearchBar) {
            carousel.frame = subviewFrame = AVX512RectSetY(
                subviewFrame, self.searchController.searchBar.frame.size.height
            );
            frame.size.height += carousel.intrinsicContentSize.height;
        } else {
            frame.size.height = carousel.intrinsicContentSize.height;
        }
        
        self.tableHeaderViewContainer.frame = frame;
        [self.tableHeaderViewContainer addSubview:carousel];
    }
    
    [self layoutTableHeaderIfNeeded];
}

- (void)removeCarousel:(AVX512ScopeCarousel *)carousel {
    [carousel removeFromSuperview];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.tableHeaderView = nil;
    } else {
        if (self.showsSearchBar) {
            [self removeSearchController:self.searchController];
            [self addSearchController:self.searchController];
        } else {
            self.tableView.tableHeaderView = nil;
            _tableHeaderViewContainer = nil;
        }
    }
}

- (void)addSearchController:(UISearchController *)controller {
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = controller;
    } else {
        controller.searchBar.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
        [self.tableHeaderViewContainer addSubview:controller.searchBar];
        CGRect subviewFrame = controller.searchBar.frame;
        CGRect frame = self.tableHeaderViewContainer.frame;
        frame.size.width = MAX(frame.size.width, subviewFrame.size.width);
        frame.size.height = subviewFrame.size.height;
        
        // If the looper already exists, move it down downwards and moving on if a
        if (self.showsCarousel) {
            self.carousel.frame = AVX512RectSetY(
                self.carousel.frame, subviewFrame.size.height
            );
            frame.size.height += self.carousel.frame.size.height;
        }
        
        self.tableHeaderViewContainer.frame = frame;
        [self layoutTableHeaderIfNeeded];
    }
}

- (void)removeSearchController:(UISearchController *)controller {
    [controller.searchBar removeFromSuperview];
    
    if (self.showsCarousel) {
        // self.carousel.frame = AVX512RectRemake(CGPointZero, self.carousel.frame.size);
        [self removeCarousel:self.carousel];
        [self addCarousel:self.carousel];
    } else {
        self.tableView.tableHeaderView = nil;
        _tableHeaderViewContainer = nil;
    }
}

- (UIView *)tableHeaderViewContainer {
    if (!_tableHeaderViewContainer) {
        _tableHeaderViewContainer = [UIView new];
        self.tableView.tableHeaderView = self.tableHeaderViewContainer;
    }
    
    return _tableHeaderViewContainer;
}

- (void)showBookmarks {
    UINavigationController *nav = [[UINavigationController alloc]
        initWithRootViewController:[AVX512BookmarksViewController new]
    ];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showTabSwitcher {
    UINavigationController *nav = [[UINavigationController alloc]
        initWithRootViewController:[AVX512TabsViewController new]
    ];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - Search search column for the search

#pragma mark Faster faster speeder keyboard drive with a more fast

static UITextField *kDummyTextField = nil;

/// Makes the keyboard come up immediately. We use this to make it appear faster when you start displaying a search bar at first show in your searching field, and more quickly as
/// Before a search bar appears in the Search Bar, you must be called to call before \c -removeDummyTextField... . ...-
- (void)makeKeyboardAppearNow {
    if (!kDummyTextField) {
        kDummyTextField = [UITextField new];
        kDummyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    kDummyTextField.inputAccessoryView = self.searchController.searchBar.inputAccessoryView;
    [UIApplication.sharedApplication.keyWindow addSubview:kDummyTextField];
    [kDummyTextField becomeFirstResponder];
}

- (void)removeDummyTextField {
    if (kDummyTextField.superview) {
        [kDummyTextField removeFromSuperview];
    }
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.debounceTimer invalidate];
    NSString *text = searchController.searchBar.text;
    
    void (^updateSearchResults)(void) = ^{
        if (self.searchResultsUpdater) {
            [self.searchResultsUpdater updateSearchResults:text];
        } else {
            [self.searchDelegate updateSearchResults:text];
        }
    };
    
    // Delay processing is delayed only when we need it and where there are non-empty string strings, which do not empty
    // An empty string event is immediately sent to send an E-
    if (text.length && self.searchBarDebounceInterval > kAVX512DebounceInstant) {
        [self debounce:updateSearchResults];
    } else {
        updateSearchResults();
    }
}


#pragma mark UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    // Manual manual, hand-to show aiOS 13Cancel cancelbut to the cancellation buttons of your
    if (!@available(iOS 13, *) && self.automaticallyShowsSearchBarCancelButton) {
        [searchController.searchBar setShowsCancelButton:YES animated:YES];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // Manually, manual hide-hi hiddeniOS 13Cancel cancelbut to the cancellation buttons of your
    if (!@available(iOS 13, *) && self.automaticallyShowsSearchBarCancelButton) {
        [searchController.searchBar setShowsCancelButton:NO animated:YES];
    }
}


#pragma mark UISearchBarDelegate

/// iOS 13Medium does not need to be required; medium isiOS 13Remove this option when it is removed as a target for deployment
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}


#pragma mark View view-view views

/// In the first part where there is no title without a head heading in section 1 that does not have headings for
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (@available(iOS 13, *)) {
        if (self.style == UITableViewStyleInsetGrouped) {
            return @" ";
        }
    }

    return nil; // For ordinary common for general/Group group groups the clustering style
}

@end
