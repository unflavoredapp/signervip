//
//  AVX512NetworkMITMViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXColor.h"
#import "FLEXUtility.h"
#import "FLEXMITMDataSource.h"
#import "FLEXNetworkMITMViewController.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXNetworkObserver.h"
#import "FLEXNetworkTransactionCell.h"
#import "FLEXHTTPTransactionDetailController.h"
#import "FLEXNetworkSettingsController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXGlobalsViewController.h"
#import "FLEXWebViewController.h"
#import "UIBarButtonItem+FLEX.h"
#import "FLEXResources.h"
#import "NSUserDefaults+FLEX.h"

#define kFirebaseAvailable NSClassFromString(@"FIRDocumentReference")
#define kWebsocketsAvailable @available(iOS 13.0, *)

typedef NS_ENUM(NSInteger, AVX512NetworkObserverMode) {
    AVX512NetworkObserverModeFirebase = 0,
    AVX512NetworkObserverModeREST,
    AVX512NetworkObserverModeWebsockets,
};

@interface AVX512NetworkMITMViewController ()

@property (nonatomic) BOOL updateInProgress;
@property (nonatomic) BOOL pendingReload;

@property (nonatomic) AVX512NetworkObserverMode mode;

@property (nonatomic, readonly) AVX512MITMDataSource<AVX512NetworkTransaction *> *dataSource;
@property (nonatomic, readonly) AVX512MITMDataSource<AVX512HTTPTransaction *> *HTTPDataSource;
@property (nonatomic, readonly) AVX512MITMDataSource<AVX512WebsocketTransaction *> *websocketDataSource;
@property (nonatomic, readonly) AVX512MITMDataSource<AVX512FirebaseTransaction *> *firebaseDataSource;

@end

@implementation AVX512NetworkMITMViewController

