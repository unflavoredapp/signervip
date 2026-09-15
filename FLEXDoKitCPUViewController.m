#import "FLEXDoKitCPUViewController.h"
#import "FLEXCompatibility.h"  // ✅ Compcomp compatibility compatible macro-m Macro
#import <mach/mach.h>
#import <sys/sysctl.h>

@interface AVX512DoKitCPUViewController ()
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIProgressView *cpuProgressView;
@property (nonatomic, strong) UISwitch *monitorSwitch;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cpuHistory;
@end

@implementation AVX512DoKitCPUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CPUMonitoring, surveillance and monitoring";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    self.cpuHistory = [NSMutableArray new];
    
    [self setupUI];
    [self startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopMonitoring];
}

- (void)setupUI {
    // CPUUs rate of usage ratio displays the
    self.cpuLabel = [[UILabel alloc] init];
    self.cpuLabel.font = [UIFont boldSystemFontOfSize:36];
    self.cpuLabel.textAlignment = NSTextAlignmentCenter;
    self.cpuLabel.text = @"0%";
    self.cpuLabel.textColor = AVX512SystemGreenColor;
    
    // The status of the post-st
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"Normal normal, regular and";
    self.statusLabel.textColor = AVX512SystemGreenColor;
    
    // CPUUse rate of progress bar to use the rates-
    self.cpuProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.cpuProgressView.progress = 0.0;
    self.cpuProgressView.progressTintColor = AVX512SystemGreenColor;
    
    // Surveillance surveillance switch switches, monitoring and control
    self.monitorSwitch = [[UISwitch alloc] init];
    self.monitorSwitch.on = YES;
    [self.monitorSwitch addTarget:self action:@selector(monitorSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Descriptions to explain the label tab
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = @"Real-time real time, liveCPUUs rate of usage ratio use rates\nGreen green, and a: Normal normal, regular and(<30%) Orange orange.: Higher (b higher)(30-70%) Red red, red: Too much too high to(>70%)";
    descLabel.numberOfLines = 0;
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = AVX512SystemGrayColor;
    
    // Layout layout-B lay
    UIStackView *mainStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.cpuLabel,
        self.statusLabel,
        self.cpuProgressView,
        self.monitorSwitch,
        descLabel
    ]];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 20;
    mainStack.alignment = UIStackViewAlignmentCenter;
    
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [mainStack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [mainStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [self.cpuProgressView.widthAnchor constraintEqualToConstant:200]
    ]];
}

- (void)startMonitoring {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
    }
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateCPUUsage)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopMonitoring {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)updateCPUUsage {
    if (!self.monitorSwitch.on) return;
    
    CGFloat cpuUsage = [self getCPUUsage];
    
    // Add added to the historical history record by adding add
    [self.cpuHistory addObject:@(cpuUsage)];
    if (self.cpuHistory.count > 60) { // Re reservations reservation late to a recent60The data of the second-second
        [self.cpuHistory removeObjectAtIndex:0];
    }
    
    [self updateCPUUsage:cpuUsage];
}

- (void)updateCPUUsage:(CGFloat)cpuUsage {
    // Updates to update the updating updates
    self.cpuLabel.text = [NSString stringWithFormat:@"%.1f%%", cpuUsage];
    self.cpuProgressView.progress = cpuUsage / 100.0;
    
    // on the basis,CPUThe rate of usage set-rate settings colour color
    if (cpuUsage < 30) {
        self.cpuLabel.textColor = AVX512SystemGreenColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.textColor = AVX512SystemGreenColor;  // ✅ Now now the definitions have been defined
        self.cpuProgressView.progressTintColor = AVX512SystemGreenColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.text = @"Normal normal, regular and";
    } else if (cpuUsage < 70) {
        self.cpuLabel.textColor = AVX512SystemOrangeColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.textColor = AVX512SystemOrangeColor;  // ✅ Now now the definitions have been defined
        self.cpuProgressView.progressTintColor = AVX512SystemOrangeColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.text = @"Higher (b higher)";
    } else {
        self.cpuLabel.textColor = AVX512SystemRedColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.textColor = AVX512SystemRedColor;  // ✅ Now now the definitions have been defined
        self.cpuProgressView.progressTintColor = AVX512SystemRedColor;  // ✅ Now now the definitions have been defined
        self.statusLabel.text = @"Too much too high to";
    }
}

- (CGFloat)getCPUUsage {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCount = 0;
    
    kern_return_t kr = task_threads(mach_task_self(), &threads, &threadCount);
    if (kr != KERN_SUCCESS) {
        return 0.0;
    }
    
    CGFloat totalCPU = 0.0;
    
    for (unsigned int i = 0; i < threadCount; i++) {
        thread_info_data_t threadInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        
        kr = thread_info(threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount);
        if (kr == KERN_SUCCESS) {
            thread_basic_info_t basicInfo = (thread_basic_info_t)threadInfo;
            
            if (!(basicInfo->flags & TH_FLAGS_IDLE)) {
                totalCPU += basicInfo->cpu_usage / (CGFloat)TH_USAGE_SCALE * 100.0;
            }
        }
    }
    
    // Clearing of resources clean-up
    vm_deallocate(mach_task_self(), (vm_offset_t)threads, threadCount * sizeof(thread_t));
    
    return totalCPU;
}

- (void)monitorSwitchChanged:(UISwitch *)sender {
    if (!sender.on) {
        [self stopMonitoring];
        self.cpuLabel.text = @"--";
        self.statusLabel.text = @"It's stop-";
        self.cpuLabel.textColor = AVX512SystemGrayColor;
        self.statusLabel.textColor = AVX512SystemGrayColor;
        self.cpuProgressView.progress = 0;
    } else {
        [self startMonitoring];
    }
}

@end