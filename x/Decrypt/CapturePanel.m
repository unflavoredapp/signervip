#import "CapturePanel.h"
#import "FLEXColor.h"
#import "FLEXTableViewController.h"
#import "FLEXNetworkMITMViewController.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXNetworkTransactionCell.h"
#import "FLEXNetworkObserver.h"
#import "FLEXNetworkSettingsController.h"
#import "FLEXResources.h"
#import "UIBarButtonItem+FLEX.h"
#import "FLEXHTTPTransactionDetailController.h"
#import "FLEXActivityViewController.h"
#import "DatabaseManager.h"
#import "UCDecryptTool.h"

#pragma mark - Notification of a notification name definition for the

NSString *const CaptureDataUpdatedNotification = @"CaptureDataUpdatedNotification";
NSString *const CaptureDataUpdatedTableKey = @"tableName";

#pragma mark - Type type-type definition of the

typedef NS_ENUM(NSInteger, CaptureTab) {
    CaptureTabNetwork = 0,
    CaptureTabDecrypt,
    CaptureTabKeys,
    CaptureTabCrypto,
};

#pragma mark - Function Switch switch on function of the functional turn-

@interface CaptureSwitchItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *switchKey;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL defaultValue;
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key desc:(NSString *)desc default:(BOOL)def;
@end

@implementation CaptureSwitchItem
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key desc:(NSString *)desc default:(BOOL)def {
    CaptureSwitchItem *item = [CaptureSwitchItem new];
    item.title = title;
    item.switchKey = key;
    item.desc = desc;
    item.defaultValue = def;
    return item;
}
@end

#pragma mark - Details of detail details for more detailed view views View

@interface CaptureDetailViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, copy) NSString *textContent;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSArray<NSValue *> *matchRanges;
@property (nonatomic, assign) NSInteger currentMatchIndex;

@end

@implementation CaptureDetailViewController

- (instancetype)initWithText:(NSString *)text title:(NSString *)title {
    self = [super init];
    if (self) {
        _textContent = text ?: @"";
        _navTitle = title ?: @"For more details, please";
        _fontSize = 11;
        _matchRanges = @[];
        _currentMatchIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = AVX512Color.primaryBackgroundColor;
    self.title = self.navTitle;
    
    // Global navigation bar button to the guidance Bar
    UIBarButtonItem *copy = [[UIBarButtonItem alloc]
        initWithTitle:@"Copy copy-copy duplicate"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(copyAction)];
    
    UIBarButtonItem *share = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
        target:self
        action:@selector(shareAction)];
    
    UIBarButtonItem *font = [[UIBarButtonItem alloc]
        initWithTitle:@"The font Font for the"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(fontAction)];
    
    self.navigationItem.rightBarButtonItems = @[share, copy, font];
    
    // Search search column for the search
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search search for the contents of searching...";
    self.searchBar.backgroundColor = AVX512Color.primaryBackgroundColor;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    // Text text view of the texts in
    CGFloat topOffset = 44;
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, topOffset,
        self.view.bounds.size.width, self.view.bounds.size.height - topOffset)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = AVX512Color.primaryBackgroundColor;
    self.textView.textColor = AVX512Color.primaryTextColor;
    self.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:self.fontSize];
    self.textView.editable = NO;
    self.textView.selectable = YES;
    self.textView.text = self.textContent;
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.textView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topInset = self.view.safeAreaInsets.top;
    [self.searchBar sizeToFit];
    self.searchBar.frame = CGRectMake(0, topInset, self.view.bounds.size.width, self.searchBar.frame.size.height);
    self.textView.frame = CGRectMake(0, topInset + self.searchBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - topInset - self.searchBar.frame.size.height);
}

#pragma mark - Operation of the operation operations

