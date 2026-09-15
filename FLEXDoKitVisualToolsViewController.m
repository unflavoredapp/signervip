#import "FLEXDoKitVisualToolsViewController.h"
#import "FLEXDoKitVisualTools.h"
#import "FLEXLookinMeasureController.h"

@interface AVX512DoKitVisualToolsViewController ()
@property (nonatomic, strong) NSArray *visualTools;
@end

@implementation AVX512DoKitVisualToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Visual visual tools for video-visual";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.visualTools = @[
        @{@"title": @"Colour-colored straws in colour", @"detail": @"Screen-sscreen colouring tool to the screen", @"action": @"showColorPicker"},
        @{@"title": @"Alignment alignment to align the rule rules of", @"detail": @"UIMeasurement tool tools to measure the measurement", @"action": @"showRuler"},
        @{@"title": @"View views view border frame box for the", @"detail": @"Shows a display of the view views View Views", @"action": @"showViewBorders"},
        @{@"title": @"laid, well- but layout and", @"detail": @"Show Layout show layouts to display Boot board", @"action": @"showLayoutBounds"},
        @{@"title": @"LookinTo measure the measurement of", @"detail": @"Accu precise distance-t range measure", @"action": @"showLookinMeasure"}
    ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"VisualToolCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.visualTools.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VisualToolCell" forIndexPath:indexPath];
    
    NSDictionary *tool = self.visualTools[indexPath.row];
    cell.textLabel.text = tool[@"title"];
    cell.detailTextLabel.text = tool[@"detail"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Set the setting of acellStyle styles to the
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VisualToolCell"];
    cell.textLabel.text = tool[@"title"];
    cell.detailTextLabel.text = tool[@"detail"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *tool = self.visualTools[indexPath.row];
    NSString *action = tool[@"action"];
    
    SEL actionSelector = NSSelectorFromString(action);
    if ([self respondsToSelector:actionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:actionSelector];
#pragma clang diagnostic pop
    }
}

#pragma mark - Actions

- (void)showColorPicker {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AVX512DoKitVisualTools sharedInstance] startColorPicker];
    }];
}

- (void)showRuler {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AVX512DoKitVisualTools sharedInstance] showRuler];
    }];
}

- (void)showViewBorders {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AVX512DoKitVisualTools sharedInstance] showViewBorders];
    }];
}

- (void)showLayoutBounds {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AVX512DoKitVisualTools sharedInstance] showLayoutBounds];
    }];
}

- (void)showLookinMeasure {
    [self dismissViewControllerAnimated:YES completion:^{
        [[AVX512LookinMeasureController sharedInstance] startMeasuring];
    }];
}

@end