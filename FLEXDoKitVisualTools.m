#import "FLEXDoKitVisualTools.h"

@interface AVX512DoKitVisualTools ()
@property (nonatomic, strong) UIWindow *colorPickerWindow;
@property (nonatomic, strong) UIView *rulerView;
@property (nonatomic, strong) UIView *borderOverlayView;
@property (nonatomic, strong) UIView *layoutBoundsView;
@property (nonatomic, assign) BOOL isColorPickerActive;
@property (nonatomic, assign) BOOL isRulerVisible;
@property (nonatomic, assign) BOOL areBordersVisible;
@property (nonatomic, assign) BOOL areLayoutBoundsVisible;
@end

@implementation AVX512DoKitVisualTools

+ (instancetype)sharedInstance {
    static AVX512DoKitVisualTools *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Colour-colored straws in colour

- (void)startColorPicker {
    if (self.isColorPickerActive) return;
    
    self.isColorPickerActive = YES;
    
    // Creates a window to create full-screen wide screen
    self.colorPickerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.colorPickerWindow.windowLevel = UIWindowLevelAlert + 100;
    self.colorPickerWindow.backgroundColor = [UIColor clearColor];
    self.colorPickerWindow.hidden = NO;
    
    // Add the add hand gesture recognition identification recognizing addedhand
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handleColorPickerTap:)];
    [self.colorPickerWindow addGestureRecognizer:tapGesture];
    
    // Shows a reminder to show the
    [self showColorPickerHUD];
}

- (void)stopColorPicker {
    self.isColorPickerActive = NO;
    self.colorPickerWindow.hidden = YES;
    self.colorPickerWindow = nil;
}

- (void)handleColorPickerTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.colorPickerWindow];
    UIColor *color = [self getColorAtPoint:location];
    
    [self showColorInfo:color atPoint:location];
}

- (UIColor *)getColorAtPoint:(CGPoint)point {
    // Get a screensc Screenshot to fetch the
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, 0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Gets a pixel colour color to get the P
    CGImageRef imageRef = screenshot.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    if (point.x < 0 || point.x >= width || point.y < 0 || point.y >= height) {
        return [UIColor blackColor];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(rawData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(-point.x, -point.y, width, height), imageRef);
    CGContextRelease(context);
    
    CGFloat red = rawData[0] / 255.0;
    CGFloat green = rawData[1] / 255.0;
    CGFloat blue = rawData[2] / 255.0;
    CGFloat alpha = rawData[3] / 255.0;
    
    free(rawData);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)showColorInfo:(UIColor *)color atPoint:(CGPoint)point {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSString *hexColor = [NSString stringWithFormat:@"#%02X%02X%02X", 
                         (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Colour Information Color Info colour information color" 
                                                                   message:[NSString stringWithFormat:@"RGB: (%.0f, %.0f, %.0f)\nHex: %@", red*255, green*255, blue*255, hexColor]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy copy-copy duplicate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].string = hexColor;
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self stopColorPicker];
    }];
    
    [alert addAction:copyAction];
    [alert addAction:closeAction];
    
    UIViewController *topViewController = [self topViewController];
    [topViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showColorPickerHUD {
    // Shows the use of this hint-
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"Click click on the screensscreen to get colour\nDouble double-click both twice to exit";
    hintLabel.numberOfLines = 2;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.layer.cornerRadius = 8;
    hintLabel.clipsToBounds = YES;
    hintLabel.frame = CGRectMake(0, 0, 200, 60);
    hintLabel.center = CGPointMake(self.colorPickerWindow.bounds.size.width / 2, 100);
    
    [self.colorPickerWindow addSubview:hintLabel];
    
    // Add double-clicking hand gestures to add a two
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                        initWithTarget:self 
                                        action:@selector(stopColorPicker)];
    doubleTap.numberOfTapsRequired = 2;
    [self.colorPickerWindow addGestureRecognizer:doubleTap];
}

#pragma mark - Alignment alignment to align the rule rules of

