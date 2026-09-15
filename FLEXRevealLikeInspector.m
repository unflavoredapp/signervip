#import "FLEXRevealLikeInspector.h"
#import "FLEXUtility.h"
#import <objc/runtime.h>

@interface AVX512RevealLikeInspector ()
@property (nonatomic, strong) UIWindow *inspectorWindow;
@property (nonatomic, strong) UIView *hierarchy3DContainer;
@property (nonatomic, strong) UIView *constraintsOverlay;
@property (nonatomic, strong) UIView *measurementsOverlay;
@property (nonatomic, strong) NSMutableArray<UIView *> *viewLayers;
@property (nonatomic, strong) NSMutableDictionary *originalTransforms;
@property (nonatomic, assign) BOOL liveEditingEnabled;
@property (nonatomic, strong) UIView *mutableSelectedView;

@property (nonatomic, assign) BOOL isLiveEditingEnabled;
@property (nonatomic, strong) UIToolbar *editingToolbar;
@property (nonatomic, weak) UIView *editingView;
@end

@implementation AVX512RevealLikeInspector

+ (instancetype)sharedInstance {
    static AVX512RevealLikeInspector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewLayers = [NSMutableArray new];
        _originalTransforms = [NSMutableDictionary new];
        _liveEditingEnabled = NO;
        [self setupInspectorWindow];
    }
    return self;
}

- (UIView *)selectedView {
    return self.mutableSelectedView;
}

#pragma mark - Window window set-up of the

- (void)setupInspectorWindow {
    self.inspectorWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.inspectorWindow.windowLevel = UIWindowLevelAlert + 200;
    self.inspectorWindow.backgroundColor = [UIColor clearColor];
    self.inspectorWindow.hidden = YES;
    
    // Add the add hand gesture recognition identification recognizing addedhand
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handleTap:)];
    [self.inspectorWindow addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] 
                                             initWithTarget:self 
                                             action:@selector(handlePinch:)];
    [self.inspectorWindow addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handlePan:)];
    [self.inspectorWindow addGestureRecognizer:panGesture];
}

#pragma mark - 3DView view level-level structure of the

- (void)show3DViewHierarchy {
    if (self.isInspecting) return;
    
    self.isInspecting = YES;
    
    // Create creation and create created3DContainer container of the packaging
    self.hierarchy3DContainer = [[UIView alloc] initWithFrame:self.inspectorWindow.bounds];
    self.hierarchy3DContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self.inspectorWindow addSubview:self.hierarchy3DContainer];
    
    // Shows a window to show the
    self.inspectorWindow.hidden = NO;
    
    // Build a building to build3DThe hierarchical structure of the hierarchy-
    [self build3DViewHierarchy];
    
    NSLog(@"3DThe view level-level structure of the View Horizontal Level");
}

- (void)hide3DViewHierarchy {
    if (!self.isInspecting) return;
    
    self.isInspecting = NO;
    
    // Clean view clean-cleans the
    [self.hierarchy3DContainer removeFromSuperview];
    self.hierarchy3DContainer = nil;
    
    // Clear Clean Selection clean-clean cleaning
    self.mutableSelectedView = nil;
    
    // Hide the hidden window to hide a
    self.inspectorWindow.hidden = YES;
    
    // Clean-up level clean up at
    [self.viewLayers removeAllObjects];
    
    NSLog(@"3DView level-level structure of the view hierarchy has hidden");
}

- (void)build3DViewHierarchy {
    UIWindow *keyWindow = [self getKeyWindow];
    if (!keyWindow) return;
    
    [self.viewLayers removeAllObjects];
    [self buildLayersForView:keyWindow.rootViewController.view depth:0];
    
    [self apply3DTransforms];
}

- (UIWindow *)getKeyWindow {
    // ✅ iOSComp compatibility with the compatible processing treatment process
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
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
}