#pragma mark - The life cycle of the

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsSearchBar = YES;
    self.pinSearchBar = YES;
    self.showSearchBarInitially = NO;
    NSMutableArray *scopeTitles = [NSMutableArray arrayWithObject:@"REST"];
    
    _HTTPDataSource = [AVX512MITMDataSource dataSourceWithProvider:^NSArray * {
        return AVX512NetworkRecorder.defaultRecorder.HTTPTransactions;
    }];

    if (kFirebaseAvailable) {
        _firebaseDataSource = [AVX512MITMDataSource dataSourceWithProvider:^NSArray * {
            return AVX512NetworkRecorder.defaultRecorder.firebaseTransactions;
        }];
        [scopeTitles insertObject:@"Firebase" atIndex:0]; // The first space, the
    }

    if (kWebsocketsAvailable) {
        [scopeTitles addObject:@"Websockets"]; // Last space last, the final spatial
        _websocketDataSource = [AVX512MITMDataSource dataSourceWithProvider:^NSArray * {
            return AVX512NetworkRecorder.defaultRecorder.websocketTransactions;
        }];
    }
    
    // Only only if we have what there areFirebaseor/or is,WebsocketsThe range ranges will be shown only if available to show
    self.searchController.searchBar.showsScopeBar = scopeTitles.count > 1;
    self.searchController.searchBar.scopeButtonTitles = scopeTitles;
    self.mode = NSUserDefaults.standardUserDefaults.avx512_lastNetworkObserverMode;

    [self addToolbarItems:@[
        [UIBarButtonItem
            avx512_itemWithImage:AVX512Resources.gearIcon
            target:self
            action:@selector(settingsButtonTapped:)
        ],
        [[UIBarButtonItem
          avx512_systemItem:UIBarButtonSystemItemTrash
          target:self
          action:@selector(trashButtonTapped:)
        ] avx512_withTintColor:UIColor.redColor]
    ]];

    [self.tableView
        registerClass:AVX512NetworkTransactionCell.class
        forCellReuseIdentifier:AVX512NetworkTransactionCell.reuseID
    ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = AVX512NetworkTransactionCell.preferredCellHeight;

    [self registerForNotifications];
    [self updateTransactions:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If we receive updates from outside the screen if an update is received out of view, then reload a
    if (self.pendingReload) {
        [self.tableView reloadData];
        self.pendingReload = NO;
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)registerForNotifications {
    NSDictionary *notifications = @{
        kAVX512NetworkRecorderNewTransactionNotification:
            NSStringFromSelector(@selector(handleNewTransactionRecordedNotification:)),
        kAVX512NetworkRecorderTransactionUpdatedNotification:
            NSStringFromSelector(@selector(handleTransactionUpdatedNotification:)),
        kAVX512NetworkRecorderTransactionsClearedNotification:
            NSStringFromSelector(@selector(handleTransactionsClearedNotification:)),
        kAVX512NetworkObserverEnabledStateChangedNotification:
            NSStringFromSelector(@selector(handleNetworkObserverEnabledStateChangedNotification:)),
    };
    
    for (NSString *name in notifications.allKeys) {
        [NSNotificationCenter.defaultCenter addObserver:self
            selector:NSSelectorFromString(notifications[name]) name:name object:nil
        ];
    }
}


#pragma mark - Private private methods and privately-private

#pragma mark button to the implementation of this tool

- (void)settingsButtonTapped:(UIBarButtonItem *)sender {
    UIViewController *settings = [AVX512NetworkSettingsController new];
    settings.navigationItem.rightBarButtonItem = AVX512BarButtonItemSystem(
        Done, self, @selector(settingsViewControllerDoneTapped:)
    );
    settings.title = @"Network-net listen listening bug Listen switch switches turn Switch";
    
    // It's not thatFLEXNavigationControllerBecause it is not designed as a new tab label because, since this was
    UIViewController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)trashButtonTapped:(UIBarButtonItem *)sender {
    [AVX512Alert makeSheet:^(AVX512Alert *make) {
        BOOL clearAll = !self.dataSource.isFiltered;
        if (!clearAll) {
            make.title(@"Clear Filter filtering request? Cleans the s");
            make.message(@"This will only remove the deletion of a request on this screen that matches your search string's number for matching");
        } else {
            make.title(@"Requests to clear all recorded records of requests for clearances");
            make.message(@"It's uncan could not be revoked.");
        }
        
        make.button(@"Cancel").cancelStyle();
        make.button(@"Clear empty, clear and empt").destructiveStyle().handler(^(NSArray *strings) {
            if (clearAll) {
                [AVX512NetworkRecorder.defaultRecorder clearRecordedActivity];
            } else {
                AVX512NetworkTransactionKind kind = (AVX512NetworkTransactionKind)self.mode;
                [AVX512NetworkRecorder.defaultRecorder clearRecordedActivity:kind matching:self.searchText];
            }
        });
    } showFrom:self source:sender];
}

- (void)settingsViewControllerDoneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark A. Conduct of business in the

- (AVX512NetworkObserverMode)mode {
    AVX512NetworkObserverMode mode = self.searchController.searchBar.selectedScopeButtonIndex;
    switch (mode) {
        case AVX512NetworkObserverModeFirebase:
            if (kFirebaseAvailable) {
                return AVX512NetworkObserverModeFirebase;
            }

            return AVX512NetworkObserverModeREST;
        case AVX512NetworkObserverModeREST:
            if (kFirebaseAvailable) {
                return AVX512NetworkObserverModeREST;
            }

            return AVX512NetworkObserverModeWebsockets;
        case AVX512NetworkObserverModeWebsockets:
            return AVX512NetworkObserverModeWebsockets;
    }
}

- (void)setMode:(AVX512NetworkObserverMode)mode {
// Sub-paragraph control will be controlled in accordance withAPIHe has different appearances. For example, when only there is a person who canWebsocketsWhen available: _ Available availability time
//
//               0                           1
// ┌───────────────────────────┬────────────────────────────┐
// │            REST           │         Websockets         │
// └───────────────────────────┴────────────────────────────┘
//
// when the day isFirebaseandWebsocketsBoth are available when: _ Available availability time
//
//          0                  1                  2
// ┌──────────────────┬──────────────────┬──────────────────┐
// │     Firebase     │       REST       │    Websockets    │
// └──────────────────┴──────────────────┴──────────────────┘
//
// Therefore, we need to adjust the input mode pattern variable accordingly and then actually set it up. We therefore want
// When we try to set it in settings when tryingFirebaseBut yet, butFirebaseWhen not available, we don't do anything at all because when it is non-FirebaseUnavailable when not available, if unavailable
// AVX512NetworkObserverModeFirebaseThe expression and the absence of an indicationFirebaseThe whole of all theRESTSame index of the same Indexes.
// For every other for each of the others, we subtract1, and for each associated related relation per relevantAPIThis is not available. It does
// So, therefore for the case asWebsocketsIf it's not available, we de-min minus and subtract if1, it turns into the turn ofFLEXNetworkObserverModeREST... . ...-
// If if, whatFirebaseIt's not available or usable, either. Let us1... . ...-

    switch (mode) {
        case AVX512NetworkObserverModeFirebase:
            // If if, whatFirebaseNot available. Default default will be assumed to use theREST
            break;
        case AVX512NetworkObserverModeREST:
            // If if, whatFirebaseNot available and not usable, butFirebasewill be transformed and turned into aREST
            if (!kFirebaseAvailable) {
                mode--;
            }
            break;
        case AVX512NetworkObserverModeWebsockets:
            // If if, whatWebsocketsNot available. Default default will be assumed to use theREST
            if (!kWebsocketsAvailable) {
                mode--;
            }
            // If if, whatFirebaseNot available and not usable, butFirebasewill be transformed and turned into aREST
            if (!kFirebaseAvailable) {
                mode--;
            }
    }

    self.searchController.searchBar.selectedScopeButtonIndex = mode;
}

- (AVX512MITMDataSource<AVX512NetworkTransaction *> *)dataSource {
    switch (self.mode) {
        case AVX512NetworkObserverModeREST:
            return self.HTTPDataSource;
        case AVX512NetworkObserverModeWebsockets:
            return self.websocketDataSource;
        case AVX512NetworkObserverModeFirebase:
            return self.firebaseDataSource;
    }
}

- (void)updateTransactions:(void(^)(void))callback {
    id completion = ^(AVX512MITMDataSource *dataSource) {
        // Updates the update inby byin to updated field
        [self updateFirstSectionHeader];
        if (callback && dataSource == self.dataSource) callback();
    };
    
    [self.HTTPDataSource reloadData:completion];
    [self.websocketDataSource reloadData:completion];
    [self.firebaseDataSource reloadData:completion];
}


#pragma mark Title title of the heading

- (void)updateFirstSectionHeader {
    UIView *view = [self.tableView headerViewForSection:0];
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self headerText];
        [headerView setNeedsLayout];
    }
}

