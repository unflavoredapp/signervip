#import "FLEXDoKitColorPickerViewController.h"
#import "FLEXDoKitVisualTools.h"
#import "FLEXCompatibility.h"

@interface AVX512DoKitColorPickerViewController ()
@property (nonatomic, strong) UIView *colorPreview;
@property (nonatomic, strong) UILabel *colorInfoLabel;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@end

@implementation AVX512DoKitColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Colour-colored straws in colour";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
}

- (void)setupUI {
    // Descriptions to explain the label tab
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.text = @"Click on \"Start colouring\" to click anywhere in the screen, then tap a color";
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.font = [UIFont systemFontOfSize:16];
    self.instructionLabel.textColor = AVX512SecondaryLabelColor;
    
    // Colours for a colour preview of the
    self.colorPreview = [[UIView alloc] init];
    self.colorPreview.backgroundColor = [UIColor lightGrayColor];
    self.colorPreview.layer.borderWidth = 1;
    self.colorPreview.layer.borderColor = AVX512SystemGrayColor.CGColor;
    self.colorPreview.layer.cornerRadius = 8;
    
    // Colour Information Color Info colour information on color
    self.colorInfoLabel = [[UILabel alloc] init];
    self.colorInfoLabel.text = @"The colour color has not been selected to select the";
    self.colorInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.colorInfoLabel.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightMedium];
    self.colorInfoLabel.numberOfLines = 0;
    self.colorInfoLabel.textColor = AVX512LabelColor;
    
    // Start start button to begin the starting
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:@"Start start of the check-to to" forState:UIControlStateNormal];
    self.startButton.backgroundColor = AVX512SystemBlueColor;
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.layer.cornerRadius = 8;
    [self.startButton addTarget:self action:@selector(startColorPicker) forControlEvents:UIControlEventTouchUpInside];
    
    // Stop stop button to cease the current
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setTitle:@"Stops the check-out to stop" forState:UIControlStateNormal];
    self.stopButton.backgroundColor = AVX512SystemRedColor;
    [self.stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.stopButton.layer.cornerRadius = 8;
    self.stopButton.enabled = NO;
    [self.stopButton addTarget:self action:@selector(stopColorPicker) forControlEvents:UIControlEventTouchUpInside];
    
    // Layout layout-B lay
    UIStackView *buttonStack = [[UIStackView alloc] initWithArrangedSubviews:@[self.startButton, self.stopButton]];
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.spacing = 16;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    
    UIStackView *mainStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.instructionLabel,
        self.colorPreview,
        self.colorInfoLabel,
        buttonStack
    ]];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 20;
    mainStack.alignment = UIStackViewAlignmentFill;
    
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [mainStack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [mainStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
        
        [self.colorPreview.heightAnchor constraintEqualToConstant:100],
        [self.startButton.heightAnchor constraintEqualToConstant:44],
        [self.stopButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // Listen listening to colour selection for hearing color selects the
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(colorPicked:)
                                                 name:@"AVX512DoKitColorPicked"
                                               object:nil];
}

- (void)startColorPicker {
    [[AVX512DoKitVisualTools sharedInstance] startColorPicker];
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    // ✅ Restored: Use transfine character characters or change quote marks to the English quotation sign for citation numbering in
    self.instructionLabel.text = @"The colouring mode has been started and the color checker pattern is activated, clicking on any location anywhere";
}

- (void)stopColorPicker {
    [[AVX512DoKitVisualTools sharedInstance] stopColorPicker];
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    // ✅ Restored: Use transfine character characters or change quote marks to the English quotation sign for citation numbering in
    self.instructionLabel.text = @"Click on \"Start colouring\" to click anywhere in the screen, then tap a color";
}

- (void)colorPicked:(NSNotification *)notification {
    UIColor *color = notification.object;
    if (color) {
        self.colorPreview.backgroundColor = color;
        
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        NSString *hexColor = [NSString stringWithFormat:@"#%02X%02X%02X",
                             (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
        NSString *rgbColor = [NSString stringWithFormat:@"RGB(%.0f, %.0f, %.0f)",
                             red * 255, green * 255, blue * 255];
        
        self.colorInfoLabel.text = [NSString stringWithFormat:@"Hex: %@\n%@\nAlpha: %.2f", hexColor, rgbColor, alpha];
        
        // Copy copy to the clipboard runup-to Clip
        [UIPasteboard generalPasteboard].string = hexColor;
        
        // Shows a reminder to show the
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Colour colours for which color has obtained"
                                                                       message:[NSString stringWithFormat:@"The colour value of the color- %@ Copyed to the clipboard board has been copied and reproduced", hexColor]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVX512DoKitVisualTools sharedInstance] stopColorPicker];
}

@end