- (void)buildLayersForView:(UIView *)view depth:(NSInteger)depth {
    // ✅ Reminds alarm warning to restore the logical logic operator operators ' first priority for
    if (!view || ([view isKindOfClass:[UIWindow class]] && view != [self getKeyWindow])) {
        return;
    }
    
    // Create creation and create created3DAn expression of an indication
    UIView *layer3D = [self create3DLayerForView:view depth:depth];
    [self.hierarchy3DContainer addSubview:layer3D];
    [self.viewLayers addObject:layer3D];
    
    // The Association 's relevance to the original
    objc_setAssociatedObject(layer3D, @"originalView", view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // In return, process the processing of sub-view view
    for (UIView *subview in view.subviews) {
        [self buildLayersForView:subview depth:depth + 1];
    }
}

- (UIView *)create3DLayerForView:(UIView *)view depth:(NSInteger)depth {
    UIView *layer = [[UIView alloc] init];
    
    // Set the setting of aframe(scaling to adapt adaptation for adaptive3D) (s). This is
    CGFloat scale = 0.3;
    CGRect scaledFrame = CGRectMake(view.frame.origin.x * scale,
                                   view.frame.origin.y * scale,
                                   view.frame.size.width * scale,
                                   view.frame.size.height * scale);
    layer.frame = scaledFrame;
    
    // Sets to set the settings for a
    layer.backgroundColor = view.backgroundColor ?: [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
    layer.layer.borderWidth = 1;
    layer.layer.borderColor = [UIColor systemBlueColor].CGColor;
    
    // Adds a tag tab label to
    UILabel *label = [[UILabel alloc] init];
    label.text = NSStringFromClass([view class]);
    label.font = [UIFont systemFontOfSize:8];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(layer.frame.size.width / 2, layer.frame.size.height / 2);
    [layer addSubview:label];
    
    return layer;
}

- (void)apply3DTransforms {
    for (NSInteger i = 0; i < self.viewLayers.count; i++) {
        UIView *layer = self.viewLayers[i];
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 1000.0; // Insight-vision viewing
        
        // Apply the application rotational rotated
        transform = CATransform3DRotate(transform, M_PI_4 / 2, 1, 0, 0);
        transform = CATransform3DRotate(transform, M_PI_4 / 4, 0, 1, 0);
        
        // ZAxi axis-axe offset trans
        CGFloat zOffset = i * 20;
        transform = CATransform3DTranslate(transform, 0, 0, zOffset);
        
        layer.layer.transform = transform;
    }
}

#pragma mark - Hand gestures and hand-hand handling

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (!self.isInspecting) return;
    
    CGPoint location = [gesture locationInView:self.hierarchy3DContainer];
    UIView *tappedView = [self.hierarchy3DContainer hitTest:location withEvent:nil];
    
    if (tappedView && tappedView != self.hierarchy3DContainer) {
        UIView *originalView = objc_getAssociatedObject(tappedView, @"originalView");
        if (originalView) {
            [self selectView:originalView];
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if (!self.isInspecting) return;
    
    static CGFloat initialScale = 1.0;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        initialScale = self.hierarchy3DContainer.transform.a;
    }
    
    CGFloat scale = initialScale * gesture.scale;
    scale = MAX(0.5, MIN(3.0, scale)); // Limits limit limits to limiting the zoo-in
    
    self.hierarchy3DContainer.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (!self.isInspecting) return;
    
    CGPoint translation = [gesture translationInView:self.inspectorWindow];
    
    // Apply the application to apply over-A
    self.hierarchy3DContainer.center = CGPointMake(
        self.hierarchy3DContainer.center.x + translation.x,
        self.hierarchy3DContainer.center.y + translation.y
    );
    
    [gesture setTranslation:CGPointZero inView:self.inspectorWindow];
}

- (void)selectView:(UIView *)view {
    self.mutableSelectedView = view;
    
    // Highlighting highlights highlighted high bright displays
    [self highlightSelectedView:view];
    
    // Notification to the agent- agency,
    if ([self.delegate respondsToSelector:@selector(revealInspector:didSelectView:)]) {
        [self.delegate revealInspector:self didSelectView:view];
    }
    
    NSLog(@"The selected view views Viewor Views: %@", NSStringFromClass([view class]));
}

- (void)highlightSelectedView:(UIView *)view {
    // Clear the pre-up high and brighter before
    for (UIView *layer in self.viewLayers) {
        layer.layer.borderWidth = 1;
        layer.layer.borderColor = [UIColor systemBlueColor].CGColor;
    }
    
    // Highlighting the highlight highlighted current present currently active selection
    for (UIView *layer in self.viewLayers) {
        UIView *originalView = objc_getAssociatedObject(layer, @"originalView");
        if (originalView == view) {
            layer.layer.borderWidth = 3;
            layer.layer.borderColor = [UIColor systemRedColor].CGColor;
            break;
        }
    }
}

#pragma mark - View bound view check on views review of

- (void)showViewConstraints:(UIView *)view {
    if (!view) return;
    
    [self hideViewConstraints]; // Prior to clearing the pre-clean before clears
    
    // Creates create a binding bounded OverCover
    self.constraintsOverlay = [[UIView alloc] initWithFrame:[self getKeyWindow].bounds];
    self.constraintsOverlay.backgroundColor = [UIColor clearColor];
    self.constraintsOverlay.userInteractionEnabled = NO;
    
    // Draws the drawing of bound binding line
    [self drawConstraintsForView:view];
    
    // Add to the window for adding added add
    [[self getKeyWindow] addSubview:self.constraintsOverlay];
    
    NSLog(@"Constrained display show was enabled to enable the");
}

- (void)hideViewConstraints {
    if (self.constraintsOverlay) {
        [self.constraintsOverlay removeFromSuperview];
        self.constraintsOverlay = nil;
        NSLog(@"Constrained display showing a constraint to show the");
    }
}

- (void)drawConstraintsForView:(UIView *)view {
    if (!view.superview) return;
    
    NSArray *constraints = view.superview.constraints;
    
    for (NSLayoutConstraint *constraint in constraints) {
        if (constraint.firstItem == view || constraint.secondItem == view) {
            [self drawConstraintLine:constraint];
            [self addConstraintLabel:constraint];
        }
    }
}

- (void)drawConstraintLine:(NSLayoutConstraint *)constraint {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor systemOrangeColor];
    
    // Sim simplified, streamlined and s simplify-simp
    CGRect firstFrame = [(UIView *)constraint.firstItem frame];
    
    // ✅ Repairs: Statement and use, if only needed; statement secondFrame
    CGRect lineFrame;
    
    // A line-line drawings to draw lines of the
    switch (constraint.firstAttribute) {
        case NSLayoutAttributeTop:
        case NSLayoutAttributeBottom: {
            lineFrame = CGRectMake(firstFrame.origin.x, firstFrame.origin.y, firstFrame.size.width, 2);
            
            // If there is a second view if you have the 2nd View,
            if (constraint.secondItem) {
                CGRect secondFrame = [(UIView *)constraint.secondItem frame];
                CGFloat midY = (firstFrame.origin.y + secondFrame.origin.y) / 2;
                lineFrame = CGRectMake(firstFrame.origin.x, midY, firstFrame.size.width, 2);
            }
            break;
        }
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeRight: {
            lineFrame = CGRectMake(firstFrame.origin.x, firstFrame.origin.y, 2, firstFrame.size.height);
            
            // If there is a second view if you have the 2nd View,
            if (constraint.secondItem) {
                CGRect secondFrame = [(UIView *)constraint.secondItem frame];
                CGFloat midX = (firstFrame.origin.x + secondFrame.origin.x) / 2;
                lineFrame = CGRectMake(midX, firstFrame.origin.y, 2, firstFrame.size.height);
            }
            break;
        }
        case NSLayoutAttributeWidth:
        case NSLayoutAttributeHeight: {
            // The size constraint is expressed as a dot-line in
            lineFrame = CGRectMake(firstFrame.origin.x, firstFrame.origin.y, firstFrame.size.width, firstFrame.size.height);
            line.alpha = 0.5;
            line.layer.borderWidth = 1;
            line.layer.borderColor = [UIColor systemOrangeColor].CGColor;
            line.backgroundColor = [UIColor clearColor];
            break;
        }
        default:
            lineFrame = CGRectMake(firstFrame.origin.x, firstFrame.origin.y, 2, 2);
            break;
    }
    
    line.frame = lineFrame;
    [self.constraintsOverlay addSubview:line];
}

- (void)addConstraintLabel:(NSLayoutConstraint *)constraint {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor systemOrangeColor];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    // simplified, streamlined binding restraint description of a
    NSString *description = [NSString stringWithFormat:@"%@ %@ %.1f",
                           [self stringFromLayoutAttribute:constraint.firstAttribute],
                           [self stringFromLayoutRelation:constraint.relation],
                           constraint.constant];
    
    label.text = description;
    [label sizeToFit];
    
    // Positioning position of the GPS tab
    CGRect firstFrame = [(UIView *)constraint.firstItem frame];
    label.center = CGPointMake(CGRectGetMidX(firstFrame), CGRectGetMidY(firstFrame));
    
    [self.constraintsOverlay addSubview:label];
}

