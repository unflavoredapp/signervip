#import "FLEXDoKitComponentViewController.h"
#import "FLEXCompatibility.h"  // ✅ Compcomp compatible headhead First Header file compatibility

@interface AVX512DoKitComponentViewController ()
@property (nonatomic, strong) UIView *overlayWindow;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, assign) BOOL isInspecting;
@end

@implementation AVX512DoKitComponentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Component component checker for components part-";
    self.view.backgroundColor = AVX512SystemBackgroundColor;
    
    [self setupUI];
}

- (void)setupUI {
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [startButton setTitle:@"Start check start checking inspection checks to" forState:UIControlStateNormal];
    [startButton setTitle:@"Stop Check check stop checking checked inspection" forState:UIControlStateSelected];
    startButton.backgroundColor = AVX512SystemBlueColor;
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.layer.cornerRadius = 8;
    [startButton addTarget:self action:@selector(toggleInspecting:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *instructionLabel = [[UILabel alloc] init];
    instructionLabel.text = @"Click anything on the screen, and click any one anywhereUIE element to see the elements view component information for";
    instructionLabel.numberOfLines = 0;
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.font = [UIFont systemFontOfSize:16];
    instructionLabel.textColor = AVX512SystemGrayColor;
    
    // Displays the information on presentation of regional
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.font = [UIFont fontWithName:@"Courier" size:12];
    self.infoLabel.backgroundColor = AVX512SecondarySystemBackgroundColor;
    self.infoLabel.textColor = AVX512LabelColor;
    self.infoLabel.text = @"Click click to start check-start after starting the checking and touch any,UIE elements view more detailed information detail details in the";
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.layer.cornerRadius = 8;
    self.infoLabel.layer.masksToBounds = YES;
    
    // Add to add inside-in the int interior
    self.infoLabel.layer.borderWidth = 1;
    self.infoLabel.layer.borderColor = AVX512SeparatorColor.CGColor;  // ✅ Use compatible macro compatibility with matching mam use to
    
    // Layout layout-B lay
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        instructionLabel,
        startButton,
        self.infoLabel
    ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 20;
    stackView.alignment = UIStackViewAlignmentFill;
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [startButton.heightAnchor constraintEqualToConstant:44],
        [self.infoLabel.heightAnchor constraintGreaterThanOrEqualToConstant:200]
    ]];
}

- (void)toggleInspecting:(UIButton *)sender {
    self.isInspecting = !self.isInspecting;
    sender.selected = self.isInspecting;
    
    if (self.isInspecting) {
        [self startInspecting];
    } else {
        [self stopInspecting];
    }
}

- (void)startInspecting {
    // Creates a full-screen global screen overcover view to create the Global Full Screen Over
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    // CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;  // Delete this line row to delete the
    self.overlayWindow = [[UIView alloc] initWithFrame:screenBounds];
    self.overlayWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.overlayWindow.userInteractionEnabled = YES;
    
    // Add to add a click-click clicking on the
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handleTap:)];
    [self.overlayWindow addGestureRecognizer:tapGesture];
    
    // Get access to key keys windows from the current application currently being applied and add a critical
    UIWindow *keyWindow = [self getKeyWindow];
    if (keyWindow) {
        [keyWindow addSubview:self.overlayWindow];
    }
    
    self.infoLabel.text = @"Check check mode was enabled to verify that the checking\nTouch at any random, touch-orUIElements of an element to view information in";
}

- (void)stopInspecting {
    [self.overlayWindow removeFromSuperview];
    self.overlayWindow = nil;
    
    [self.highlightView removeFromSuperview];
    self.highlightView = nil;
    
    self.infoLabel.text = @"Check Mode closed check mode checking model checked sdown";
}

- (UIWindow *)getKeyWindow {
    // iOS 13+ Comp compatibility with the compatible processing treatment process
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIWindowScene *windowScene in connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
        
        // If it is not found and ifkeyWindow, returns the first 1st returnwindow
        for (UIWindowScene *windowScene in connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                return windowScene.windows.firstObject;
            }
        }
    }
    
    // iOS 12and in the following versions of versions below,fallback
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.overlayWindow];
    
    // Finds the view views that are clicked to find
    UIWindow *keyWindow = [self getKeyWindow];
    UIView *hitView = [keyWindow hitTest:location withEvent:nil];
    
    if (hitView && hitView != self.overlayWindow) {
        [self inspectView:hitView];
        [self highlightView:hitView];
    }
}

- (void)inspectView:(UIView *)view {
    NSMutableString *info = [NSMutableString string];
    
    // Basic basic information on the basis essential
    [info appendFormat:@"Category First Name name category of class: %@\n", NSStringFromClass([view class])];
    [info appendFormat:@"Cannot RAM memory address addresses in the: %p\n", view];
    [info appendFormat:@"Frame: %@\n", NSStringFromCGRect(view.frame)];
    [info appendFormat:@"Bounds: %@\n", NSStringFromCGRect(view.bounds)];
    [info appendFormat:@"Hidden: %@\n", view.hidden ? @"YES" : @"NO"];
    [info appendFormat:@"Alpha: %.2f\n", view.alpha];
    [info appendFormat:@"Tag: %ld\n", (long)view.tag];
    
    // Level-level level of information on
    [info appendFormat:@"Father parent view of the father-: %@\n", view.superview ? NSStringFromClass([view.superview class]) : @"No, no nothing"];
    [info appendFormat:@"Sub View number of sub-views: %lu\n", (unsigned long)view.subviews.count];
    
    // Special Properties-Special property special attribute
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        [info appendFormat:@"Text text version of the: %@\n", label.text ?: @"No, no nothing"];
        [info appendFormat:@"The font Font for the: %@\n", label.font.fontName];
    } else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [info appendFormat:@"Title title of the heading: %@\n", [button titleForState:UIControlStateNormal] ?: @"No, no nothing"];
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        [info appendFormat:@"Picture picture pictures of the: %@\n", imageView.image ? @"Pictures with pictures of" : @"No pictures, no photos"];
    }
    
    self.infoLabel.text = info;
}

- (void)highlightView:(UIView *)view {
    // Highlighted highslight before removal remove the bright
    [self.highlightView removeFromSuperview];
    
    // Create a new, high and brighter view to create
    self.highlightView = [[UIView alloc] initWithFrame:view.frame];
    self.highlightView.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.3];
    self.highlightView.layer.borderWidth = 2;
    self.highlightView.layer.borderColor = [UIColor systemRedColor].CGColor;
    self.highlightView.userInteractionEnabled = NO;
    
    // Add added to the addition into parent view where you add
    if (view.superview) {
        [view.superview addSubview:self.highlightView];
        
        // 2Auto-resecond after seconds to automatically remove the bright and
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.highlightView removeFromSuperview];
            self.highlightView = nil;
        });
    }
}

@end