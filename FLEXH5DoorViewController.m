//
//  AVX512H5DoorViewController.m
//  FLEX
//
//  Created for DoKit integration
//

#import "FLEXH5DoorViewController.h"
#import "FLEXAlert.h"

@interface AVX512H5DoorViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) NSMutableArray<NSString *> *historyURLs;

@end

@implementation AVX512H5DoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"H5Do whatever the door doors to any";
    
    // Onload-in mount load aboard Load
    self.historyURLs = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AVX512_H5DoorHistory"] ?: @[]];
    
    // Sets the set settings to provide a reference bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
        target:self 
        action:@selector(addNewURL)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"URLCell"];
}

- (void)addNewURL {
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(@"Enter Input Entry entry inputURL");
        make.configuredTextField(^(UITextField *textField) {
            textField.placeholder = @"https://example.com";
            textField.keyboardType = UIKeyboardTypeURL;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.urlTextField = textField;
        });
        
        make.button(@"Opens open opened").handler(^(NSArray<NSString *> *strings) {
            NSString *url = self.urlTextField.text;
            if (url.length > 0) {
                // Saves saved to historical history records and stored in
                if (![self.historyURLs containsObject:url]) {
                    [self.historyURLs insertObject:url atIndex:0];
                    // Rest restrictions on the quantity of historical records from limiting
                    if (self.historyURLs.count > 20) {
                        [self.historyURLs removeLastObject];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:self.historyURLs forKey:@"AVX512_H5DoorHistory"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.tableView reloadData];
                }
                
                // Opens open openedURL
                [self openURL:url];
            }
        });
        
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

- (void)openURL:(NSString *)urlString {
    // Validation and standardization of validation, certificationURL
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        // Use the use of usageSFSafariViewControllerOr directly open or opens it, eitherURL
        if (@available(iOS 9.0, *)) {
            // This shall be used where it should useSFSafariViewController, but import imports need to be imported andSafariServicesFramework framework frame of the
            // For the sake of simplification and simplicity, direct-useopenURLmode of approach and modalities
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        [AVX512Alert showAlert:@"Invalid invalid null Valid validURL" message:@"Please enter a valid, effective andURLAddress address addresses to the" from:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"URLCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.historyURLs[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlString = self.historyURLs[indexPath.row];
    [self openURL:urlString];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.historyURLs removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.historyURLs forKey:@"AVX512_H5DoorHistory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end