- (NSString *)stringFromLayoutAttribute:(NSLayoutAttribute)attribute {
    switch (attribute) {
        case NSLayoutAttributeLeft: return @"L";
        case NSLayoutAttributeRight: return @"R";
        case NSLayoutAttributeTop: return @"T";
        case NSLayoutAttributeBottom: return @"B";
        case NSLayoutAttributeWidth: return @"W";
        case NSLayoutAttributeHeight: return @"H";
        case NSLayoutAttributeCenterX: return @"CX";
        case NSLayoutAttributeCenterY: return @"CY";
        default: return @"?";
    }
}

- (NSString *)stringFromLayoutRelation:(NSLayoutRelation)relation {
    switch (relation) {
        case NSLayoutRelationEqual: return @"=";
        case NSLayoutRelationLessThanOrEqual: return @"≤";
        case NSLayoutRelationGreaterThanOrEqual: return @"≥";
        default: return @"=";
    }
}

#pragma mark - View view survey measure of the views

- (void)showViewMeasurements:(UIView *)view {
    [self hideViewMeasurements]; // Measurement prior to clearance of the pre-cleaning
    
    if (!view) return;
    
    // Creates the creation to create a measurement coverage layer
    self.measurementsOverlay = [[UIView alloc] initWithFrame:[self getKeyWindow].bounds];  // ✅ Use the right property name to use using correct attribute
    self.measurementsOverlay.backgroundColor = [UIColor clearColor];
    self.measurementsOverlay.userInteractionEnabled = NO;
    
    // Adds the size 'S add-size comment
    [self addDimensionLabelsForView:view];
    
    // Adds a margin to add the distance markt for  
    [self addMarginLabelsForView:view];
    
    // Add to the window for adding added add
    [[self getKeyWindow] addSubview:self.measurementsOverlay];
}