- (void)copyAction {
    UIPasteboard.generalPasteboard.string = self.textContent;
    
    // Visual visual feedback video-visual feed
    UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    toast.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    toast.textColor = [UIColor whiteColor];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.font = [UIFont systemFontOfSize:14];
    toast.text = @"Copy copied copy- over";
    toast.layer.cornerRadius = 8;
    toast.clipsToBounds = YES;
    toast.alpha = 0;
    [self.view addSubview:toast];
    
    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.8 options:0 animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

- (void)shareAction {
    NSArray *items = @[self.textContent];
    UIBarButtonItem *sourceItem = nil;
    if (self.navigationItem.rightBarButtonItems.count > 0) {
        sourceItem = self.navigationItem.rightBarButtonItems.firstObject;
    }
    UIViewController *activityVC = [AVX512ActivityViewController sharing:items source:sourceItem];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)fontAction {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"The font size-size and the"
        message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *sizes = @[@10, @11, @12, @14, @16, @18, @20];
    for (NSNumber *size in sizes) {
        NSString *title = [NSString stringWithFormat:@"%@ pt", size];
        if (size.integerValue == self.fontSize) {
            title = [title stringByAppendingString:@" ✓"];
        }
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.fontSize = size.integerValue;
            self.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:self.fontSize];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems.lastObject;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Search search and searching for

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    [self highlightMatches];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self findNextMatch];
}

- (void)highlightMatches {
    NSString *search = self.searchText.lowercaseString;
    if (search.length == 0) {
        self.textView.attributedText = [[NSAttributedString alloc]
            initWithString:self.textContent
            attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo-Regular" size:self.fontSize],
                         NSForegroundColorAttributeName: AVX512Color.primaryTextColor}];
        self.matchRanges = @[];
        return;
    }
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc]
        initWithString:self.textContent
        attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo-Regular" size:self.fontSize],
                     NSForegroundColorAttributeName: AVX512Color.primaryTextColor}];
    
    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
    NSString *text = self.textContent.lowercaseString;
    NSRange searchRange = NSMakeRange(0, text.length);
    
    while (searchRange.location < text.length) {
        NSRange foundRange = [text rangeOfString:search options:0 range:searchRange];
        if (foundRange.location == NSNotFound) break;
        
        [ranges addObject:[NSValue valueWithRange:foundRange]];
        [attrText addAttribute:NSBackgroundColorAttributeName
                         value:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.4]
                         range:foundRange];
        
        searchRange.location = foundRange.location + foundRange.length;
        searchRange.length = text.length - searchRange.location;
    }
    
    self.matchRanges = ranges;
    self.currentMatchIndex = 0;
    self.textView.attributedText = attrText;
    
    if (ranges.count > 0) {
        [self scrollToMatch:0];
    }
}

- (void)findNextMatch {
    if (self.matchRanges.count == 0) return;
    
    self.currentMatchIndex = (self.currentMatchIndex + 1) % self.matchRanges.count;
    [self scrollToMatch:self.currentMatchIndex];
}

- (void)scrollToMatch:(NSInteger)index {
    if (index < 0 || index >= self.matchRanges.count) return;
    
    NSRange range = [self.matchRanges[index] rangeValue];
    [self.textView scrollRangeToVisible:range];
}

@end

#pragma mark - Set set settings for setting up a view views View

@interface CaptureSettingsVC : AVX512TableViewController
@property (nonatomic, strong) NSArray<CaptureSwitchItem *> *switchItems;
@end