- (NSString *)headerText {
    long long bytesReceived = self.dataSource.bytesReceived;
    NSInteger totalRequests = self.dataSource.transactions.count;
    
    NSString *byteCountText = [NSByteCountFormatter
        stringFromByteCount:bytesReceived countStyle:NSByteCountFormatterCountStyleBinary
    ];
    NSString *requestsText = totalRequests == 1 ? @"Request request, requests requested" : @"Request request, requests requested";
    
    // From all from theFirebaseExcludes excluding excluded byby to exclude the in By
    if (self.mode == AVX512NetworkObserverModeFirebase) {
        return [NSString stringWithFormat:@"%@ %@",
            @(totalRequests), requestsText
        ];
    }
    
    return [NSString stringWithFormat:@"%@ %@ (%@ Received received receiving receipt accepted)",
        @(totalRequests), requestsText, byteCountText
    ];
}


#pragma mark - AVX512GlobalsEntry

+ (NSString *)globalsEntryTitle:(AVX512GlobalsRow)row {
    return @"Network History";
}

+ (AVX512GlobalsEntryRowAction)globalsEntryRowAction:(AVX512GlobalsRow)row {
    return ^(UITableViewController *host) {
        if (AVX512NetworkObserver.isEnabled) {
            [host.navigationController pushViewController:[
                self globalsEntryViewController:row
            ] animated:YES];
        } else {
            [AVX512Alert makeAlert:^(AVX512Alert *make) {
                make.title(@"Network Monitors network monitor monitors are currently disabled for the current");
                make.message(@"You must enable web-based monitoring to continue.");
                
                make.button(@"Opens open opened").preferred().handler(^(NSArray<NSString *> *strings) {
                    AVX512NetworkObserver.enabled = YES;
                    [host.navigationController pushViewController:[
                        self globalsEntryViewController:row
                    ] animated:YES];
                });
                make.button(@"Cancel").cancelStyle();
            } showFrom:host];
        }
    };
}

+ (UIViewController *)globalsEntryViewController:(AVX512GlobalsRow)row {
    UIViewController *controller = [self new];
    controller.title = [self globalsEntryTitle:row];
    return controller;
}


#pragma mark - Notice process procedure for notice notification processing proceedings

- (void)handleNewTransactionRecordedNotification:(NSNotification *)notification {
    [self tryUpdateTransactions];
}

