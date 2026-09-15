//
//  AVX512ClearCacheViewController.m
//  FLEX
//
//  Created for DoKit integration
//

#import "FLEXClearCacheViewController.h"
#import "FLEXUtility.h"
#import "FLEXAlert.h"

@interface AVX512ClearCacheViewController ()

@property (nonatomic, strong) NSArray *cacheOptions;
@property (nonatomic, strong) NSMutableDictionary *cacheSizes;

@end

@implementation AVX512ClearCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Clear Local-Du clean local data";
    
    // Configure conf configuration of the Configuration Save for A
    self.cacheOptions = @[
        @{@"title": @"Apply the application cache-Applied C", @"path": NSTemporaryDirectory(), @"type": @"temp"},
        @{@"title": @"User-user preferences preferred user preference users", @"type": @"userDefaults"},
        @{@"title": @"Cookies", @"type": @"cookies"},
        @{@"title": @"KeychainThe data of the Data", @"type": @"keychain"},
    ];
    
    self.cacheSizes = [NSMutableDictionary dictionary];
    
    // On the background backstage, calculate a cache-size buffer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self calculateCacheSizes];
    });
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CacheCell"];
}

- (void)calculateCacheSizes {
    for (NSDictionary *option in self.cacheOptions) {
        if ([option[@"type"] isEqualToString:@"temp"]) {
            NSString *path = option[@"path"];
            uint64_t size = [self calculateDirectorySize:path];
            self.cacheSizes[option[@"title"]] = @(size);
        } else if ([option[@"type"] isEqualToString:@"userDefaults"]) {
            // User preferences the user's preferred occupied space is an app approximate value close to p
            self.cacheSizes[option[@"title"]] = @(50 * 1024); // assumption assumptions assuming hypothetical,50KB
        } else if ([option[@"type"] isEqualToString:@"cookies"]) {
            // CookieThe size is also close to the approximate value, and
            self.cacheSizes[option[@"title"]] = @(20 * 1024); // assumption assumptions assuming hypothetical,20KB
        } else if ([option[@"type"] isEqualToString:@"keychain"]) {
            // KeychainThe occupied space is also an app approximate value, and the
            self.cacheSizes[option[@"title"]] = @(10 * 1024); // assumption assumptions assuming hypothetical,10KB
        }
    }
    
    // Update update updating updates updatedUI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (uint64_t)calculateDirectorySize:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    uint64_t totalSize = 0;
    for (NSString *name in contents) {
        NSString *fullPath = [path stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                totalSize += [self calculateDirectorySize:fullPath];
            } else {
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attributes fileSize];
            }
        }
    }
    
    return totalSize;
}

- (NSString *)formattedSizeForOption:(NSString *)title {
    NSNumber *size = self.cacheSizes[title];
    if (size) {
        uint64_t bytes = [size unsignedLongLongValue];
        if (bytes < 1024) {
            return [NSString stringWithFormat:@"%llu B", bytes];
        } else if (bytes < 1024 * 1024) {
            return [NSString stringWithFormat:@"%.2f KB", (double)bytes / 1024];
        } else {
            return [NSString stringWithFormat:@"%.2f MB", (double)bytes / (1024 * 1024)];
        }
    }
    return @"Calculating…";
}

- (void)clearCache:(NSDictionary *)option {
    NSString *type = option[@"type"];
    
    if ([type isEqualToString:@"temp"]) {
        NSString *path = option[@"path"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
        
        for (NSString *file in contents) {
            NSString *fullPath = [path stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
        
        // Updates the update cache-Cue size to
        self.cacheSizes[option[@"title"]] = @(0);
    } else if ([type isEqualToString:@"userDefaults"]) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        self.cacheSizes[option[@"title"]] = @(0);
    } else if ([type isEqualToString:@"cookies"]) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookieStorage.cookies) {
            [cookieStorage deleteCookie:cookie];
        }
        self.cacheSizes[option[@"title"]] = @(0);
    } else if ([type isEqualToString:@"keychain"]) {
        // Clear clear clean- andKeychainData (ex example, where the application should be treated with care in practical applications) for data
        // Note: In real applications, more refinements may need to be needed in a true application that might requireKeychainClears the logical logic clean-
        self.cacheSizes[option[@"title"]] = @(0);
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cacheOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CacheCell" forIndexPath:indexPath];
    
    NSDictionary *option = self.cacheOptions[indexPath.row];
    NSString *title = option[@"title"];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [self formattedSizeForOption:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *option = self.cacheOptions[indexPath.row];
    
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title([NSString stringWithFormat:@"Clear clear clean- and%@", option[@"title"]]);
        make.message([NSString stringWithFormat:@"Determined confirmed that to clear clean-%@? is this operation uncan could not be repeated. This action", option[@"title"]]);
        
        make.button(@"Clear clear clean- and").destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            [self clearCache:option];
        });
        
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

@end