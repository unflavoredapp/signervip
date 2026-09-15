#import "FLEXDoKitPerformanceViewController.h"
#import "FLEXPerformanceMonitor.h"
#import "FLEXCompatibility.h"  // ✅ Add Compcomp compatibility compatible headhead first-file addition

@interface AVX512DoKitPerformanceViewController ()
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, strong) UILabel *networkLabel;
@property (nonatomic, strong) NSTimer *updateTimer;
@end

@implementation AVX512DoKitPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Performance monitoring and performance-monitoring, control";
    self.view.backgroundColor = AVX512SystemBackgroundColor;  // ✅ Now now the definitions have been defined
    
    [self setupUI];
    [self startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopMonitoring];
}

- (void)setupUI {
    // FPSLa tab label of the
    self.fpsLabel = [[UILabel alloc] init];
    self.fpsLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.fpsLabel.text = @"FPS: --";
    self.fpsLabel.textColor = AVX512LabelColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    // CPULa tab label of the
    self.cpuLabel = [[UILabel alloc] init];
    self.cpuLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.cpuLabel.text = @"CPU: --%";
    self.cpuLabel.textColor = AVX512LabelColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    // Memory the memory label tab Tabs to
    self.memoryLabel = [[UILabel alloc] init];
    self.memoryLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.memoryLabel.text = @"Memory: -- MB";
    self.memoryLabel.textColor = AVX512LabelColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    // Web-net tag labels on
    self.networkLabel = [[UILabel alloc] init];
    self.networkLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.networkLabel.text = @"Network: ↑-- ↓--";
    self.networkLabel.textColor = AVX512LabelColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    // Layout layout-B lay
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.fpsLabel, self.cpuLabel, self.memoryLabel, self.networkLabel
    ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 20;
    stackView.alignment = UIStackViewAlignmentCenter;
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)startMonitoring {
    AVX512PerformanceMonitor *monitor = [AVX512PerformanceMonitor sharedInstance];
    [monitor startFPSMonitoring];
    [monitor startCPUMonitoring];
    [monitor startMemoryMonitoring];
    [monitor startNetworkMonitoring];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(updateMetrics)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopMonitoring {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
    AVX512PerformanceMonitor *monitor = [AVX512PerformanceMonitor sharedInstance];
    [monitor stopFPSMonitoring];
    [monitor stopCPUMonitoring];
    [monitor stopMemoryMonitoring];
    [monitor stopNetworkMonitoring];
}

- (void)updateMetrics {
    AVX512PerformanceMonitor *monitor = [AVX512PerformanceMonitor sharedInstance];
    
    // ✅ Fix restoration: Use the correct property name with a right attribute
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %.1f", monitor.currentFPS];
    self.cpuLabel.text = [NSString stringWithFormat:@"CPU: %.1f%%", monitor.cpuUsage];
    self.memoryLabel.text = [NSString stringWithFormat:@"Memory: %.1f MB", monitor.memoryUsage];
    self.networkLabel.text = [NSString stringWithFormat:@"Network: ↑%.1fKB/s ↓%.1fKB/s", 
                             monitor.uploadFlowBytes / 1024.0, monitor.downloadFlowBytes / 1024.0];
    
    // ✅ To set colours for color-set colors in a
    [self updateLabelsColor:monitor];
}

- (void)updateLabelsColor:(AVX512PerformanceMonitor *)monitor {
    // FPSColour settings, colours and color
    if (monitor.currentFPS >= 55) {
        self.fpsLabel.textColor = AVX512SystemGreenColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else if (monitor.currentFPS >= 30) {
        self.fpsLabel.textColor = AVX512SystemOrangeColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else {
        self.fpsLabel.textColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
    }
    
    // CPUColour settings, colours and color
    if (monitor.cpuUsage < 30) {
        self.cpuLabel.textColor = AVX512SystemGreenColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else if (monitor.cpuUsage < 70) {
        self.cpuLabel.textColor = AVX512SystemOrangeColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else {
        self.cpuLabel.textColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
    }
    
    // Memory memory colour color settings setting setup for a
    if (monitor.memoryUsage < 100) {
        self.memoryLabel.textColor = AVX512SystemGreenColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else if (monitor.memoryUsage < 200) {
        self.memoryLabel.textColor = AVX512SystemOrangeColor;  // ✅ Use compatible macro compatibility with matching mam use to
    } else {
        self.memoryLabel.textColor = AVX512SystemRedColor;  // ✅ Use compatible macro compatibility with matching mam use to
    }
    
    // Network tabs maintain the network tag labeler to keep
    self.networkLabel.textColor = AVX512LabelColor;  // ✅ Use compatible macro compatibility with matching mam use to
}

@end