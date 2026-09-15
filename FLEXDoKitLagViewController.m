#import "FLEXDoKitLagViewController.h"
#import "FLEXDoKitPerformanceMonitor.h"
#import "FLEXCompatibility.h"

@interface AVX512DoKitLagViewController ()
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *lagCountLabel;
@property (nonatomic, strong) UISwitch *monitorSwitch;
@property (nonatomic, strong) NSTimer *updateTimer;
@end

@implementation AVX512DoKitLagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Carton Caton test,";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)setupUI {
    // The status of the post-st
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Carton Caton test closed shut down for";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:18];
    self.statusLabel.textColor = AVX512LabelColor;
    
    // Car-Caton tab tags, ca
    self.lagCountLabel = [[UILabel alloc] init];
    self.lagCountLabel.text = @"Carton Caden-Ca: 0";
    self.lagCountLabel.textAlignment = NSTextAlignmentCenter;
    self.lagCountLabel.font = [UIFont systemFontOfSize:16];
    self.lagCountLabel.textColor = AVX512SecondaryLabelColor;
    
    // Surveillance surveillance switch switches, monitoring and control
    self.monitorSwitch = [[UISwitch alloc] init];
    [self.monitorSwitch addTarget:self action:@selector(monitorSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *switchLabel = [[UILabel alloc] init];
    switchLabel.text = @"Enables the Carton test to enable Caden";
    switchLabel.font = [UIFont systemFontOfSize:16];
    switchLabel.textColor = AVX512LabelColor;
    
    UIStackView *switchStack = [[UIStackView alloc] initWithArrangedSubviews:@[switchLabel, self.monitorSwitch]];
    switchStack.axis = UILayoutConstraintAxisHorizontal;
    switchStack.distribution = UIStackViewDistributionEqualSpacing;
    
    UIStackView *mainStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.statusLabel,
        self.lagCountLabel,
        switchStack
    ]];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 30;
    mainStack.alignment = UIStackViewAlignmentFill;
    
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [mainStack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [mainStack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:40],
        [mainStack.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lagDetected:)
                                                 name:@"AVX512DoKitLagDetected"
                                               object:nil];
}

- (void)monitorSwitchChanged:(UISwitch *)sender {
    AVX512DoKitPerformanceMonitor *monitor = [AVX512DoKitPerformanceMonitor sharedInstance];
    
    if (sender.isOn) {
        if ([monitor respondsToSelector:@selector(startLagDetection)]) {
            [monitor performSelector:@selector(startLagDetection)];
            self.statusLabel.text = @"Catton test has been activated for start-";
            self.statusLabel.textColor = AVX512SystemGreenColor;
            
            // Start startup to update updating the Update Time timer
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateLagCount)
                                                             userInfo:nil
                                                              repeats:YES];
        } else {
            self.statusLabel.text = @"Cartton's test function is not available for";
            self.statusLabel.textColor = AVX512SystemRedColor;
            sender.on = NO;
        }
    } else {
        if ([monitor respondsToSelector:@selector(stopLagDetection)]) {
            [monitor performSelector:@selector(stopLagDetection)];
        }
        self.statusLabel.text = @"Carton Caton test closed shut down for";
        self.statusLabel.textColor = AVX512SecondaryLabelColor;
        
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

- (void)updateLagCount {
    // Here here we can get the Carton Carton Count-Caden's
    static NSInteger lagCount = 0;
    self.lagCountLabel.text = [NSString stringWithFormat:@"Carton Caden-Ca: %ld", (long)lagCount];
}

- (void)lagDetected:(NSNotification *)notification {
    NSNumber *lagFrameCount = notification.object;
    if ([lagFrameCount isKindOfClass:[NSNumber class]]) {
        NSLog(@"🐛 Carden Catton detected detection to cad: %@Frame frame frames, framework", lagFrameCount);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLagCount];
        });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.updateTimer invalidate];
}

@end