- (void)tryUpdateTransactions {
    // If we are not in the view level-level structure of a View hierarchy, no views update
    if (!self.viewIfLoaded.window) {
        [self updateTransactions:nil];
        self.pendingReload = YES;
        return;
    }
    
    // When the animation has been completed, let previous rows insert to prior lines and then start a new animation after it is finished before
    // We will try to call this method again when the insertion is complete and we'll attempt once
    // If we don't change if there is no changes that changed,
    if (self.updateInProgress) {
        return;
    }
    
    self.updateInProgress = YES;

    // Before updating the update, get Status status position before
    NSString *currentFilter = self.searchText;
    AVX512NetworkObserverMode currentMode = self.mode;
    NSInteger existingRowCount = self.dataSource.transactions.count;
    
    [self updateTransactions:^{
        // Compare comparison with the updated status as compared to a more
        NSString *newFilter = self.searchText;
        AVX512NetworkObserverMode newMode = self.mode;
        NSInteger newRowCount = self.dataSource.transactions.count;
        NSInteger rowCountDiff = newRowCount - existingRowCount;
        
        // If the observed pattern changes in observation mode, or if search field text is changed to a change of viewing
        if (newMode != currentMode || ![currentFilter isEqualToString:newFilter]) {
            self.updateInProgress = NO;
            return;
        }
        
        if (rowCountDiff) {
            // If we are at the top, insert animated drawings.
            if (self.tableView.contentOffset.y <= 0.0 && rowCountDiff > 0) {
                [CATransaction begin];
                
                [CATransaction setCompletionBlock:^{
                    self.updateInProgress = NO;
                    // This is not an unlimited cycle, and if there are no new things for the second time it will never run a third
                    [self tryUpdateTransactions];
                }];
                
                NSMutableArray<NSIndexPath *> *indexPathsToReload = [NSMutableArray new];
                for (NSInteger row = 0; row < rowCountDiff; row++) {
                    [indexPathsToReload addObject:[NSIndexPath indexPathForRow:row inSection:0]];
                }

                [self.tableView insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
                [CATransaction commit];
            } else {
                // If the user has already scroll down-downwards, keep your users' location if you
                CGSize existingContentSize = self.tableView.contentSize;
                [self.tableView reloadData];
                CGFloat contentHeightChange = self.tableView.contentSize.height - existingContentSize.height;
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + contentHeightChange);
                self.updateInProgress = NO;
            }
        } else {
            self.updateInProgress = NO;
        }
    }];
}

- (void)handleTransactionUpdatedNotification:(NSNotification *)notification {
    [self.HTTPDataSource reloadByteCounts];
    [self.websocketDataSource reloadByteCounts];
    // There is no need to reload the again load-Firebase

    AVX512NetworkTransaction *transaction = notification.userInfo[kAVX512NetworkRecorderUserInfoTransactionKey];

    // Update the Main Table View and Search view of search table views if necessary to update, as required
    for (AVX512NetworkTransactionCell *cell in self.tableView.visibleCells) {
        if ([cell.transaction isEqual:transaction]) {
            // Use the use of usage-[UITableView reloadRowsAtIndexPaths:withRowAnimation:]It's excessive, it is over-over
            // And a lot of work has been initiated, which may cause the table view to be somewhat unresponsive when there is an influx in large volumes with
            // We just need to tell the cell that it needs a new layout. Let's
            [cell setNeedsLayout];
            break;
        }
    }
    
    [self updateFirstSectionHeader];
}

- (void)handleTransactionsClearedNotification:(NSNotification *)notification {
    [self updateTransactions:^{
        [self.tableView reloadData];
    }];
}

- (void)handleNetworkObserverEnabledStateChangedNotification:(NSNotification *)notification {
    // Updates the title header to update a caption heading. When network debug commissioning is disabled,
    [self updateFirstSectionHeader];
}


