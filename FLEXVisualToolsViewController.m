//
//  AVX512VisualToolsViewController.m
//  FLEX
//
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import "FLEXVisualToolsViewController.h"
#import "FLEXColorPickerTool.h"
#import "FLEXRulerTool.h"

@interface AVX512VisualToolsViewController ()

@property (nonatomic, strong) NSArray *toolsList;

@end

@implementation AVX512VisualToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Visual visual tools for video-visual";
    self.toolsList = @[
        @{@"title": @"Colour to colour picker for color-to and", @"detail": @"Picks the colour color colors on your screen to pick"},
        @{@"title": @"Alignment alignment to align the rule rules of", @"detail": @"To measure the measurement ofUIThe size-size dimensions of the element"}
    ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ToolCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toolsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToolCell" forIndexPath:indexPath];
    
    NSDictionary *tool = self.toolsList[indexPath.row];
    cell.textLabel.text = tool[@"title"];
    cell.detailTextLabel.text = tool[@"detail"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: // Colour to colour picker for color-to and
            [self dismissViewControllerAnimated:YES completion:^{
                [[AVX512ColorPickerTool sharedInstance] show];
            }];
            break;
            
        case 1: // Alignment alignment to align the rule rules of
            [self dismissViewControllerAnimated:YES completion:^{
                [[AVX512RulerTool sharedInstance] show];
            }];
            break;
            
        default:
            break;
    }
}

@end