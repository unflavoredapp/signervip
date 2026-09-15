#import "FLEXLookinMeasureViewController.h"
#import "FLEXLookinMeasureController.h"
#import "FLEXCompatibility.h"  // ✅ Add Compability to Acompat compatibility Import import

@interface AVX512LookinMeasureViewController ()
@property (nonatomic, strong) UISwitch *measureSwitch;
@property (nonatomic, strong) UILabel *instructionLabel;
@end

@implementation AVX512LookinMeasureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"LookinMeasurement tool tools to measure the measurement";
    self.view.backgroundColor = AVX512SystemBackgroundColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    [self setupUI];
}

- (void)setupUI {
    // Measuring switch switches to measure the measurement
    self.measureSwitch = [[UISwitch alloc] init];
    [self.measureSwitch addTarget:self action:@selector(measureSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Descriptions to explain the label tab
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.text = @"When the measurement mode is turned on, you can be dragged and pulled to measure distance between two view views by drag-\n\nOperation description: Operational Note _ operational\n1. Turns on the measure measurement switch switches to open\n2. Drag-and drag to and pull dragged to select two\n3. Double double-click to lock twice by both impacting";
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.font = [UIFont systemFontOfSize:16];
    
    // Layout layout-B lay
    self.measureSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.measureSwitch];
    [self.view addSubview:self.instructionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.measureSwitch.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.measureSwitch.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-50],
        
        [self.instructionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.instructionLabel.topAnchor constraintEqualToAnchor:self.measureSwitch.bottomAnchor constant:30],
        [self.instructionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.instructionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)measureSwitchChanged:(UISwitch *)sender {
    AVX512LookinMeasureController *controller = [AVX512LookinMeasureController sharedInstance];
    
    if (sender.isOn) {
        [controller startMeasuring];
        self.instructionLabel.text = @"Measuring mode is active! The measuring modes are on\n\nNow can it now and:\n• Drag drag- and pull screen to dragging the dragged videoscreen to select two\n• Double double-click twice click locks on the current measurement\n• Turns turn off switch to Close Switchoff quit out of";
    } else {
        [controller stopMeasuring];
        self.instructionLabel.text = @"When the measurement mode is turned on, you can be dragged and pulled to measure distance between two view views by drag-\n\nOperation description: Operational Note _ operational\n1. Turns on the measure measurement switch switches to open\n2. Drag-and drag to and pull dragged to select two\n3. Double double-click to lock twice by both impacting";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Auto turn the measure measurement mode pattern model off automatically self-
    if (self.measureSwitch.isOn) {
        [[AVX512LookinMeasureController sharedInstance] stopMeasuring];
    }
}

@end