- (void)hideViewMeasurements {
    if (self.measurementsOverlay) {
        [self.measurementsOverlay removeFromSuperview];
        self.measurementsOverlay = nil;
        NSLog(@"The measurement display of the measure shows that hidden hiding");
    }
}

- (void)addDimensionLabelsForView:(UIView *)view {
    CGRect frame = [view.superview convertRect:view.frame toView:nil];
    
    // The width pointer notation for the breadth of
    UILabel *widthLabel = [self createMeasurementLabel];
    widthLabel.text = [NSString stringWithFormat:@"%.1f", frame.size.width];
    widthLabel.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame) + 15);
    [self.measurementsOverlay addSubview:widthLabel];
    
    // Heighting of the high-high
    UILabel *heightLabel = [self createMeasurementLabel];
    heightLabel.text = [NSString stringWithFormat:@"%.1f", frame.size.height];
    heightLabel.center = CGPointMake(CGRectGetMaxX(frame) + 15, CGRectGetMidY(frame));
    heightLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.measurementsOverlay addSubview:heightLabel];
}

- (void)addMarginLabelsForView:(UIView *)view {
    if (!view.superview) return;
    
    CGRect viewFrame = [view.superview convertRect:view.frame toView:nil];
    CGRect superFrame = [view.superview convertRect:view.superview.bounds toView:nil];
    
    // Upper, upper- and up/over
    if (viewFrame.origin.y > superFrame.origin.y) {
        UILabel *topLabel = [self createMeasurementLabel];
        topLabel.text = [NSString stringWithFormat:@"%.1f", viewFrame.origin.y - superFrame.origin.y];
        topLabel.center = CGPointMake(CGRectGetMidX(viewFrame), (superFrame.origin.y + viewFrame.origin.y) / 2);
        [self.measurementsOverlay addSubview:topLabel];
    }
    
    // Left left-left, to the
    if (viewFrame.origin.x > superFrame.origin.x) {
        UILabel *leftLabel = [self createMeasurementLabel];
        leftLabel.text = [NSString stringWithFormat:@"%.1f", viewFrame.origin.x - superFrame.origin.x];
        leftLabel.center = CGPointMake((superFrame.origin.x + viewFrame.origin.x) / 2, CGRectGetMidY(viewFrame));
        [self.measurementsOverlay addSubview:leftLabel];
    }
}