- (void)showRuler {
    if (self.isRulerVisible) return;
    
    self.isRulerVisible = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.rulerView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.rulerView.backgroundColor = [UIColor clearColor];
    self.rulerView.userInteractionEnabled = NO;
    
    // Adds a horizontal and vertical rule line to add the lines of rules
    [self addRulerLines];
    
    [keyWindow addSubview:self.rulerView];
}

- (void)hideRuler {
    self.isRulerVisible = NO;
    [self.rulerView removeFromSuperview];
    self.rulerView = nil;
}

- (void)addRulerLines {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // Vertical lines of vertical line (per each per straight10Point of point (point rule)(
    for (int x = 0; x <= screenWidth; x += 10) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, screenHeight)];
        line.backgroundColor = (x % 50 == 0) ? [UIColor redColor] : [[UIColor redColor] colorWithAlphaComponent:0.3];
        [self.rulerView addSubview:line];
    }
    
    // Horizontal lines (of horizontal line(s) of10Point of point (point rule)(
    for (int y = 0; y <= screenHeight; y += 10) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, screenWidth, 1)];
        line.backgroundColor = (y % 50 == 0) ? [UIColor redColor] : [[UIColor redColor] colorWithAlphaComponent:0.3];
        [self.rulerView addSubview:line];
    }
}

#pragma mark - View views view border frame box for the

- (void)showViewBorders {
    if (self.areBordersVisible) return;
    
    self.areBordersVisible = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.borderOverlayView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.borderOverlayView.backgroundColor = [UIColor clearColor];
    self.borderOverlayView.userInteractionEnabled = NO;
    
    [self addViewBordersRecursively:keyWindow];
    
    [keyWindow addSubview:self.borderOverlayView];
}

- (void)hideViewBorders {
    self.areBordersVisible = NO;
    [self.borderOverlayView removeFromSuperview];
    self.borderOverlayView = nil;
}

- (void)addViewBordersRecursively:(UIView *)view {
    if (view == self.borderOverlayView) return;
    
    // Adds Border border to the list of
    UIView *borderView = [[UIView alloc] initWithFrame:view.frame];
    borderView.layer.borderWidth = 1;
    borderView.layer.borderColor = [UIColor redColor].CGColor;
    borderView.backgroundColor = [UIColor clearColor];
    
    // Convert the conversion of coordinates system systems to
    CGRect convertedFrame = [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow];
    borderView.frame = convertedFrame;
    
    [self.borderOverlayView addSubview:borderView];
    
    // In return, process the processing of sub-view view
    for (UIView *subview in view.subviews) {
        [self addViewBordersRecursively:subview];
    }
}

#pragma mark - laid, well- but layout and

- (void)showLayoutBounds {
    if (self.areLayoutBoundsVisible) return;
    
    self.areLayoutBoundsVisible = YES;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.layoutBoundsView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.layoutBoundsView.backgroundColor = [UIColor clearColor];
    self.layoutBoundsView.userInteractionEnabled = NO;
    
    [self addLayoutBoundsRecursively:keyWindow];
    
    [keyWindow addSubview:self.layoutBoundsView];
}

- (void)hideLayoutBounds {
    self.areLayoutBoundsVisible = NO;
    [self.layoutBoundsView removeFromSuperview];
    self.layoutBoundsView = nil;
}

- (void)addLayoutBoundsRecursively:(UIView *)view {
    if (view == self.layoutBoundsView) return;
    
    // Displays the display of bound-bound
    UIView *boundsView = [[UIView alloc] initWithFrame:view.bounds];
    boundsView.layer.borderWidth = 2;
    boundsView.layer.borderColor = [UIColor blueColor].CGColor;
    boundsView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    
    CGRect convertedFrame = [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow];
    boundsView.frame = convertedFrame;
    
    [self.layoutBoundsView addSubview:boundsView];
    
    // In return, process the processing of sub-view view
    for (UIView *subview in view.subviews) {
        [self addLayoutBoundsRecursively:subview];
    }
}

#pragma mark - Supporting methodological methods to assist methodologies and

- (UIViewController *)topViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end