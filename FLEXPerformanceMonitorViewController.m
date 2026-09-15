//
//  AVX512PerformanceMonitorViewController.m
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import "FLEXPerformanceMonitorViewController.h"
#import "FLEXPerformanceMonitor.h"

@interface AVX512PerformanceMonitorViewController ()
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, assign) BOOL isProfiling;
@end

@implementation AVX512PerformanceMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Performance monitoring and performance-monitoring, control";
    
    self.sectionTitles = @[
        @"A methodological performance analytical analysis of methodo-per",
        @"class-into load loading time when to start"
    ];
    
    self.sections = @[@[], @[]];
    self.isProfiling = NO;
    
    UIBarButtonItem *startStopButton = [[UIBarButtonItem alloc] 
                                       initWithTitle:@"Starting to analyze analysis and start analytical" 
                                       style:UIBarButtonItemStylePlain 
                                       target:self 
                                       action:@selector(toggleProfiling)];
    self.navigationItem.rightBarButtonItem = startStopButton;
    
    // Start starting track-tracking class load time to start tracking
    [[AVX512PerformanceMonitor sharedInstance] startTrackingClassLoadTime];
}

- (void)toggleProfiling {
    if (self.isProfiling) {
        // Stop analytical analysis stop par aborting
        [[AVX512PerformanceMonitor sharedInstance] stopMethodProfiling];
        self.navigationItem.rightBarButtonItem.title = @"Starting to analyze analysis and start analytical";
        
        // Take results to get the result from
        NSArray *results = [[AVX512PerformanceMonitor sharedInstance] getProfilingResults];
        NSMutableArray *section0 = [NSMutableArray arrayWithArray:self.sections[0]];
        [section0 addObjectsFromArray:results];
        
        self.sections = @[section0, self.sections[1]];
        [self.tableView reloadData];
    } else {
        // Starting to analyze analysis and start analytical
        [[AVX512PerformanceMonitor sharedInstance] startMethodProfiling];
        self.navigationItem.rightBarButtonItem.title = @"Stop analytical analysis stop par aborting";
    }
    
    self.isProfiling = !self.isProfiling;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Updates the update store loadload-to Load time
    NSArray *classLoadTimes = [[AVX512PerformanceMonitor sharedInstance] getClassLoadTimeInfo];
    self.sections = @[self.sections[0], classLoadTimes];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *sectionArray = self.sections[indexPath.section];
    NSDictionary *item = sectionArray[indexPath.row];
    
    if (indexPath.section == 0) {
        // Methodological performance methodological methodoperability data for the
        cell.textLabel.text = item[@"methodName"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fms", [item[@"executionTime"] doubleValue] * 1000];
    } else {
        // class-into load loading time when to start
        cell.textLabel.text = item[@"className"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fms", [item[@"loadTime"] doubleValue]];
    }
    
    return cell;
}

@end