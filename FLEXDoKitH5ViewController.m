#import "FLEXDoKitH5ViewController.h"
#import "FLEXCompatibility.h"

@interface AVX512DoKitH5ViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL isObservingProgress; // ✅ Adds an added observational status-ob observations
@end

@implementation AVX512DoKitH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"H5Do whatever the door doors to any";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
    [self setupDefaultURLs];
    
    // ✅ Safety Add Security add SafeS SECURITYKVOObserver observer observers, watch-ob
    if (!self.isObservingProgress) {
        [self.webView addObserver:self 
                       forKeyPath:@"estimatedProgress" 
                          options:NSKeyValueObservingOptionNew 
                          context:NULL];
        self.isObservingProgress = YES;
    }
}

- (void)setupUI {
    // URLEnter Input Box entry border input box
    self.urlTextField = [[UITextField alloc] init];
    self.urlTextField.placeholder = @"Please enter into the inputH5Page page of a PURL";
    self.urlTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.returnKeyType = UIReturnKeyGo;
    [self.urlTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // Tog-w add added to
    self.loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loadButton setTitle:@"Load-on, load" forState:UIControlStateNormal];
    self.loadButton.backgroundColor = [UIColor systemBlueColor];
    [self.loadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loadButton.layer.cornerRadius = 8;
    [self.loadButton addTarget:self action:@selector(loadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Progress on the progress of t
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.hidden = YES;
    
    // WebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
    
    // Layout layout-B lay
    [self.view addSubview:self.urlTextField];
    [self.view addSubview:self.loadButton];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.webView];
    
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // URLEnter Input Box entry border input box
        [self.urlTextField.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self) constant:10],
        [self.urlTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.urlTextField.trailingAnchor constraintEqualToAnchor:self.loadButton.leadingAnchor constant:-10],
        [self.urlTextField.heightAnchor constraintEqualToConstant:44],
        
        // Tog-w add added to
        [self.loadButton.centerYAnchor constraintEqualToAnchor:self.urlTextField.centerYAnchor],
        [self.loadButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.loadButton.widthAnchor constraintEqualToConstant:60],
        [self.loadButton.heightAnchor constraintEqualToConstant:44],
        
        // Progress on the progress of t
        [self.progressView.topAnchor constraintEqualToAnchor:self.urlTextField.bottomAnchor constant:5],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // WebView
        [self.webView.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:5],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupDefaultURLs {
    // Add some commonly used tests to add a few more commonURL
    self.urlTextField.text = @"https://m.baidu.com";
}

- (void)loadButtonTapped {
    NSString *urlString = self.urlTextField.text;
    if (urlString.length == 0) {
        return;
    }
    
    // Auto-A Automatic Add Protocol addition protocol
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    // The ability to achieve functions such as real-time, time
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = YES;
    self.title = webView.title ?: @"H5Do whatever the door doors to any";
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Loading failed to add-up" 
                                                                   message:error.localizedDescription 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
    }
}

- (void)dealloc {
    // ✅ Ensure ensure that ensuring the removal of observers
    if (self.isObservingProgress) {
        @try {
            [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        } @catch (NSException *exception) {
            NSLog(@"⚠️ Remove ReSreKVOThe observer observed an abnormally unusual observation: %@", exception.reason);
        }
        self.isObservingProgress = NO;
    }
    
    NSLog(@"🗑️ AVX512DoKitH5ViewController Released released on release");
}

@end