//
//  AVX512NetworkWeakViewController.m
//  FLEX
//
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import "FLEXNetworkWeakViewController.h"
#import "FLEXNetworkWeakTester.h"

@interface AVX512NetworkWeakViewController ()

@property (nonatomic, strong) NSArray *networkTypesList;

@end

@implementation AVX512NetworkWeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Weak web-test test tests for";
    self.networkTypesList = @[
        @{@"title": @"Close", @"type": @(AVX512NetworkWeakTypeNone)},
        @{@"title": @"Too slow, super-slow 2G", @"type": @(AVX512NetworkWeakTypeSlow2G)},
        @{@"title": @"2G Network network networks of online", @"type": @(AVX512NetworkWeakType2G)},
        @{@"title": @"3G Network network networks of online", @"type": @(AVX512NetworkWeakType3G)},
        @{@"title": @"4G Network network networks of online", @"type": @(AVX512NetworkWeakType4G)},
        @{@"title": @"WiFi", @"type": @(AVX512NetworkWeakTypeWifi)},
        @{@"title": @"I've broken off the net", @"type": @(AVX512NetworkWeakTypeDisconnect)}
    ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NetworkTypeCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.networkTypesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkTypeCell" forIndexPath:indexPath];
    
    NSDictionary *networkType = self.networkTypesList[indexPath.row];
    cell.textLabel.text = networkType[@"title"];
    
    // Check check the currently selected network type of networkingtype types to
    AVX512NetworkWeakType currentType = [AVX512NetworkWeakTester sharedInstance].currentWeakType;
    AVX512NetworkWeakType cellType = [networkType[@"type"] integerValue];
    
    cell.accessoryType = (currentType == cellType) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *networkType = self.networkTypesList[indexPath.row];
    AVX512NetworkWeakType type = [networkType[@"type"] integerValue];
    
    if (type == AVX512NetworkWeakTypeNone) {
        [[AVX512NetworkWeakTester sharedInstance] stopWeakNetwork];
    } else {
        [[AVX512NetworkWeakTester sharedInstance] startWeakNetworkWithType:type];
    }
    
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Selects selection network type to select a";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"This function simulates different network environments using late request delay requests and connection limits to model the various networks environment settings\nNote: only use-use uses will have an impactNSURLSessionthe network's request for a web-network";
}

@end