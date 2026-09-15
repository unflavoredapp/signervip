#import "FLEXDoKitUserDefaultsViewController.h"
#import "FLEXCompatibility.h"  // ✅ Add Compcomp compatibility compatible headhead first-file addition

@interface AVX512DoKitUserDefaultsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>  // ✅ Add added add to theUISearchBarDelegateAgreement to and agreement between
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *userDefaultsKeys;
@property (nonatomic, strong) NSArray *filteredKeys;
@end

@implementation AVX512DoKitUserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"UserDefaults";
    self.view.backgroundColor = AVX512SystemBackgroundColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    [self setupNavigationBar];
    [self setupSearchBar];
    [self setupTableView];
    [self loadUserDefaults];
}

- (void)setupNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                             target:self 
                                             action:@selector(refreshUserDefaults)];
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search search for key-search keyword name...";
    self.searchBar.delegate = self;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UserDefaultsCell"];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self)],  // ✅ Use the use compatibility compatible-compability function to
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadUserDefaults {
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    self.userDefaultsKeys = [defaults.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.filteredKeys = self.userDefaultsKeys;
    [self.tableView reloadData];
}

- (void)refreshUserDefaults {
    [self loadUserDefaults];
}

- (NSString *)stringValueForKey:(NSString *)key {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    } else if ([value isKindOfClass:[NSArray class]]) {
        return [NSString stringWithFormat:@"Array(%lu items)", (unsigned long)[value count]];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        return [NSString stringWithFormat:@"Dictionary(%lu keys)", (unsigned long)[value count]];
    } else if ([value isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        return [formatter stringFromDate:value];
    } else if ([value isKindOfClass:[NSData class]]) {
        return [NSString stringWithFormat:@"Data(%lu bytes)", (unsigned long)[value length]];
    } else {
        return [value description] ?: @"(null)";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserDefaultsCell"];
    
    // ✅ Strict border checks and strict control of the
    if (indexPath.row >= self.filteredKeys.count || indexPath.row < 0) {
        cell.textLabel.text = @"⚠️ Error data indexing error wrong DataIn";
        cell.textLabel.textColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Index indexes to the: %ld, The segment length of the array ' s: %lu", 
                                   (long)indexPath.row, (unsigned long)self.filteredKeys.count];
        return cell;
    }
    
    NSString *key = self.filteredKeys[indexPath.row];
    NSString *value = [self stringValueForKey:key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    cell.detailTextLabel.numberOfLines = 2;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // ✅ Border border inspection and surveillance of the
    if (indexPath.row >= self.filteredKeys.count) {
        return;
    }
    
    NSString *key = self.filteredKeys[indexPath.row];
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:key 
                                                                   message:[self stringValueForKey:key]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Copy copy copied button to duplicate the
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy copy-copy duplicate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].string = [self stringValueForKey:key];
    }];
    
    // To delete the button to
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete to delete deleted" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadUserDefaults];
    }];
    
    // Edit the editing button to edit editor (Limit only to string strings and numerical Strings &)
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit Editor edit editing editorial" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self editValueForKey:key currentValue:value];
        }];
        [alert addAction:editAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:copyAction];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editValueForKey:(NSString *)key currentValue:(id)value {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Edit Editor edit editing editorial %@", key]
                                                                   message:@"Enter the input new value to enter a"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [value description];
        textField.placeholder = @"The new value of the";
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save and save the saving" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *newValue = alert.textFields.firstObject.text;
        
        // Try to keep the original type-type and try
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *numberValue = [formatter numberFromString:newValue];
            if (numberValue) {
                [[NSUserDefaults standardUserDefaults] setObject:numberValue forKey:key];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadUserDefaults];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredKeys = self.userDefaultsKeys;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
        self.filteredKeys = [self.userDefaultsKeys filteredArrayUsingPredicate:predicate];
    }
    
    [self.tableView reloadData];
}

@end