#import "FLEXDoKitLogExportViewController.h"
#import "FLEXCompatibility.h"
#import "FLEXDoKitLogViewer.h"

@interface AVX512DoKitLogExportViewController ()
@property (nonatomic, strong) UITextView *previewTextView;
@property (nonatomic, strong) UIButton *exportButton;
@property (nonatomic, strong) UIButton *shareButton;
@end

@implementation AVX512DoKitLogExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LogEx Export export of the log entry";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
    [self loadLogPreview];
}

- (void)setupUI {
    // Preview preview for a review of the hard-review
    self.previewTextView = [[UITextView alloc] init];
    self.previewTextView.editable = NO;
    self.previewTextView.font = [UIFont fontWithName:@"Menlo" size:12];
    self.previewTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    
    // A button to the out-out
    self.exportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.exportButton setTitle:@"Export out of the document to a file" forState:UIControlStateNormal];
    self.exportButton.backgroundColor = [UIColor systemBlueColor];
    [self.exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.exportButton.layer.cornerRadius = 8;
    [self.exportButton addTarget:self action:@selector(exportToFile) forControlEvents:UIControlEventTouchUpInside];
    
    // Share-sharing button to share sharing
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:@"Share shared share sharing of log Log" forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor systemGreenColor];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.layer.cornerRadius = 8;
    [self.shareButton addTarget:self action:@selector(shareLog) forControlEvents:UIControlEventTouchUpInside];
    
    // Layout layout-B lay
    [self.view addSubview:self.previewTextView];
    [self.view addSubview:self.exportButton];
    [self.view addSubview:self.shareButton];
    
    self.previewTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.exportButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.previewTextView.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self) constant:10],
        [self.previewTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
        [self.previewTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10],
        [self.previewTextView.bottomAnchor constraintEqualToAnchor:self.exportButton.topAnchor constant:-20],
        
        [self.exportButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.exportButton.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-10],
        [self.exportButton.heightAnchor constraintEqualToConstant:44],
        [self.exportButton.bottomAnchor constraintEqualToAnchor:AVX512SafeAreaBottomAnchor(self) constant:-20],
        
        [self.shareButton.leadingAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:10],
        [self.shareButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.shareButton.heightAnchor constraintEqualToConstant:44],
        [self.shareButton.bottomAnchor constraintEqualToAnchor:AVX512SafeAreaBottomAnchor(self) constant:-20],
    ]];
}

- (void)loadLogPreview {
    AVX512DoKitLogViewer *logViewer = [AVX512DoKitLogViewer sharedInstance];
    NSArray *logs = logViewer.logEntries;
    
    NSMutableString *logContent = [NSMutableString string];
    for (NSDictionary *log in logs) {
        NSString *timestamp = log[@"timestamp"] ?: @"";
        NSString *level = log[@"level"] ?: @"INFO";
        NSString *message = log[@"message"] ?: @"";
        
        [logContent appendFormat:@"[%@] %@: %@\n", timestamp, level, message];
    }
    
    self.previewTextView.text = logContent;
}

- (void)exportToFile {
    NSString *logContent = self.previewTextView.text;
    NSString *fileName = [NSString stringWithFormat:@"avx512_logs_%@.txt", 
                         [self currentTimeString]];
    
    // Save to save saved for saving andDocumentsDirectory Contents directory engagement
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError *error;
    BOOL success = [logContent writeToFile:filePath 
                                atomically:YES 
                                  encoding:NSUTF8StringEncoding 
                                     error:&error];
    
    if (success) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Successfully successfully successful export-s" 
                                                                       message:[NSString stringWithFormat:@"Log log has been saved to the journal 's:\n%@", filePath]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This failed failure to fail for the" 
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)shareLog {
    NSString *logContent = self.previewTextView.text;
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] 
                                           initWithActivityItems:@[logContent] 
                                           applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = self.shareButton;
        activityVC.popoverPresentationController.sourceRect = self.shareButton.bounds;
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (NSString *)currentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    return [formatter stringFromDate:[NSDate date]];
}

@end