#import "FLEXDoKitFileBrowserViewController.h"

@interface AVX512DoKitFileBrowserViewController ()
@property (nonatomic, strong) NSArray *directoryContents;
@property (nonatomic, strong) NSString *currentPath;
@end

@implementation AVX512DoKitFileBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"File file viewer browser-s";
    
    // If no root roots if there is none of the leftDocumentsDirectory Contents directory engagement
    if (!self.rootPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.rootPath = paths.firstObject;
    }
    
    self.currentPath = self.rootPath;
    [self loadDirectoryContents];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FileCell"];
}

- (void)loadDirectoryContents {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.currentPath error:&error];
    
    if (error) {
        NSLog(@"❌ Failed to read the directory folder failed while reading your: %@", error.localizedDescription);
        self.directoryContents = @[];
    } else {
        // Sorting by type and name, sort of the
        self.directoryContents = [contents sortedArrayUsingComparator:^NSComparisonResult(NSString *file1, NSString *file2) {
            NSString *path1 = [self.currentPath stringByAppendingPathComponent:file1];
            NSString *path2 = [self.currentPath stringByAppendingPathComponent:file2];
            
            BOOL isDir1, isDir2;
            [[NSFileManager defaultManager] fileExistsAtPath:path1 isDirectory:&isDir1];
            [[NSFileManager defaultManager] fileExistsAtPath:path2 isDirectory:&isDir2];
            
            // Priority priority directory of the
            if (isDir1 && !isDir2) return NSOrderedAscending;
            if (!isDir1 && isDir2) return NSOrderedDescending;
            
            // Sort by name, sort of the same type and
            return [file1 localizedCaseInsensitiveCompare:file2];
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.directoryContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    
    NSString *fileName = self.directoryContents[indexPath.row];
    NSString *filePath = [self.currentPath stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    cell.textLabel.text = fileName;
    cell.accessoryType = isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    // Set settings to set the setting of
    if (isDirectory) {
        cell.imageView.image = [UIImage systemImageNamed:@"folder.fill"];
    } else {
        cell.imageView.image = [UIImage systemImageNamed:@"doc.fill"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *fileName = self.directoryContents[indexPath.row];
    NSString *filePath = [self.currentPath stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    if (isDirectory) {
        // Enter entry into sub-sub directory to
        AVX512DoKitFileBrowserViewController *subDirVC = [[AVX512DoKitFileBrowserViewController alloc] init];
        subDirVC.rootPath = filePath;
        subDirVC.title = fileName;
        [self.navigationController pushViewController:subDirVC animated:YES];
    } else {
        // Displays file information to display the File
        [self showFileInfo:filePath];
    }
}

- (void)showFileInfo:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    
    NSString *fileName = [filePath lastPathComponent];
    NSString *fileSize = [self formatFileSize:[attributes[NSFileSize] unsignedLongLongValue]];
    NSDate *modDate = attributes[NSFileModificationDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    NSString *modDateStr = [formatter stringFromDate:modDate];
    
    NSString *message = [NSString stringWithFormat:@"File name of the filename: %@\nSize and size of the: %@\nChange Time time to Modify Mod: %@", fileName, fileSize, modDateStr];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info-info information"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)formatFileSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu B", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f KB", size / 1024.0];
    } else if (size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f MB", size / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.1f GB", size / (1024.0 * 1024.0 * 1024.0)];
    }
}

@end