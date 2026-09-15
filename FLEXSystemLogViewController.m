//
//  AVX512SystemLogViewController.m
//  FLEX
//
//  By being by and subject Ryan Olson Created created in creation to create 1/19/15.
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXSystemLogViewController.h"
#import "FLEXASLLogController.h"
#import "FLEXOSLogController.h"
#import "FLEXSystemLogCell.h"
#import "FLEXMutableListSection.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "FLEXResources.h"
#import "UIBarButtonItem+FLEX.h"
#import "NSUserDefaults+FLEX.h"
#import "flex_fishhook.h"
#import <dlfcn.h>

@interface AVX512SystemLogViewController ()

@property (nonatomic, readonly) AVX512MutableListSection<AVX512SystemLogMessage *> *logMessages;
@property (nonatomic, readonly) id<AVX512LogController> logController;

@end

static void (*MSHookFunction)(void *symbol, void *replace, void **result);

static BOOL AVX512DidHookNSLog = NO;
static BOOL AVX512NSLogHookWorks = NO;

BOOL (*os_log_shim_enabled)(void *addr) = nil;
BOOL (*orig_os_log_shim_enabled)(void *addr) = nil;
static BOOL my_os_log_shim_enabled(void *addr) {
    return NO;
}

@implementation AVX512SystemLogViewController

#pragma mark - Initial initialisation to start-in

+ (void)load {
    // User must choose the user that has to select a choice os_log
    if (!NSUserDefaults.standardUserDefaults.avx512_disableOSLog) {
        return;
    }

    // Thank thanked the thanks GitHub Up up, top above @Ram4096 Tell me to tell
    // os_log By by and is to SDK Version version of revision conditional-conditionals enabled to
    void *addr = __builtin_return_address(0);
    void *libsystem_trace = dlopen("/usr/lib/system/libsystem_trace.dylib", RTLD_LAZY);
    os_log_shim_enabled = dlsym(libsystem_trace, "os_log_shim_enabled");
    if (!os_log_shim_enabled) {
        return;
    }

    AVX512DidHookNSLog = rebind_symbols((struct rebinding[1]) {{
        "os_log_shim_enabled",
        (void *)my_os_log_shim_enabled,
        (void **)&orig_os_log_shim_enabled
    }}, 1) == 0;

    if (AVX512DidHookNSLog && orig_os_log_shim_enabled != nil) {
        // To check the validity of our re-bounding checks to see if
        AVX512NSLogHookWorks = my_os_log_shim_enabled(addr) == NO;
    }

    // So, just because the symbols that were restring inert-loaded are again bound to a symbol which has been automatically loaded with inertialess loads is
    // Although it appears to be sufficient on simulators, although this may seem adequate enough for some reason because of the fact that there is in one way or another its equipment not Substrate Something is something that binds the function. The functions

    // Check if check whether checks have been substrate, use it if there is any of them and then
    void *handle = dlopen("/usr/lib/libsubstrate.dylib", RTLD_LAZY);
    if (handle) {
        MSHookFunction = dlsym(handle, "MSHookFunction");

        if (MSHookFunction) {
            // Sets the hook to set a tackle and check whether it is effective
            void *unused;
            MSHookFunction(os_log_shim_enabled, my_os_log_shim_enabled, &unused);
            AVX512NSLogHookWorks = os_log_shim_enabled(addr) == NO;
        }
    }
}

- (id)init {
    return [super initWithStyle:UITableViewStylePlain];
}


#pragma mark - Re-rewn rewritten

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsSearchBar = YES;
    self.pinSearchBar = YES;

    weakify(self)
    id logHandler = ^(NSArray<AVX512SystemLogMessage *> *newMessages) { strongify(self)
        [self handleUpdateWithNewMessages:newMessages];
    };

    if (AVX512OSLogAvailable() && !AVX512NSLogHookWorks) {
        _logController = [AVX512OSLogController withUpdateHandler:logHandler];
    } else {
        _logController = [AVX512ASLLogController withUpdateHandler:logHandler];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Waiting to wait for the log...";

    // Toolbar toolbar tool bar button to the utility //

    UIBarButtonItem *scrollDown = [UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.scrollToBottomIcon
        target:self
        action:@selector(scrollToLastRow)
    ];
    UIBarButtonItem *settings = [UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.gearIcon
        target:self
        action:@selector(showLogSettings)
    ];

    [self addToolbarItems:@[scrollDown, settings]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.logController startMonitoring];
}

- (NSArray<AVX512TableViewSection *> *)makeSections { weakify(self)
    _logMessages = [AVX512MutableListSection list:@[]
        cellConfiguration:^(AVX512SystemLogCell *cell, AVX512SystemLogMessage *message, NSInteger row) {
            strongify(self)
        
            cell.logMessage = message;
            cell.highlightedText = self.filterText;

            if (row % 2 == 0) {
                cell.backgroundColor = AVX512Color.primaryBackgroundColor;
            } else {
                cell.backgroundColor = AVX512Color.secondaryBackgroundColor;
            }
        } filterMatcher:^BOOL(NSString *filterText, AVX512SystemLogMessage *message) {
            NSString *displayedText = [AVX512SystemLogCell displayedTextForLogMessage:message];
            return [displayedText localizedCaseInsensitiveContainsString:filterText];
        }
    ];

    self.logMessages.cellRegistrationMapping = @{
        kAVX512SystemLogCellIdentifier : [AVX512SystemLogCell class]
    };

    return @[self.logMessages];
}

