#import "FLEXDoKitLogViewController.h"

@interface AVX512DoKitLogViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *logEntries;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredLogs;
@property (nonatomic, strong) UISwitch *autoScrollSwitch;
@property (nonatomic, assign) NSUInteger lastLogIndex;
@end

@implementation AVX512DoKitLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Real-real real time, live";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.logEntries = [NSMutableArray array];
    [self setupUI];
    [self startLogMonitoring];
}

- (void)setupUI {
    // Search search column for the search
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search search log Log content for search";
    self.searchBar.delegate = self;
    
    // Auto autoroll automatically scrolling the automatic roll-
    self.autoScrollSwitch = [[UISwitch alloc] init];
    self.autoScrollSwitch.on = YES;
    
    UILabel *scrollLabel = [[UILabel alloc] init];
    scrollLabel.text = @"Auto auto-automatic automatic rolling automatically";
    scrollLabel.font = [UIFont systemFontOfSize:14];
    
    UIStackView *controlStack = [[UIStackView alloc] initWithArrangedSubviews:@[scrollLabel, self.autoScrollSwitch]];
    controlStack.axis = UILayoutConstraintAxisHorizontal;
    controlStack.spacing = 10;
    
    // Table table view of the tables,
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogCell"];
    
    // Clears the rin clean button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithTitle:@"Clear clear clean- and" 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(clearLogs)];
    
    // Layout layout-B lay
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    controlStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:controlStack];
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [controlStack.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:10],
        [controlStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [controlStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.tableView.topAnchor constraintEqualToAnchor:controlStack.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)startLogMonitoring {
    // Re-directed Control Con Orientation controller platform log entry to file files
    [self redirectConsoleLogToDocuments];
    
    // Starts the regular periodic reading read-ret regularly
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(readLogFile)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)redirectConsoleLogToDocuments {
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count == 0) {
            NSLog(@"❌ Could not fetch cannot access failed unDocumentsDirectory Contents directory engagement");
            return;
        }
        
        NSString *documentsDirectory = paths.firstObject;
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"avx512_console.log"];
        
        // Checks file path to check files access permission checking
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager isWritableFileAtPath:documentsDirectory]) {
            NSLog(@"❌ DocumentsThe directory of contents in a non");
            return;
        }
        
        // Check check inspection Inspection inspectionsfreopenReturns return value returns the returned values
        FILE *logFile = freopen([logPath UTF8String], "a", stderr);
        if (logFile == NULL) {
            NSLog(@"❌ Log redirecting has failed failure to log Re: %s", strerror(errno));
            return;
        }
        
        // Sets settings set setting Settings for the BS
        setbuf(logFile, NULL);  // No buffer, no cushions. Write immediately to write
        
        NSLog(@"✅ Log redirecting was successfully successful and the log: %@", logPath);
        
    } @catch (NSException *exception) {
        NSLog(@"❌ Log redirecting red-ret redirected: %@", exception.reason);
        
        // Atypical recovery mechanism for abnormal rehabilitation mechanisms
        freopen("/dev/stderr", "a", stderr);
    }
}

- (void)readLogFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *newLogEntries = [NSMutableArray array];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count == 0) return;
        
        NSString *documentsDirectory = paths.firstObject;
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"avx512_console.log"];
        
        // Check to check if a file exists or
        if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
            return;
        }
        
        NSError *error;
        NSString *logContent = [NSString stringWithContentsOfFile:logPath 
                                                         encoding:NSUTF8StringEncoding 
                                                            error:&error];
        
        if (error) {
            NSLog(@"❌ Failed to read Log log file document failed while reading the: %@", error.localizedDescription);
            return;
        }
        
        if (!logContent || logContent.length == 0) {
            return;
        }
        
        // Resolution resolution of the log-log content to resolve
        NSArray *logLines = [logContent componentsSeparatedByString:@"\n"];
        
        for (NSString *line in logLines) {
            if (line.length > 0) {
                NSDictionary *logEntry = [self parseLogLine:line];
                if (logEntry) {
                    [newLogEntries addObject:logEntry];
                }
            }
        }
        
        // ✅ Fix repair: Correct code block structural structure of the correct box
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(self.logEntries) {
                [self.logEntries addObjectsFromArray:newLogEntries];
                
                // Limit the number of logs to limit Log numbers and prevent over-exes from
                if (self.logEntries.count > 1000) {
                    NSRange removeRange = NSMakeRange(0, self.logEntries.count - 1000);
                    [self.logEntries removeObjectsInRange:removeRange];
                }
                
                [self filterLogs];
                [self.tableView reloadData];
                
                // Auto auto-automatic scroll automatically rolls an automatic
                if (self.autoScrollSwitch.isOn && self.filteredLogs.count > 0) {
                    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.filteredLogs.count - 1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
            }
        });
    });
}

