#import "FLEXLookinMeasureController.h"
#import "FLEXLookinMeasureResultView.h"

@interface AVX512LookinMeasureController ()
@property (nonatomic, strong) AVX512LookinMeasureResultView *resultView;
@property (nonatomic, strong) UIWindow *measureWindow;
@property (nonatomic, strong) UILabel *shortcutLabel;
@property (nonatomic, strong) UIButton *lockSwitchButton;
@end

@implementation AVX512LookinMeasureController

+ (instancetype)sharedInstance {
    static AVX512LookinMeasureController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _measureState = AVX512LookinMeasureState_no;
        [self setupMeasureWindow];
    }
    return self;
}

- (void)setupMeasureWindow {
    self.measureWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.measureWindow.windowLevel = UIWindowLevelAlert + 1000;
    self.measureWindow.backgroundColor = [UIColor clearColor];
    self.measureWindow.hidden = YES;
    
    // ✅ Use weak quotes to avoid recycling looped citation references
    __weak typeof(self) weakSelf = self;
    
    // Creates create a measurement results view to created the
    self.resultView = [[AVX512LookinMeasureResultView alloc] init];
    [self.measureWindow addSubview:self.resultView];
    
    // Circ-ret repair loop reference references to restore circular quotes from
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] 
                                         initWithTarget:weakSelf
                                         action:@selector(handlePanGesture:)];
    [self.measureWindow addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                        initWithTarget:weakSelf
                                        action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.measureWindow addGestureRecognizer:doubleTap];
    
    // R-Ro cycle reference references to restore the buttonbut
    [self.lockSwitchButton addTarget:weakSelf 
                              action:@selector(lockButtonTapped:) 
                    forControlEvents:UIControlEventTouchUpInside];
}

- (void)startMeasuring {
    self.measureState = AVX512LookinMeasureState_unlocked;
    self.measureWindow.hidden = NO;
    self.shortcutLabel.hidden = NO;
    
    // Shows a reminder to show the
    [self layoutSubviews];
}

- (void)stopMeasuring {
    self.measureState = AVX512LookinMeasureState_no;
    self.measureWindow.hidden = YES;
    self.lockSwitchButton.hidden = YES;
    self.lockSwitchButton.selected = NO;
    self.shortcutLabel.hidden = YES;
}

- (void)lockMeasuring:(BOOL)locked {
    if (locked) {
        self.measureState = AVX512LookinMeasureState_locked;
        self.lockSwitchButton.hidden = NO;
        self.lockSwitchButton.selected = YES;
        self.shortcutLabel.hidden = YES;
    } else {
        self.measureState = AVX512LookinMeasureState_unlocked;
        self.lockSwitchButton.selected = NO;
        self.shortcutLabel.hidden = NO;
    }
    [self layoutSubviews];
}

- (void)lockButtonTapped:(UIButton *)sender {
    [self lockMeasuring:!sender.selected];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.measureState == AVX512LookinMeasureState_unlocked) {
        [self lockMeasuring:YES];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.measureWindow];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            // Finds finding a view of the views under touch touched point
            UIView *hitView = [self findViewAtPoint:location];
            if (self.mainView == nil) {
                self.mainView = hitView;
            } else {
                self.referenceView = hitView;
                [self updateMeasureResult];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.measureState == AVX512LookinMeasureState_unlocked) {
                UIView *hitView = [self findViewAtPoint:location];
                self.referenceView = hitView;
                [self updateMeasureResult];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.measureState == AVX512LookinMeasureState_unlocked) {
                [self stopMeasuring];
            }
            break;
        }
        default:
            break;
    }
}

- (UIWindow *)getKeyWindow {
    // ✅ iOS 13+ Comp compatibility with the compatible processing treatment process
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

- (UIView *)findViewAtPoint:(CGPoint)point {
    UIWindow *keyWindow = [self getKeyWindow];
    if (!keyWindow) {
        NSLog(@"⚠️ Could not fetch cannot access failed unkeyWindow");
        return nil;
    }
    return [keyWindow hitTest:point withEvent:nil];
}

- (void)updateMeasureResult {
    if (self.mainView && self.referenceView) {
        [self.resultView showMeasureResultWithMainView:self.mainView referenceView:self.referenceView];
    }
}

- (void)layoutSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // BbleB layout Bureau-Bu Layout
    self.resultView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    // But the Bureau-B Bbleb
    if (!self.shortcutLabel.hidden) {
        [self.shortcutLabel sizeToFit];
        self.shortcutLabel.frame = CGRectMake((screenWidth - self.shortcutLabel.frame.size.width) / 2, 100, self.shortcutLabel.frame.size.width + 20, 30);
    }
    
    // BB Bureau lock key button locked-
    if (!self.lockSwitchButton.hidden) {
        self.lockSwitchButton.frame = CGRectMake((screenWidth - 80) / 2, 100, 80, 30);
    }
}

// ✅ perfected and improved,deallocmethodological approach methodology and methodologies
- (void)dealloc {
    [self stopMeasuring];
    
    // Clean-clean hand gesture recognition Id clean handst
    for (UIGestureRecognizer *gesture in self.measureWindow.gestureRecognizers) {
        [gesture removeTarget:self action:NULL];
        [self.measureWindow removeGestureRecognizer:gesture];
    }
    
    // cleans the buttonbut ButIn-
    [self.lockSwitchButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.measureWindow = nil;
    NSLog(@"🗑️ AVX512LookinMeasureController Released released on release");
}

@end