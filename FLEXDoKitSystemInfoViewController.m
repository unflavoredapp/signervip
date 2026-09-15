#import "FLEXDoKitSystemInfoViewController.h"
#import "FLEXCompatibility.h"
#import <sys/utsname.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/proc.h>

@interface AVX512DoKitSystemInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *systemInfoData;
@end

@implementation AVX512DoKitSystemInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"System information system for systematic info";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupTableView];
    [self loadSystemInfo];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SystemInfoCell"];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self)],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadSystemInfo {
    NSMutableArray *sections = [NSMutableArray array];
    
    // System information system for systematic info
    NSMutableArray *systemInfo = [NSMutableArray array];
    struct utsname systemInfo_c;
    uname(&systemInfo_c);
    
    [systemInfo addObject:@{@"title": @"ker core name for the inner nuclear", @"value": [NSString stringWithCString:systemInfo_c.sysname encoding:NSUTF8StringEncoding]}];
    [systemInfo addObject:@{@"title": @"No no point Point Name name of the", @"value": [NSString stringWithCString:systemInfo_c.nodename encoding:NSUTF8StringEncoding]}];
    [systemInfo addObject:@{@"title": @"The ker core version of the inside", @"value": [NSString stringWithCString:systemInfo_c.release encoding:NSUTF8StringEncoding]}];
    [systemInfo addObject:@{@"title": @"The ker core build-up built", @"value": [NSString stringWithCString:systemInfo_c.version encoding:NSUTF8StringEncoding]}];
    [systemInfo addObject:@{@"title": @"Hard hardware platform for the hardware", @"value": [NSString stringWithCString:systemInfo_c.machine encoding:NSUTF8StringEncoding]}];
    [sections addObject:@{@"title": @"Nuclear nuclear systems within the system'", @"items": systemInfo}];
    
    // Memory Info to memory information stored in 
    NSMutableArray *memoryInfo = [NSMutableArray array];
    vm_size_t page_size;
    mach_port_t mach_port = mach_host_self();
    host_page_size(mach_port, &page_size);
    
    vm_statistics64_data_t vm_stat;
    mach_msg_type_number_t host_size = sizeof(vm_statistics64_data_t) / sizeof(natural_t);
    host_statistics64(mach_port, HOST_VM_INFO, (host_info64_t)&vm_stat, &host_size);
    
    uint64_t total_memory = [NSProcessInfo processInfo].physicalMemory;
    uint64_t used_memory = (uint64_t)(vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * page_size;
    uint64_t free_memory = total_memory - used_memory;
    
    [memoryInfo addObject:@{@"title": @"Total Memory", @"value": [self formatBytes:total_memory]}];
    [memoryInfo addObject:@{@"title": @"Used use-used usage", @"value": [self formatBytes:used_memory]}];
    [memoryInfo addObject:@{@"title": @"Available memory that can be available to the", @"value": [self formatBytes:free_memory]}];
    [memoryInfo addObject:@{@"title": @"Page size of a page with the", @"value": [self formatBytes:page_size]}];
    [sections addObject:@{@"title": @"Memory Info to memory information stored in ", @"items": memoryInfo}];
    
    // Processor processer for handler information - To restore Format formatting error-forming bug
    NSMutableArray *cpuInfo = [NSMutableArray array];
    [cpuInfo addObject:@{@"title": @"Process processer number of handler quantity", @"value": [NSString stringWithFormat:@"%lu", (unsigned long)[NSProcessInfo processInfo].processorCount]}];
    [cpuInfo addObject:@{@"title": @"Actively active processr for dynamic processing", @"value": [NSString stringWithFormat:@"%lu", (unsigned long)[NSProcessInfo processInfo].activeProcessorCount]}];
    [sections addObject:@{@"title": @"Processor processer for handler information", @"items": cpuInfo}];
    
    // Run run-time running of the ran - To restore running run-time time calculation to repair
    NSMutableArray *runtimeInfo = [NSMutableArray array];
    [runtimeInfo addObject:@{@"title": @"System system start-up time to S", @"value": [self formatUptime:[NSProcessInfo processInfo].systemUptime]}];
    
    // To restore process running time run-time calculation of the
    NSTimeInterval processUptime = [[NSDate date] timeIntervalSince1970] - [[NSProcessInfo processInfo] systemUptime];
    [runtimeInfo addObject:@{@"title": @"Process run running time-time to start", @"value": [self formatUptime:processUptime]}];
    [runtimeInfo addObject:@{@"title": @"Process process processes of theID", @"value": [NSString stringWithFormat:@"%d", [NSProcessInfo processInfo].processIdentifier]}];
    [sections addObject:@{@"title": @"Run run-time running of the ran", @"items": runtimeInfo}];
    
    self.systemInfoData = [sections copy];
    [self.tableView reloadData];
}

- (NSString *)formatBytes:(uint64_t)bytes {
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%llu B", bytes];
    } else if (bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", bytes / 1024.0];
    } else if (bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f MB", bytes / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0)];
    }
}

- (NSString *)formatUptime:(NSTimeInterval)uptime {
    int days = (int)(uptime / (24 * 3600));
    int hours = (int)((uptime - days * 24 * 3600) / 3600);
    int minutes = (int)((uptime - days * 24 * 3600 - hours * 3600) / 60);
    
    if (days > 0) {
        return [NSString stringWithFormat:@"%dHeavens, days %dHour hours, hour and %dmin minutes minute Minutes", days, hours, minutes];
    } else if (hours > 0) {
        return [NSString stringWithFormat:@"%dHour hours, hour and %dmin minutes minute Minutes", hours, minutes];
    } else {
        return [NSString stringWithFormat:@"%dmin minutes minute Minutes", minutes];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.systemInfoData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.systemInfoData[section];
    return [sectionData[@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.systemInfoData[section];
    return sectionData[@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SystemInfoCell"];
    
    NSDictionary *sectionData = self.systemInfoData[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"value"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end