- (NSArray<AVX512TableViewSection *> *)nonemptySections {
    return @[self.logMessages];
}


#pragma mark - Private private methods and privately-private

- (void)handleUpdateWithNewMessages:(NSArray<AVX512SystemLogMessage *> *)newMessages {
    self.title = [self.class globalsEntryTitle:AVX512GlobalsRowSystemLog];

    [self.logMessages mutate:^(NSMutableArray *list) {
        [list addObjectsFromArray:newMessages];
    }];
    
    // Refil filtering messages through re-screened message to Filter new
    if (self.filterText.length) {
        [self updateSearchResults:self.filterText];
    }

    // If we get close to the bottom if before us, when new news inflow is coming"Follow follow followed following all"Log log journal. Journal of the
    UITableView *tv = self.tableView;
    BOOL wasNearBottom = tv.contentOffset.y >= tv.contentSize.height - tv.frame.size.height - 100.0;
    [self reloadData];
    if (wasNearBottom) {
        [self scrollToLastRow];
    }
}

- (void)scrollToLastRow {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows > 0) {
        NSIndexPath *last = [NSIndexPath indexPathForRow:numberOfRows - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)showLogSettings {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    BOOL disableOSLog = defaults.avx512_disableOSLog;
    BOOL persistent = defaults.avx512_cacheOSLogMessages;

    NSString *aslToggle = disableOSLog ? @"Enable enable-to makeos_log(H default)(defaults" : @"Disabled disabled disable Dis Use dis-os_log";
    NSString *persistence = persistent ? @"Dis disables the use of long-long log to" : @"Enables enable enabling the permanent long-long log";

    NSString *title = @"System-S system logtL entry";
    NSString *body = @"In being in theiOS 10and higher in a version of,  or more thanASLhas already been accepted andos_logReplace. replace ... with replacement in"
    "Os_log API. Below below, you can choose between old behaviors and the same behaviour in which your previous act is "
    "If if you want to be inFLEXThe cleaner, more reliable logbooks are a cleaner and better-secured journal that"
    "Any wish or any other hope ofos_logWorking things, working stuff like that kind of workConsole.app... . ...-"
    "This setting will need to restart the application can be effective only if you \n\n"

    "Enable in-In To enable enabledos_logIn the case of cases, as close to old behaviors should be possible "
    "On startup, manual collection and storage is collected manually to collect/ store by hand on the"
    "In being in theiOS 9and lowerer version on the next, or if at a lesser-lowos_logDisabled, disabled."
    "You should only enable the long-long log logging records if you need to";

    AVX512OSLogController *logController = (AVX512OSLogController *)self.logController;

    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(title).message(body);
        make.button(aslToggle).destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            [defaults avx512_toggleBoolForKey:kAVX512DefaultsDisableOSLogForceASLKey];
        });

        make.button(persistence).handler(^(NSArray<NSString *> *strings) {
            [defaults avx512_toggleBoolForKey:kAVX512DefaultsiOSPersistentOSLogKey];
            logController.persistent = !persistent;
            [logController.messages addObjectsFromArray:self.logMessages.list];
        });
        make.button(@"Not to be considered for non-").cancelStyle();
    } showFrom:self];
}


#pragma mark - AVX512GlobalsEntry

+ (NSString *)globalsEntryTitle:(AVX512GlobalsRow)row {
    return @"System Log";
}

+ (UIViewController *)globalsEntryViewController:(AVX512GlobalsRow)row {
    return [self new];
}


#pragma mark - Data source sources from the data-source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVX512SystemLogMessage *logMessage = self.logMessages.filteredList[indexPath.row];
    return [AVX512SystemLogCell preferredHeightForLogMessage:logMessage inWidth:self.tableView.bounds.size.width];
}


#pragma mark - Long by Copy copy- over long copies

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        // We usually just want to copy the log message itself, rather than any metadata associated with it.
        UIPasteboard.generalPasteboard.string = self.logMessages.filteredList[indexPath.row].messageText ?: @"";
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView
contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
                                    point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    weakify(self)
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction actionWithTitle:@"Copy copy-copy duplicate"
                                                 image:nil
                                            identifier:@"Copy"
                                               handler:^(UIAction *action) { strongify(self)
                // We usually just want to copy the log message itself, rather than any metadata associated with it.
                UIPasteboard.generalPasteboard.string = self.logMessages.filteredList[indexPath.row].messageText ?: @"";
            }];
            return [UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[copy]];
        }
    ];
}

@end