@implementation CaptureSettingsVC

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"The functional settings setup of the";
        
        _switchItems = @[
            [CaptureSwitchItem itemWithTitle:@"General switch on the general switches," key:@"zongkaiguan" desc:@"Controls all dec Dec/Wrapbag wrap bag-cap grab package" default:NO],
            [CaptureSwitchItem itemWithTitle:@"Network grab bag enhancement network scratcher enhanced web-" key:@"zhaiyaokaiguan" desc:@"Capture capture, catch and URL Reply-responsive and automatically dec" default:NO],
            [CaptureSwitchItem itemWithTitle:@"Encrypt crypt encryption algorithms of the Cryc encrypted" key:@"jiamisuanfakaiguan" desc:@"Records and records of record AES/DES/RSA Alari alqu algorithms call to use an equal" default:NO],
            [CaptureSwitchItem itemWithTitle:@"HMAC Key key capture catch-K keys to" key:@"hanmiyaokaiguan" desc:@"Records and records of record HMAC Key key and abstract summary algorithms for both keys to the" default:NO],
            [CaptureSwitchItem itemWithTitle:@"SSL Certificate caught by certificate to take catch" key:@"ssl3kaiguan" desc:@"Capture capture, catch and SSL/TLS Shake hands c Certificate of Hand holding certificate" default:NO],
            [CaptureSwitchItem itemWithTitle:@"Agent's agent bypasses the agency" key:@"proxy_bypass" desc:@"Dis disabled system-system proxy agent detect detection monitoring pro" default:NO],
            [CaptureSwitchItem itemWithTitle:@"RSA Encrypted encryption, crypt-en" key:@"rsa_encrypt" desc:@"Records and records of record RSA Encrypt encryption encs encryptedo" default:NO],
            [CaptureSwitchItem itemWithTitle:@"RSA Dec decryclassed capture catch-" key:@"rsa_decrypt" desc:@"Records and records of record RSA Decw dec Committee Operations" default:NO],
            [CaptureSwitchItem itemWithTitle:@"RSA Signed signature-sign capture catch" key:@"rsa_sign" desc:@"Records and records of record RSA Sign Signature Operation for signature-signature" default:NO],
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = AVX512Color.primaryBackgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.switchItems.count;
    if (section == 1) return 2;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Function Switch switch turn-off functional function";
    if (section == 1) return @"Data statistics and statistical data for the";
    return @"Data management for data administration and database";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *switchCellId = @"SwitchCell";
    static NSString *statCellId = @"StatCell";
    static NSString *buttonCellId = @"ButtonCell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:switchCellId];
            cell.backgroundColor = AVX512Color.primaryBackgroundColor;
        }
        
        CaptureSwitchItem *item = self.switchItems[indexPath.row];
        cell.textLabel.text = item.title;
        cell.textLabel.textColor = AVX512Color.primaryTextColor;
        cell.detailTextLabel.text = item.desc;
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        cell.detailTextLabel.numberOfLines = 0;
        
        UISwitch *sw = [[UISwitch alloc] init];
        sw.onTintColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        sw.tag = indexPath.row;
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
        BOOL isOn = [[DatabaseManager sharedManager] getSwitch:item.switchKey
                                                      bundleID:bundleID
                                                  defaultValue:item.defaultValue];
        sw.on = isOn;
        
        cell.accessoryView = sw;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:statCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:statCellId];
            cell.backgroundColor = AVX512Color.primaryBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        DatabaseManager *db = [DatabaseManager sharedManager];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Dec dec cip declassified records record";
            NSArray *records = [db queryAllRecordsFromTable:@"decrypt_data" limit:9999];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)records.count];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2 green:0.78 blue:0.4 alpha:1.0];
        } else {
            cell.textLabel.text = @"Al algorithms is the method to call and log records";
            NSArray *records = [db queryAllRecordsFromTable:@"jiamisuanfa" limit:9999];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)records.count];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.78 green:0.4 blue:1.0 alpha:1.0];
        }
        
        cell.textLabel.textColor = AVX512Color.primaryTextColor;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:buttonCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellId];
            cell.backgroundColor = AVX512Color.primaryBackgroundColor;
        }
        cell.textLabel.text = @"Clears all local-local data clearing cleanup";
        cell.textLabel.textColor = UIColor.redColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Confirm confirmed confirm confirmation confirming"
            message:@"Are you sure that all local data, such as decrysing records and key-key record or algorithmal log of any other locally generated files will be removed"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Determines determined clear clean-out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull a) {
            DatabaseManager *db = [DatabaseManager sharedManager];
            [db clearTable:@"decrypt_data"];
            [db clearTable:@"crypto_keys"];
            [db clearTable:@"jiamisuanfa"];
            [db clearTable:@"url_responses"];
            [db clearTable:@"ssl_certificates"];
            [db clearTable:@"ssl_challenges"];
            [db clearTable:@"rsa_data"];
            
            [self.tableView reloadData];
            
            // Send data update notification notice to send the Data Update
            [[NSNotificationCenter defaultCenter]
                postNotificationName:CaptureDataUpdatedNotification
                object:nil
                userInfo:@{CaptureDataUpdatedTableKey: @"all"}];
            
            UIAlertController *done = [UIAlertController
                alertControllerWithTitle:@"Clear cleared clear clean-"
                message:@"All local data has cleared all indigenous native-data"
                preferredStyle:UIAlertControllerStyleAlert];
            [done addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:done animated:YES completion:nil];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    CaptureSwitchItem *item = self.switchItems[sender.tag];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
    [[DatabaseManager sharedManager] setSwitch:item.switchKey
                                      bundleID:bundleID
                                         value:sender.isOn];
    
    NSLog(@"[CaptureSettings] %@ Switch switch switches, turn-off: %@", item.title, sender.isOn ? @"Open, open and opened" : @"Close");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

@end

#pragma mark - Generic List of Universal General-wide list listing tab

@interface CaptureListViewController : AVX512TableViewController

@property (nonatomic, strong) NSArray *allItems;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, strong) NSArray<NSString *> *scopeTitles;
@property (nonatomic) NSInteger currentScope;
@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic, strong) UILabel *statusLabel;

