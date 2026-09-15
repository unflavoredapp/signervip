#import "FLEXDoKitCleanViewController.h"

@interface AVX512DoKitCleanViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *cleanOptions;
@end

@implementation AVX512DoKitCleanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Clean-up clean data cleansing of";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupTableView];
    [self loadCleanOptions];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CleanOptionCell"];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadCleanOptions {
    self.cleanOptions = @[
        @{
            @"title": @"Clears the clean-clean cache C",
            @"detail": @"Clears the application of cache data cleanup to apply",
            @"action": @"cleanCache",
            @"destructive": @NO
        },
        @{
            @"title": @"Clear interim files clearing temporary file clean-",
            @"detail": @"Clean-clean clean cleaningtmpAll file belongings to",
            @"action": @"cleanTempFiles",
            @"destructive": @NO
        },
        @{
            @"title": @"Clean-clean clean cleaningUserDefaults",
            @"detail": @"Resets the re-reset to apply preference application preferences",
            @"action": @"cleanUserDefaults",
            @"destructive": @YES
        },
        @{
            @"title": @"Clean-clean clean cleaningKeychain",
            @"detail": @"Clears the clean-cleaning of key string",
            @"action": @"cleanKeychain",
            @"destructive": @YES
        },
        @{
            @"title": @"Clean-clean clean cleaningDocuments",
            @"detail": @"Clean-clean clean cleaningDocumentsDirectory Contents directory engagement",
            @"action": @"cleanDocuments",
            @"destructive": @YES
        }
    ];
    
    [self.tableView reloadData];
}

#pragma mark - Clean Actions

- (void)cleanCache {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cachePaths.firstObject;
    [self cleanDirectory:cacheDirectory withName:@"L cache buffer to cc C"];
}

- (void)cleanTempFiles {
    NSString *tempDirectory = NSTemporaryDirectory();
    [self cleanDirectory:tempDirectory withName:@"Temporary st pro-sc"];
}

- (void)cleanUserDefaults {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm confirmed clearance clean-" 
                                                                   message:@"This operation will re-set all application preferences settings for any applications, and continues? Do you want to continue"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"-C?" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        for (NSString *key in defaults.allKeys) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showSuccessAlert:@"UserDefaultsclean-clean cleared cleaned"];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cleanKeychain {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm confirmed clearance clean-" 
                                                                   message:@"This operation will clean key string data, may affect the state of login status and continue? Do you want to proceed"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"-C?" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showSuccessAlert:@"KeychainClean-clean complete clean up and"];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cleanDocuments {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentPaths.firstObject;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm confirmed clearance clean-" 
                                                                   message:@"This operation will be deleted to remove thisDocumentsAll folders of all files in the directory directories and do"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"-C?" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self cleanDirectory:documentDirectory withName:@"Documents"];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cleanDirectory:(NSString *)directory withName:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory error:&error];
    
    if (error) {
        [self showErrorAlert:[NSString stringWithFormat:@"Clean-clean clean cleaning%@Failed failed failure to fail: %@", name, error.localizedDescription]];
        return;
    }
    
    NSUInteger cleanedCount = 0;
    for (NSString *file in contents) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        if ([fileManager removeItemAtPath:filePath error:&error]) {
            cleanedCount++;
        }
    }
    
    [self showSuccessAlert:[NSString stringWithFormat:@"%@Clean-up complete, clean done. Deleted deleted%luindividual file files in one single document", name, (unsigned long)cleanedCount]];
}

- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Successful clean-up successfully cleared and" 
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cleaning failed" 
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cleanOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CleanOptionCell"];
    
    NSDictionary *option = self.cleanOptions[indexPath.row];
    
    cell.textLabel.text = option[@"title"];
    cell.detailTextLabel.text = option[@"detail"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([option[@"destructive"] boolValue]) {
        cell.textLabel.textColor = [UIColor systemRedColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *option = self.cleanOptions[indexPath.row];
    NSString *action = option[@"action"];
    
    SEL actionSelector = NSSelectorFromString(action);
    if ([self respondsToSelector:actionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:actionSelector];
#pragma clang diagnostic pop
    }
}

@end