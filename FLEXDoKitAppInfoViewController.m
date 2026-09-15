#import "FLEXDoKitAppInfoViewController.h"
#import "FLEXCompatibility.h"

@interface AVX512DoKitAppInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *appInfoData;
@end

@implementation AVX512DoKitAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AppInformation InfoInfo information";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupTableView];
    [self loadAppInfo];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AppInfoCell"];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self)],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadAppInfo {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDictionary = mainBundle.infoDictionary;
    UIDevice *device = [UIDevice currentDevice];
    
    NSMutableArray *sections = [NSMutableArray array];
    
    // AppBasic basic information on the basis essential
    NSMutableArray *appInfo = [NSMutableArray array];
    [appInfo addObject:@{@"title": @"Apply a name application to apply the", @"value": infoDictionary[@"CFBundleDisplayName"] ?: infoDictionary[@"CFBundleName"] ?: @"Unknown"}];
    [appInfo addObject:@{@"title": @"Bundle ID", @"value": infoDictionary[@"CFBundleIdentifier"] ?: @"Unknown"}];
    [appInfo addObject:@{@"title": @"Version", @"value": infoDictionary[@"CFBundleShortVersionString"] ?: @"Unknown"}];
    [appInfo addObject:@{@"title": @"BuildNo. no, number", @"value": infoDictionary[@"CFBundleVersion"] ?: @"Unknown"}];
    [appInfo addObject:@{@"title": @"BundlePath path paths to the", @"value": mainBundle.bundlePath}];
    [sections addObject:@{@"title": @"App Info", @"items": appInfo}];
    
    // Device info equipment information device for
    NSMutableArray *deviceInfo = [NSMutableArray array];
    [deviceInfo addObject:@{@"title": @"Device Name", @"value": device.name}];
    [deviceInfo addObject:@{@"title": @"Model", @"value": device.model}];
    [deviceInfo addObject:@{@"title": @"System system name names for the systematic", @"value": device.systemName}];
    [deviceInfo addObject:@{@"title": @"System Version", @"value": device.systemVersion}];
    [deviceInfo addObject:@{@"title": @"Localized Model", @"value": device.localizedModel}];
    [sections addObject:@{@"title": @"Device Info", @"items": deviceInfo}];
    
    // ScreenIn Information on screen-screen
    UIScreen *screen = [UIScreen mainScreen];
    NSMutableArray *screenInfo = [NSMutableArray array];
    [screenInfo addObject:@{@"title": @"ScreenSscreen-size screens", @"value": NSStringFromCGSize(screen.bounds.size)}];
    [screenInfo addObject:@{@"title": @"Screen Scale on screen scale-scale", @"value": NSStringFromCGSize(screen.nativeBounds.size)}];
    [screenInfo addObject:@{@"title": @"P-Pi pixels of", @"value": [NSString stringWithFormat:@"%.1fx", screen.scale]}];
    [screenInfo addObject:@{@"title": @"Brightness brightening and lightity", @"value": [NSString stringWithFormat:@"%.2f", screen.brightness]}];
    [sections addObject:@{@"title": @"ScreenIn Information on screen-screen", @"items": screenInfo}];
    
    self.appInfoData = [sections copy];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.appInfoData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.appInfoData[section];
    return [sectionData[@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.appInfoData[section];
    return sectionData[@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AppInfoCell"];
    
    NSDictionary *sectionData = self.appInfoData[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"value"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Sets settings to set the font and color for
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = AVX512SecondaryLabelColor;
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Copy copy to the clipboard runup-to Clip
    NSDictionary *sectionData = self.appInfoData[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    NSString *valueText = item[@"value"];
    if (valueText && valueText.length > 0) {
        [UIPasteboard generalPasteboard].string = valueText;
        
        // Displays the display to show that a copy replication
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Copy copied copy- over" 
                                                                       message:[NSString stringWithFormat:@"Copy copied copy- over \"%@\" To go to the clipboard Board of C", item[@"title"]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

@end