- (instancetype)initWithTableName:(NSString *)tableName
                       scopeTitles:(NSArray<NSString *> *)scopeTitles
                         tintColor:(UIColor *)tintColor;

- (BOOL)matchesScope:(NSInteger)scope text:(NSString *)text;
- (NSString *)firstLineOfText:(NSString *)text;
- (NSString *)detailOfText:(NSString *)text;
- (UIViewController *)detailViewControllerForItem:(NSDictionary *)item;

@end

@implementation CaptureListViewController

- (instancetype)initWithTableName:(NSString *)tableName
                       scopeTitles:(NSArray<NSString *> *)scopeTitles
                         tintColor:(UIColor *)tintColor {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _tableName = [tableName copy];
        _scopeTitles = [scopeTitles copy];
        _tintColor = tintColor;
        _currentScope = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsSearchBar = YES;
    self.pinSearchBar = YES;
    self.showSearchBarInitially = NO;

    if (self.scopeTitles.count > 1) {
        self.searchController.searchBar.showsScopeBar = YES;
        self.searchController.searchBar.scopeButtonTitles = self.scopeTitles;
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 64;
    self.tableView.backgroundColor = AVX512Color.primaryBackgroundColor;

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"CaptureCell"];
    
    // Under Bottom bottom status bar under the underlying state-
    [self setupStatusBar];
    
    // Listen up data update notification notice updates notifications to listen the
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataUpdate:)
                                                 name:CaptureDataUpdatedNotification
                                               object:nil];

    [self reloadData];
}

- (void)setupStatusBar {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    footerView.backgroundColor = AVX512Color.primaryBackgroundColor;
    
    self.statusLabel = [[UILabel alloc] initWithFrame:footerView.bounds];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:11];
    self.statusLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [footerView addSubview:self.statusLabel];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateStatusLabel {
    NSInteger total = self.allItems.count;
    NSInteger filtered = self.filteredItems.count;
    
    NSString *text;
    if (self.searchController.searchBar.text.length > 0 || self.currentScope > 0) {
        text = [NSString stringWithFormat:@"Shows the display of %lu Articles of the articles and / in total, all of %lu Articles of the articles and", (long)filtered, (long)total];
    } else {
        text = [NSString stringWithFormat:@"in total, all of %lu There shall be a record of records", (long)total];
    }
    
    self.statusLabel.text = text;
}

- (void)handleDataUpdate:(NSNotification *)notification {
    NSString *table = notification.userInfo[CaptureDataUpdatedTableKey];
    if ([table isEqualToString:@"all"] || [table isEqualToString:self.tableName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData {
    // Database query database queries are placed to the back-sbackstage line for data base Q
    NSString *tableName = self.tableName;
    NSString *searchText = self.searchController.searchBar.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *items = [[DatabaseManager sharedManager]
            queryAllRecordsFromTable:tableName limit:500];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allItems = items;
            [self filterContentForSearchText:searchText];
            [self.tableView reloadData];
            [self updateStatusLabel];
        });
    });
}

