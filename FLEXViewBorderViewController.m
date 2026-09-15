#import "FLEXViewBorderViewController.h"
#import "FLEXCompatibility.h"
#import "FLEXDoKitVisualTools.h"

@interface AVX512ViewBorderViewController ()
@property (nonatomic, strong) UISwitch *borderSwitch;
@property (nonatomic, strong) UISwitch *layoutSwitch;
@property (nonatomic, strong) UISwitch *rulerSwitch;
@end

@implementation AVX512ViewBorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Visual visual video deback commissioning tool tools for";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
}

- (void)setupUI {
    // View view border frame box opening switch on the Border Box
    UILabel *borderLabel = [[UILabel alloc] init];
    borderLabel.text = @"Shows a display of the view views View Views";
    borderLabel.font = [UIFont systemFontOfSize:16];
    
    self.borderSwitch = [[UISwitch alloc] init];
    [self.borderSwitch addTarget:self action:@selector(borderSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *borderStack = [[UIStackView alloc] initWithArrangedSubviews:@[borderLabel, self.borderSwitch]];
    borderStack.axis = UILayoutConstraintAxisHorizontal;
    borderStack.distribution = UIStackViewDistributionFill;
    borderStack.alignment = UIStackViewAlignmentCenter;
    
    // BB Bou-Bud layout, Bureau Border
    UILabel *layoutLabel = [[UILabel alloc] init];
    layoutLabel.text = @"Show show displays the layout border boundary of a";
    layoutLabel.font = [UIFont systemFontOfSize:16];
    
    self.layoutSwitch = [[UISwitch alloc] init];
    [self.layoutSwitch addTarget:self action:@selector(layoutSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *layoutStack = [[UIStackView alloc] initWithArrangedSubviews:@[layoutLabel, self.layoutSwitch]];
    layoutStack.axis = UILayoutConstraintAxisHorizontal;
    layoutStack.distribution = UIStackViewDistributionFill;
    layoutStack.alignment = UIStackViewAlignmentCenter;
    
    // Ruler rule measure switch switches on the rules of
    UILabel *rulerLabel = [[UILabel alloc] init];
    rulerLabel.text = @"Displays the display of a grid space ruler rules";
    rulerLabel.font = [UIFont systemFontOfSize:16];
    
    self.rulerSwitch = [[UISwitch alloc] init];
    [self.rulerSwitch addTarget:self action:@selector(rulerSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *rulerStack = [[UIStackView alloc] initWithArrangedSubviews:@[rulerLabel, self.rulerSwitch]];
    rulerStack.axis = UILayoutConstraintAxisHorizontal;
    rulerStack.distribution = UIStackViewDistributionFill;
    rulerStack.alignment = UIStackViewAlignmentCenter;
    
    // The master main container,
    UIStackView *mainStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        borderStack, layoutStack, rulerStack
    ]];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 20;
    mainStack.alignment = UIStackViewAlignmentFill;
    
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.topAnchor constraintEqualToAnchor:AVX512SafeAreaTopAnchor(self) constant:40],
        [mainStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)borderSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [[AVX512DoKitVisualTools sharedInstance] showViewBorders];
    } else {
        [[AVX512DoKitVisualTools sharedInstance] hideViewBorders];
    }
}

- (void)layoutSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [[AVX512DoKitVisualTools sharedInstance] showLayoutBounds];
    } else {
        [[AVX512DoKitVisualTools sharedInstance] hideLayoutBounds];
    }
}

- (void)rulerSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [[AVX512DoKitVisualTools sharedInstance] showRuler];
    } else {
        [[AVX512DoKitVisualTools sharedInstance] hideRuler];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Clean-cleaning of all visual tools to clean
    [[AVX512DoKitVisualTools sharedInstance] hideViewBorders];
    [[AVX512DoKitVisualTools sharedInstance] hideLayoutBounds];
    [[AVX512DoKitVisualTools sharedInstance] hideRuler];
}

@end