#pragma mark - Data source sources from the data-source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.transactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self headerText];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVX512NetworkTransactionCell *cell = [tableView
        dequeueReusableCellWithIdentifier:AVX512NetworkTransactionCell.reuseID
        forIndexPath:indexPath
    ];
    
    cell.transaction = [self transactionAtIndexPath:indexPath];

    // As we insert it from the top, because of our insertions at super-top level there is a background colour that has to be assigned back colored
    NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];
    if ((totalRows - indexPath.row) % 2 == 0) {
        cell.backgroundColor = AVX512Color.secondaryBackgroundColor;
    } else {
        cell.backgroundColor = AVX512Color.primaryBackgroundColor;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.mode) {
        case AVX512NetworkObserverModeREST: {
            AVX512HTTPTransaction *transaction = [self HTTPTransactionAtIndexPath:indexPath];
            UIViewController *details = [AVX512HTTPTransactionDetailController withTransaction:transaction];
            [self.navigationController pushViewController:details animated:YES];
            break;
        }
            
        case AVX512NetworkObserverModeWebsockets: {
            if (@available(iOS 13.0, *)) { // The checker will never fail to this
                AVX512WebsocketTransaction *transaction = [self websocketTransactionAtIndexPath:indexPath];
                
                UIViewController *details = nil;
                if (transaction.message.type == NSURLSessionWebSocketMessageTypeData) {
                    details = [AVX512ObjectExplorerFactory explorerViewControllerForObject:transaction.message.data];
                } else {
                    details = [[AVX512WebViewController alloc] initWithText:transaction.message.string];
                }
                
                [self.navigationController pushViewController:details animated:YES];
            }
            break;
        }
        
        case AVX512NetworkObserverModeFirebase: {
            AVX512FirebaseTransaction *transaction = [self firebaseTransactionAtIndexPath:indexPath];
//            id obj = transaction.documents.count == 1 ? transaction.documents.firstObject : transaction.documents;
            UIViewController *explorer = [AVX512ObjectExplorerFactory explorerViewControllerForObject:transaction];
            [self.navigationController pushViewController:explorer animated:YES];
        }
    }
}


#pragma mark - The menu operation of the Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UIPasteboard.generalPasteboard.string = [self transactionAtIndexPath:indexPath].copyString;
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    
    AVX512NetworkTransaction *transaction = [self transactionAtIndexPath:indexPath];
    
    return [UIContextMenuConfiguration
        configurationWithIdentifier:nil
        previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction
                actionWithTitle:@"Copy copy-copy duplicateURL"
                image:nil
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    UIPasteboard.generalPasteboard.string = transaction.copyString;
                }
            ];
        
            NSArray *children = @[copy];
            if (self.mode == AVX512NetworkObserverModeREST) {
                NSURLRequest *request = [self HTTPTransactionAtIndexPath:indexPath].request;
                UIAction *denylist = [UIAction
                    actionWithTitle:[NSString stringWithFormat:@"Exclude exclude excluded exclusion rule '%@'", request.URL.host]
                    image:nil
                    identifier:nil
                    handler:^(__kindof UIAction *action) {
                        NSMutableArray *denylist =  AVX512NetworkRecorder.defaultRecorder.hostDenylist;
                        [denylist addObject:request.URL.host];
                        [AVX512NetworkRecorder.defaultRecorder clearExcludedTransactions];
                        [AVX512NetworkRecorder.defaultRecorder synchronizeDenylist];
                        [self tryUpdateTransactions];
                    }
                ];
                
                children = [children arrayByAddingObject:denylist];
            }
            return [UIMenu
                menuWithTitle:@"" image:nil identifier:nil
                options:UIMenuOptionsDisplayInline
                children:children
            ];
        }
    ];
}

- (AVX512NetworkTransaction *)transactionAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource.transactions[indexPath.row];
}

- (AVX512HTTPTransaction *)HTTPTransactionAtIndexPath:(NSIndexPath *)indexPath {
    return self.HTTPDataSource.transactions[indexPath.row];
}

- (AVX512WebsocketTransaction *)websocketTransactionAtIndexPath:(NSIndexPath *)indexPath {
    return self.websocketDataSource.transactions[indexPath.row];
}

- (AVX512FirebaseTransaction *)firebaseTransactionAtIndexPath:(NSIndexPath *)indexPath {
    return self.firebaseDataSource.transactions[indexPath.row];
}

#pragma mark - Search search column for the search

- (void)updateSearchResults:(NSString *)searchString {
    id callback = ^(AVX512MITMDataSource *dataSource) {
        if (self.dataSource == dataSource) {
            [self.tableView reloadData];
        }
    };
    
    [self.HTTPDataSource filter:searchString completion:callback];
    [self.websocketDataSource filter:searchString completion:callback];
    [self.firebaseDataSource filter:searchString completion:callback];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)newScope {
    [self updateFirstSectionHeader];
    [self.tableView reloadData];

    NSUserDefaults.standardUserDefaults.avx512_lastNetworkObserverMode = self.mode;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

@end