- (UILabel *)createMeasurementLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor systemRedColor];
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 4;
    label.layer.masksToBounds = YES;
    return label;
}

- (void)addCrossHairsForView:(UIView *)view {
    CGRect frame = [view.superview convertRect:view.frame toView:nil];
    
    // Horizontal horizontal cross-c across lines in
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(frame), [UIScreen mainScreen].bounds.size.width, 1)];
    horizontalLine.backgroundColor = [UIColor systemRedColor];
    [self.measurementsOverlay addSubview:horizontalLine];
    
    // Vertical vertical cross across lines in the line
    UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(frame), 0, 1, [UIScreen mainScreen].bounds.size.height)];
    verticalLine.backgroundColor = [UIColor systemRedColor];
    [self.measurementsOverlay addSubview:verticalLine];
}

#pragma mark - Real-time real time editing the edit

- (void)enableLiveEditing {
    self.liveEditingEnabled = YES;
    
    // Adding an editorial edit editing hand gestures to the selected view for
    if (self.selectedView) {
        [self addEditingGesturesToView:self.selectedView];
    }
}

- (void)disableLiveEditing {
    self.liveEditingEnabled = NO;
    
    // Remove Edit edited edit editor gestures to remove the
    if (self.selectedView) {
        [self removeEditingGesturesFromView:self.selectedView];
    }
}

- (void)addEditingGesturesToView:(UIView *)view {
    // Adds drag- and pull gesture to add the dragged drop dragging hand
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] 
                                          initWithTarget:self 
                                          action:@selector(handleMoveGesture:)];
    moveGesture.minimumNumberOfTouches = 1;
    moveGesture.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:moveGesture];
    
    // Adds a squeezed hand gesture to add the co-conct
    UIPinchGestureRecognizer *scaleGesture = [[UIPinchGestureRecognizer alloc] 
                                             initWithTarget:self 
                                             action:@selector(handleScaleGesture:)];
    [view addGestureRecognizer:scaleGesture];
    
    // Adds a long and permanent press gesture to show the handk displaying
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleLongPressGesture:)];
    [view addGestureRecognizer:longPressGesture];
}

- (void)removeEditingGesturesFromView:(UIView *)view {
    NSArray *gestures = view.gestureRecognizers.copy;
    for (UIGestureRecognizer *gesture in gestures) {
        if (gesture.view == view && 
            ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ||
             [gesture isKindOfClass:[UIPinchGestureRecognizer class]] ||
             [gesture isKindOfClass:[UILongPressGestureRecognizer class]])) {
            [view removeGestureRecognizer:gesture];
        }
    }
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.liveEditingEnabled) return;
    
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:view.superview];
        
        // Refresh Update the refresh newer update3DView view views on the
        [self refresh3DViewHierarchy];
    }
}

- (void)handleScaleGesture:(UIPinchGestureRecognizer *)gesture {
    if (!self.liveEditingEnabled) return;
    
    UIView *view = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1.0;
        
        // Refresh Update the refresh newer update3DView view views on the
        [self refresh3DViewHierarchy];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (!self.liveEditingEnabled || gesture.state != UIGestureRecognizerStateBegan) return;
    
    self.editingView = gesture.view;
    [self showLiveEditingPanelForView:gesture.view];
}

- (void)selectViewForEditing:(UIView *)view {
    self.editingView = view;
    
    // Highlighting highlights highlight highlighted displays an edited editing view of the currently
    [self highlightEditingView:view];
    
    // Shows the display edit-ed Edit
    [self showEditingHint];
}