#pragma mark - Search search filter-ssearch Filter

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text];
    [self.tableView reloadData];
    [self updateStatusLabel];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.currentScope = selectedScope;
    [self filterContentForSearchText:searchBar.text];
    [self.tableView reloadData];
    [self updateStatusLabel];
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSString *search = searchText.lowercaseString;
    NSMutableArray *result = [NSMutableArray array];

    for (NSDictionary *item in self.allItems) {
        NSString *text = item[@"longText"] ?: @"";

        if (self.currentScope > 0) {
            if (![self matchesScope:self.currentScope text:text]) {
                continue;
            }
        }

        if (search.length > 0) {
            if (![text.lowercaseString containsString:search]) {
                continue;
            }
        }

        [result addObject:item];
    }

    self.filteredItems = result;
}

- (BOOL)matchesScope:(NSInteger)scope text:(NSString *)text {
    return YES;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CaptureCell" forIndexPath:indexPath];

    NSDictionary *item = self.filteredItems[indexPath.row];
    NSString *text = item[@"longText"] ?: @"";
    NSString *time = item[@"timestamp"] ?: @"";

    cell.textLabel.text = [self firstLineOfText:text];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.textColor = self.tintColor;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    cell.detailTextLabel.text = [self detailOfText:text];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:10];
    cell.detailTextLabel.textColor = AVX512Color.primaryTextColor;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    cell.backgroundColor = AVX512Color.primaryBackgroundColor;
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [AVX512Color secondaryBackgroundColorWithAlpha:0.5];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *item = self.filteredItems[indexPath.row];
    UIViewController *detail = [self detailViewControllerForItem:item];
    [self.navigationController pushViewController:detail animated:YES];
}

- (UIViewController *)detailViewControllerForItem:(NSDictionary *)item {
    NSString *text = item[@"longText"] ?: @"";
    return [[CaptureDetailViewController alloc] initWithText:text title:@"For more details, please"];
}

#pragma mark - Guide to the Help-

- (NSString *)firstLineOfText:(NSString *)text {
    if (text.length == 0) return @"";
    NSRange r = [text rangeOfString:@"\n"];
    if (r.location != NSNotFound) {
        NSString *line = [text substringToIndex:r.location];
        if (line.length > 90) return [line substringToIndex:90];
        return line;
    }
    if (text.length > 90) return [text substringToIndex:90];
    return text;
}

