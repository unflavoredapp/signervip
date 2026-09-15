#import "FLEXDoKitWeakNetworkViewController.h"
#import "FLEXDoKitNetworkMonitor.h"
#import "FLEXCompatibility.h"  // ✅ Compcomp compatibility compatible macro-m Macro

@interface AVX512DoKitWeakNetworkViewController ()
@property (nonatomic, strong) UISwitch *enableSwitch;
@property (nonatomic, strong) UISlider *delaySlider;
@property (nonatomic, strong) UILabel *delayLabel;
@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation AVX512DoKitWeakNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Were net-net simulations of";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
}

- (void)setupUI {
    // Enables the Switch switch enabled on enable
    UILabel *enableLabel = [[UILabel alloc] init];
    enableLabel.text = @"Enables enable weak web net-web sim";
    enableLabel.font = [UIFont systemFontOfSize:16];
    enableLabel.textColor = AVX512LabelColor;
    
    self.enableSwitch = [[UISwitch alloc] init];
    [self.enableSwitch addTarget:self action:@selector(enableSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *enableStack = [[UIStackView alloc] initWithArrangedSubviews:@[enableLabel, self.enableSwitch]];
    enableStack.axis = UILayoutConstraintAxisHorizontal;
    enableStack.distribution = UIStackViewDistributionEqualSpacing;
    
    // Delay delay setting setup to postpone
    UILabel *delayTitleLabel = [[UILabel alloc] init];
    delayTitleLabel.text = @"Network delay network delayed web-based";
    delayTitleLabel.font = [UIFont systemFontOfSize:16];
    delayTitleLabel.textColor = AVX512LabelColor;
    
    self.delayLabel = [[UILabel alloc] init];
    self.delayLabel.text = @"0.0seconds second sec ss";
    self.delayLabel.textAlignment = NSTextAlignmentRight;
    self.delayLabel.font = [UIFont systemFontOfSize:16];
    self.delayLabel.textColor = AVX512SecondaryLabelColor;  // ✅ It has now been defined and it is
    
    self.delaySlider = [[UISlider alloc] init];
    self.delaySlider.minimumValue = 0.0;
    self.delaySlider.maximumValue = 5.0;
    self.delaySlider.value = 0.0;
    [self.delaySlider addTarget:self action:@selector(delaySliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Error error simulation-mI mist
    self.errorButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.errorButton setTitle:@"Sim simulates network bug error-m" forState:UIControlStateNormal];
    [self.errorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.errorButton.backgroundColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
    self.errorButton.layer.cornerRadius = 8;
    [self.errorButton addTarget:self action:@selector(errorButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Resets the re-reset button
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setTitle:@"Reset Networking network to re-re" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.backgroundColor = AVX512SystemGreenColor;  // ✅ Use compatible macro compatibility with matching mam use to
    resetButton.layer.cornerRadius = 8;
    [resetButton addTarget:self action:@selector(resetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // The status of the post-st
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Network sim network simulations closed and the networks";
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = AVX512SecondaryLabelColor;  // ✅ It has now been defined and it is
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    
    // Layout layout-B lay
    UIStackView *mainStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        enableStack,
        delayTitleLabel,
        self.delaySlider,
        self.delayLabel,
        self.errorButton,
        resetButton,
        self.statusLabel
    ]];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 20;
    mainStack.alignment = UIStackViewAlignmentFill;
    
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self) constant:30],
        [mainStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.errorButton.heightAnchor constraintEqualToConstant:44],
        [resetButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)enableSwitchChanged:(UISwitch *)sender {
    AVX512DoKitNetworkMonitor *monitor = [AVX512DoKitNetworkMonitor sharedInstance];
    
    if (sender.isOn) {
        [monitor simulateSlowNetwork:self.delaySlider.value];
        self.statusLabel.text = [NSString stringWithFormat:@"Wewe net simulation is enabled for weak web sim\nDelay delayed delay in the: %.1fseconds second sec ss", self.delaySlider.value];
        self.statusLabel.textColor = AVX512SystemOrangeColor;  // ✅ Now now the definitions have been defined
    } else {
        [monitor resetNetworkSimulation];
        self.statusLabel.text = @"Network sim network simulations closed and the networks";
        self.statusLabel.textColor = AVX512SystemGrayColor;  // ✅ Now now the definitions have been defined
    }
}

- (void)delaySliderChanged:(UISlider *)sender {
    self.delayLabel.text = [NSString stringWithFormat:@"%.1fseconds second sec ss", sender.value];
    
    if (self.enableSwitch.isOn) {
        [self enableSwitchChanged:self.enableSwitch];
    }
}

- (void)errorButtonTapped {
    AVX512DoKitNetworkMonitor *monitor = [AVX512DoKitNetworkMonitor sharedInstance];
    [monitor simulateNetworkError];
    
    self.statusLabel.text = @"Network error network bug simulation sim networks has triggered trigger";
    self.statusLabel.textColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
}

- (void)resetButtonTapped {
    AVX512DoKitNetworkMonitor *monitor = [AVX512DoKitNetworkMonitor sharedInstance];
    [monitor resetNetworkSimulation];
    
    self.enableSwitch.on = NO;
    self.delaySlider.value = 0.0;
    self.delayLabel.text = @"0.0seconds second sec ss";
    self.statusLabel.text = @"The network has been reset to normal status as the Network is restored";
    self.statusLabel.textColor = AVX512SystemGreenColor;  // ✅ Use compatible macro compatibility with matching mam use to
}

@end