- (void)editBackgroundColor {
    if (!self.editingView) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Selects to select a background-B" 
                                                                   message:nil 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Pre-pre setting the pre settings colour color option
    NSArray *colors = @[
        @{@"name": @"Red red, red", @"color": [UIColor redColor]},
        @{@"name": @"Green green, and a", @"color": [UIColor greenColor]},
        @{@"name": @"Blue blue, blue and", @"color": [UIColor blueColor]},
        @{@"name": @"Yellow, yellow-ye", @"color": [UIColor yellowColor]},
        @{@"name": @"Transparency transparency and transparent,", @"color": [UIColor clearColor]},
    ];
    
    for (NSDictionary *colorInfo in colors) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:colorInfo[@"name"] 
                                                         style:UIAlertActionStyleDefault 
                                                       handler:^(UIAlertAction *action) {
            [self modifyView:self.editingView properties:@{@"backgroundColor": colorInfo[@"color"]}];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    UIViewController *topVC = [self topViewController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

- (void)modifyView:(UIView *)view properties:(NSDictionary *)properties {
    if (!view || !properties) return;
    
    for (NSString *property in properties.allKeys) {
        id value = properties[property];
        
        if ([property isEqualToString:@"backgroundColor"] && [value isKindOfClass:[UIColor class]]) {
            view.backgroundColor = value;
        } else if ([property isEqualToString:@"alpha"] && [value isKindOfClass:[NSNumber class]]) {
            view.alpha = [value floatValue];
        } else if ([property isEqualToString:@"hidden"] && [value isKindOfClass:[NSNumber class]]) {
            view.hidden = [value boolValue];
        }
        // More attribute support that can add more property properties to
    }
    
    // Refresh Update the refresh newer update3DShows the display of
    [self refresh3DViewHierarchy];
    
    NSLog(@"View property properties have been modified to modify the view: %@", properties);
}

- (void)showLiveEditingPanelForView:(UIView *)view {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit the editing view-ed edit"
                                                                   message:[NSString stringWithFormat:@"Edit Editor edit editing editorial %@", NSStringFromClass([view class])]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *backgroundAction = [UIAlertAction actionWithTitle:@"Background background for BB" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editBackgroundColor];
    }];
    
    UIAlertAction *frameAction = [UIAlertAction actionWithTitle:@"Frame" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editFrame];
    }];
    
    UIAlertAction *alphaAction = [UIAlertAction actionWithTitle:@"Transparency transparency and the transparent" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editAlpha];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:backgroundAction];
    [alert addAction:frameAction];
    [alert addAction:alphaAction];
    [alert addAction:cancelAction];
    
    UIViewController *topVC = [self topViewController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

- (void)editFrame {
    // Achieved, achieved and realizedFrameEdit Editor edit editing editorial
    NSLog(@"Edit Editor edit editing editorialFrameFunction function of a functional");
}

- (void)editAlpha {
    // Transparency transparency for the purpose of making transparent
    NSLog(@"Edit Transparency transparency transparent edit for editing the");
}

#pragma mark - Supporting methodological methods to assist methodologies and

- (void)highlightEditingView:(UIView *)view {
    // Highlighting to achieve high highlight brightness of the edit
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor systemRedColor].CGColor;
}

- (void)showEditingHint {
    // Achieved to achieve edit editing of the Edit
    NSLog(@"Shows the display edit-ed Edit");
}

- (void)refresh3DViewHierarchy {
    if (self.isInspecting) {
        [self build3DViewHierarchy];
    }
}

- (UIViewController *)topViewController {
    UIViewController *topController = [self getKeyWindow].rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - View capture and cross-catch catch & cutshot

- (UIImage *)captureViewHierarchy3D {
    if (!self.hierarchy3DContainer) return nil;
    
    UIGraphicsBeginImageContextWithOptions(self.hierarchy3DContainer.bounds.size, NO, 0);
    [self.hierarchy3DContainer.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)exportViewHierarchyDescription {
    UIWindow *keyWindow = [self getKeyWindow];
    if (!keyWindow) return;
    
    NSString *description = [self descriptionForView:keyWindow.rootViewController.view depth:0];
    
    // Saves saving to the clipboard Clipboard for save
    [UIPasteboard generalPasteboard].string = description;
    
    NSLog(@"View level-level structure of the view layer hierarchy has been exported to Clipboard clipboard");
}

- (NSString *)descriptionForView:(UIView *)view depth:(NSInteger)depth {
    NSMutableString *description = [NSMutableString string];
    
    // Adds an indent to the addition
    for (NSInteger i = 0; i < depth; i++) {
        [description appendString:@"  "];
    }
    
    // Adds to add the added view views
    [description appendFormat:@"%@ (%@)\n", 
     NSStringFromClass([view class]), 
     NSStringFromCGRect(view.frame)];
    
    // In return, process the processing of sub-view view
    for (UIView *subview in view.subviews) {
        [description appendString:[self descriptionForView:subview depth:depth + 1]];
    }
    
    return description;
}

@end