- (NSString *)detailOfText:(NSString *)text {
    if (text.length == 0) return @"";
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSMutableString *preview = [NSMutableString string];
    NSInteger count = 0;
    for (NSString *line in lines) {
        NSString *t = [line stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (t.length == 0) continue;
        count++;
        if (count == 1) continue;
        if (count > 3) break;
        if (preview.length > 0) [preview appendString:@" | "];
        if (t.length > 60) t = [t substringToIndex:60];
        [preview appendString:t];
    }
    return preview;
}

@end

#pragma mark - _ Decu decllylist list

@interface CaptureDecryptListVC : CaptureListViewController
@end

@implementation CaptureDecryptListVC

- (instancetype)init {
    return [self initWithTableName:@"decrypt_data"
                       scopeTitles:@[@"All all Full All", @"Automatic Auto auto-au automatic decrc", @"JSDecode de-coding password dec", @"HTTPS", @"RSA"]
                         tintColor:[UIColor colorWithRed:0.2 green:0.78 blue:0.4 alpha:1.0]];
}

- (BOOL)matchesScope:(NSInteger)scope text:(NSString *)text {
    NSString *low = text.lowercaseString;
    switch (scope) {
        case 1: return [low containsString:@"Automatic Auto auto-au automatic decrc"] || [low containsString:@"autodecrypt"];
        case 2: return [low containsString:@"js"] || [low containsString:@"eval("] ||
                        [low containsString:@"Conf confuse confusion and confusing"] || [low containsString:@"Decode de-coding password dec"];
        case 3: return [low containsString:@"https"] || [low containsString:@"http/"] ||
                        [low containsString:@"Response response responded, responding"];
        case 4: return [low containsString:@"rsa"] || [low containsString:@"seckey"];
        default: return YES;
    }
}

- (UIViewController *)detailViewControllerForItem:(NSDictionary *)item {
    NSString *text = item[@"longText"] ?: @"";
    return [[CaptureDetailViewController alloc] initWithText:text title:@"Dec dec password further details secretconf c"];
}

@end

#pragma mark - Key key listlist of keys-key

@interface CaptureKeyListVC : CaptureListViewController
@end

@implementation CaptureKeyListVC

- (instancetype)init {
    return [self initWithTableName:@"crypto_keys"
                       scopeTitles:@[@"All all Full All", @"AES", @"DES", @"RSA", @"HMAC", @"PBKDF2"]
                         tintColor:[UIColor colorWithRed:1.0 green:0.55 blue:0.1 alpha:1.0]];
}

- (BOOL)matchesScope:(NSInteger)scope text:(NSString *)text {
    NSString *low = text.lowercaseString;
    switch (scope) {
        case 1: return [low containsString:@"aes"];
        case 2: return [low containsString:@"des"] && ![low containsString:@"3des"];
        case 3: return [low containsString:@"rsa"];
        case 4: return [low containsString:@"hmac"];
        case 5: return [low containsString:@"pbkdf2"];
        default: return YES;
    }
}

- (UIViewController *)detailViewControllerForItem:(NSDictionary *)item {
    NSString *text = item[@"longText"] ?: @"";
    return [[CaptureDetailViewController alloc] initWithText:text title:@"Key key Details-keyK K keys"];
}

@end

#pragma mark - Ala algorithms listlist of the

@interface CaptureCryptoListVC : CaptureListViewController
@end

@implementation CaptureCryptoListVC

- (instancetype)init {
    return [self initWithTableName:@"jiamisuanfa"
                       scopeTitles:@[@"All all Full All", @"Encrypt encryption encrypted enc", @"Dec decc Sc", @"Hah-Hhah", @"HMAC", @"Sign Signature Signed signature"]
                         tintColor:[UIColor colorWithRed:0.78 green:0.4 blue:1.0 alpha:1.0]];
}

- (BOOL)matchesScope:(NSInteger)scope text:(NSString *)text {
    NSString *low = text.lowercaseString;
    switch (scope) {
        case 1: return [low containsString:@"encrypt"] || [text containsString:@"Encrypt encryption encs encryptedo"];
        case 2: return [low containsString:@"decrypt"] || [text containsString:@"Decw dec Committee Operations"];
        case 3: return [low containsString:@"md5"] || [low containsString:@"sha"] ||
                        [low containsString:@"cc_md5"] || [low containsString:@"cc_sha"] ||
                        [text containsString:@"Summary of summary summaries"] || [text containsString:@"Hash"];
        case 4: return [low containsString:@"hmac"] || [low containsString:@"cchmac"];
        case 5: return [low containsString:@"sign"] || [text containsString:@"Sign Signature Signed signature"];
        default: return YES;
    }
}

- (UIViewController *)detailViewControllerForItem:(NSDictionary *)item {
    NSString *text = item[@"longText"] ?: @"";
    return [[CaptureDetailViewController alloc] initWithText:text title:@"The algorithm details of the particulars in"];
}

@end

#pragma mark - The main panel vessel container for the primary

@interface CapturePanelViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIPageViewController *pageVC;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation CapturePanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AVX512Color.primaryBackgroundColor;
    self.title = @"Invert Reverse Back-re reverse";
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self
        action:@selector(closeAction)];
    self.navigationItem.leftBarButtonItem = close;

    _segment = [[UISegmentedControl alloc] initWithItems:@[@"Network network networks of online", @"Dec decc Sc", @"Key key keyskey-K K", @"Al algorithms of the ana"]];
    self.segment.selectedSegmentIndex = 0;
    self.segment.tintColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    [self.segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment;

    AVX512NetworkMITMViewController *networkVC = [[AVX512NetworkMITMViewController alloc] init];
    CaptureDecryptListVC *decryptVC = [[CaptureDecryptListVC alloc] init];
    CaptureKeyListVC *keyVC = [[CaptureKeyListVC alloc] init];
    CaptureCryptoListVC *cryptoVC = [[CaptureCryptoListVC alloc] init];

    _viewControllers = @[networkVC, decryptVC, keyVC, cryptoVC];
    _currentIndex = 0;

    _pageVC = [[UIPageViewController alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
        options:nil];
    self.pageVC.dataSource = self;
    self.pageVC.delegate = self;
    [self.pageVC setViewControllers:@[networkVC]
                         direction:UIPageViewControllerNavigationDirectionForward
                          animated:NO
                        completion:nil];

    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    self.pageVC.view.frame = self.view.bounds;
    self.pageVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.pageVC didMoveToParentViewController:self];
    
    [self updateRightBarButtonItems];
    
    // Delaying the execution of weight-weight heavy level operations delayed by delay in performing a weighted mass action is placed to backstage line
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Ensure ensure ensuring that the dec Dec hook Installed already installed (in the back-backstage thread) implemented installation
        [UCDecryptTool installDecryptHooksIfNeeded];
        
        // Ensure ensure that ensuring FLEX Network Listening enabled network listening bugs has been made
        if (!AVX512NetworkObserver.isEnabled) {
            AVX512NetworkObserver.enabled = YES;
        }
    });
    
    // Delays the display of first-time pop window windows to be shown late with a delay in showing their initial release, and when interface rendering is completed after
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self showFirstLaunchAlertIfNeeded];
    });
}