- (NSDictionary *)parseLogLine:(NSString *)line {
    // Simple simple loglog format resolution for a simplified plain Log journal[Time timetime and space] level levels of the grade: Messages news about the
    NSRange bracketRange = [line rangeOfString:@"]"];
    if (bracketRange.location != NSNotFound) {
        NSString *timestamp = [line substringToIndex:bracketRange.location + 1];
        NSString *remaining = [line substringFromIndex:bracketRange.location + 1];
        
        // Find find a level to search for
        NSArray *levels = @[@"ERROR", @"WARNING", @"INFO", @"DEBUG"];
        NSString *level = @"INFO";
        NSString *message = remaining;
        
        for (NSString *levelString in levels) {
            if ([remaining containsString:levelString]) {
                level = levelString;
                NSRange levelRange = [remaining rangeOfString:levelString];
                message = [remaining substringFromIndex:levelRange.location + levelRange.length];
                break;
            }
        }
        
        return @{
            @"timestamp": timestamp,
            @"level": level,
            @"message": [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
        };
    }
    
    return @{
        @"timestamp": @"",
        @"level": @"INFO",
        @"message": line
    };
}

- (void)filterLogs {
    if (self.searchBar.text.length == 0) {
        self.filteredLogs = [self.logEntries copy];
    } else {
        NSString *searchText = self.searchBar.text.lowercaseString;
        self.filteredLogs = [self.logEntries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *log, NSDictionary *bindings) {
            NSString *message = log[@"message"] ?: @"";
            return [message.lowercaseString containsString:searchText];
        }]];
    }
}

- (void)clearLogs {
    @synchronized(self.logEntries) {
        [self.logEntries removeAllObjects];
        [self filterLogs];
        [self.tableView reloadData];
    }
    
    // Empty empty log Loglog file files to empt
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString *documentsDirectory = paths.firstObject;
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"avx512_console.log"];
        [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @synchronized(self.logEntries) {
        return self.filteredLogs.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @synchronized(self.logEntries) {
        // Strict border checks and strict control of the
        if (indexPath.row >= self.filteredLogs.count) {
            UITableViewCell *errorCell = [[UITableViewCell alloc] init];
            errorCell.textLabel.text = @"⚠️ Error data indexing error wrong DataIn";
            errorCell.textLabel.textColor = [UIColor systemRedColor];
            return errorCell;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
        NSDictionary *logEntry = self.filteredLogs[indexPath.row];
        
        NSString *timestamp = logEntry[@"timestamp"] ?: @"";
        NSString *level = logEntry[@"level"] ?: @"INFO";
        NSString *message = logEntry[@"message"] ?: @"";
        
        cell.textLabel.text = message;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", timestamp, level];
        cell.textLabel.numberOfLines = 0;
        
        // A colour color setting of the colors to set a
        if ([level isEqualToString:@"ERROR"]) {
            cell.textLabel.textColor = [UIColor systemRedColor];
        } else if ([level isEqualToString:@"WARNING"]) {
            cell.textLabel.textColor = [UIColor systemOrangeColor];
        } else {
            cell.textLabel.textColor = [UIColor labelColor];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterLogs];
    [self.tableView reloadData];
}

@end