- (void)showFirstLaunchAlertIfNeeded {
    // Check check whether the first-first hint reminder has been shown to see
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
    NSString *hasShownKey = [NSString stringWithFormat:@"capture_first_shown_%@", bundleID];
    BOOL hasShown = [[NSUserDefaults standardUserDefaults] boolForKey:hasShownKey];
    
    if (hasShown) {
        return;
    }
    
    // Displays a functional switch switches on the function to display functions that show
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Invert Reverse Back-re reverse"
        message:@"Welcome to the reverse-inverting assistant!\n\nPlease select a function that needs to be enabled: Select the"
        preferredStyle:UIAlertControllerStyleAlert];
    
    // Adds the general switch statement to add an overall switches
    [alert addAction:[UIAlertAction actionWithTitle:@"All Enable Full Access enable-All (Recommended recommended recommendation for)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enableAllFeatures:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasShownKey];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Only enable only the use of web grab bag to allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enableNetworkOnly];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasShownKey];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"To go to settings setting setup" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self settingsTapped];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasShownKey];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No setting set- settings is yet to" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hasShownKey];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)enableAllFeatures:(BOOL)enable {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
    DatabaseManager *db = [DatabaseManager sharedManager];
    
    NSArray *allSwitches = @[@"zongkaiguan", @"zhaiyaokaiguan", @"jiamisuanfakaiguan",
                              @"hanmiyaokaiguan", @"rsa_encrypt", @"rsa_decrypt", @"rsa_sign"];
    
    for (NSString *key in allSwitches) {
        [db setSwitch:key bundleID:bundleID value:enable];
    }
    
    NSLog(@"[CapturePanel] All functions have already all features,%@", enable ? @"Enable enable-to make" : @"Disabled disabled disable Dis Use dis-");
}

- (void)enableNetworkOnly {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
    DatabaseManager *db = [DatabaseManager sharedManager];
    
    [db setSwitch:@"zongkaiguan" bundleID:bundleID value:YES];
    [db setSwitch:@"zhaiyaokaiguan" bundleID:bundleID value:YES];
    [db setSwitch:@"jiamisuanfakaiguan" bundleID:bundleID value:NO];
    [db setSwitch:@"hanmiyaokaiguan" bundleID:bundleID value:NO];
    [db setSwitch:@"ssl3kaiguan" bundleID:bundleID value:NO];
    [db setSwitch:@"rsa_encrypt" bundleID:bundleID value:NO];
    [db setSwitch:@"rsa_decrypt" bundleID:bundleID value:NO];
    [db setSwitch:@"rsa_sign" bundleID:bundleID value:NO];
    
    NSLog(@"[CapturePanel] Only only enable the web grab wrapboxing function to allow");
}

- (void)updateRightBarButtonItems {
    UIBarButtonItem *settings = [[UIBarButtonItem alloc]
        initWithImage:AVX512Resources.gearIcon
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(settingsTapped)];
    
    UIBarButtonItem *trash = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
        target:self
        action:@selector(trashTapped)];
    trash.tintColor = UIColor.redColor;
    
    self.navigationItem.rightBarButtonItems = @[trash, settings];
}

- (void)settingsTapped {
    CaptureSettingsVC *settings = [[CaptureSettingsVC alloc] init];
    settings.title = @"The functional settings setup of the";
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self
        action:@selector(settingsDoneTapped)];
    settings.navigationItem.rightBarButtonItem = done;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)settingsDoneTapped {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Refresh Updates All List tab list data to refresh the
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[CaptureListViewController class]]) {
            [(CaptureListViewController *)vc reloadData];
        }
    }
}

- (void)trashTapped {
    NSString *title = nil;
    NSString *msg = nil;
    void (^action)(void) = nil;
    
    switch (self.currentIndex) {
        case CaptureTabNetwork: {
            title = @"Clear web log clean-up network records";
            msg = @"Determine determined to clear all network grab bag logs from clean-out of";
            action = ^{
                [AVX512NetworkRecorder.defaultRecorder clearRecordedActivity];
            };
            break;
        }
        case CaptureTabDecrypt: {
            title = @"Clear Dec dec ScC cleans clear decip";
            msg = @"Determine determined that all dec Decs records are cleared and clear of any";
            action = ^{
                [[DatabaseManager sharedManager] clearTable:@"decrypt_data"];
                CaptureDecryptListVC *vc = self.viewControllers[CaptureTabDecrypt];
                [vc reloadData];
                
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:CaptureDataUpdatedNotification
                    object:nil
                    userInfo:@{CaptureDataUpdatedTableKey: @"decrypt_data"}];
            };
            break;
        }
        case CaptureTabKeys: {
            title = @"Clear KeyK key record cleans the &";
            msg = @"Are determined to clear all key logs of the keys are cleared?";
            action = ^{
                [[DatabaseManager sharedManager] clearTable:@"crypto_keys"];
                CaptureKeyListVC *vc = self.viewControllers[CaptureTabKeys];
                [vc reloadData];
                
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:CaptureDataUpdatedNotification
                    object:nil
                    userInfo:@{CaptureDataUpdatedTableKey: @"crypto_keys"}];
            };
            break;
        }
        case CaptureTabCrypto: {
            title = @"Clears the clean-clean algorithm ' s system";
            msg = @"Determine determined that all encryption algorithms call log records to determine the clean-clean clear of";
            action = ^{
                [[DatabaseManager sharedManager] clearTable:@"jiamisuanfa"];
                CaptureCryptoListVC *vc = self.viewControllers[CaptureTabCrypto];
                [vc reloadData];
                
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:CaptureDataUpdatedNotification
                    object:nil
                    userInfo:@{CaptureDataUpdatedTableKey: @"jiamisuanfa"}];
            };
            break;
        }
    }
    
    if (!title) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull a) {
        if (action) action();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    NSInteger newIndex = sender.selectedSegmentIndex;
    if (newIndex == self.currentIndex) return;

    UIPageViewControllerNavigationDirection direction =
        (newIndex > self.currentIndex) ?
        UIPageViewControllerNavigationDirectionForward :
        UIPageViewControllerNavigationDirectionReverse;

    UIViewController *vc = self.viewControllers[newIndex];
    [self.pageVC setViewControllers:@[vc]
                         direction:direction
                          animated:YES
                        completion:^(BOOL finished) {
        self.currentIndex = newIndex;
        [self updateRightBarButtonItems];
    }];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) return nil;
    return self.viewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound || index >= self.viewControllers.count - 1) return nil;
    return self.viewControllers[index + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        UIViewController *current = pageViewController.viewControllers.firstObject;
        NSInteger index = [self.viewControllers indexOfObject:current];
        if (index != NSNotFound) {
            self.currentIndex = index;
            self.segment.selectedSegmentIndex = index;
            [self updateRightBarButtonItems];
        }
    }
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - C Entry-entry function functions for the

void IZXShowDecryptPanelNow(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (!keyWindow) keyWindow = UIApplication.sharedApplication.windows.firstObject;
        if (!keyWindow) return;

        UIViewController *rootVC = keyWindow.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }

        CapturePanelViewController *panel = [[CapturePanelViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:panel];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootVC presentViewController:nav animated:YES completion:nil];
    });
}
