#import "FLEXLookinInspector.h"
#import "FLEXUtility.h"
#import <objc/runtime.h>

@implementation AVX512LookinViewNode

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ frame:%@", 
            NSStringFromClass([self class]), self, self.className, NSStringFromCGRect(self.frame)];
}

@end

@interface AVX512LookinInspector ()
@property (nonatomic, strong) UIWindow *inspectorWindow;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSMutableArray<AVX512LookinViewNode *> *mutableViewHierarchy;
@property (nonatomic, weak) UIView *mutableSelectedView;
@property (nonatomic, assign) BOOL mutableIsInspecting;
@property (nonatomic, strong) NSMutableDictionary *savedSnapshots;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

// 3DView views a view of the relevant properties
@property (nonatomic, strong) UIWindow *hierarchyWindow;
@property (nonatomic, assign) BOOL liveEditingEnabled;
@end

@implementation AVX512LookinInspector

+ (instancetype)sharedInstance {
    static AVX512LookinInspector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableViewHierarchy = [NSMutableArray new];
        _savedSnapshots = [NSMutableDictionary new];
        _viewMode = AVX512LookinViewModeHierarchy;
        [self setupGestures];
    }
    return self;
}

#pragma mark - Properties

- (NSArray<AVX512LookinViewNode *> *)viewHierarchy {
    return [self.mutableViewHierarchy copy];
}

- (UIView *)selectedView {
    return self.mutableSelectedView;
}

- (BOOL)isInspecting {
    return self.mutableIsInspecting;
}

#pragma mark - Check check-check controls and control

- (void)startInspecting {
    if (self.mutableIsInspecting) return;
    
    self.mutableIsInspecting = YES;
    
    // Creates a checker window to create the Check
    [self createInspectorWindow];
    
    // Refresh updated level-level structural structure for refreshing
    [self refreshViewHierarchy];
    
    // Enable enabled hand gestures to enable manual
    [self enableGestures];
    
    NSLog(@"LookinChecker has been activated for checkers to start");
}

- (void)stopInspecting {
    if (!self.mutableIsInspecting) return;
    
    self.mutableIsInspecting = NO;
    
    // Hide the hidden checker 's Inspector Checkers
    [self hideInspectorWindow];
    
    // Dis disables the use of hand gesture-dis
    [self disableGestures];
    
    // Clear clears clearing selection option to
    [self clearSelection];
    
    NSLog(@"LookinCheckchecker stopped checkers stop aborted checking");
}

- (void)createInspectorWindow {
    if (self.inspectorWindow) return;
    
    self.inspectorWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.inspectorWindow.windowLevel = UIWindowLevelAlert + 200;
    self.inspectorWindow.backgroundColor = [UIColor clearColor];
    self.inspectorWindow.hidden = NO;
    
    // Create created creation to create a coverage layer
    self.overlayView = [[UIView alloc] initWithFrame:self.inspectorWindow.bounds];
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self.inspectorWindow addSubview:self.overlayView];
}

- (void)hideInspectorWindow {
    self.inspectorWindow.hidden = YES;
    self.inspectorWindow = nil;
    self.overlayView = nil;
}

#pragma mark - Mod gestures settings setting set-

- (void)setupGestures {
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
}

- (void)enableGestures {
    [self.overlayView addGestureRecognizer:self.tapGesture];
    [self.overlayView addGestureRecognizer:self.panGesture];
}

- (void)disableGestures {
    [self.overlayView removeGestureRecognizer:self.tapGesture];
    [self.overlayView removeGestureRecognizer:self.panGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.overlayView];
    UIView *hitView = [self findViewAtPoint:location];
    
    if (hitView) {
        [self selectView:hitView];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    // TODO: To achieve drag- and pull to drop the dragged dragging
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:self.overlayView];
        UIView *hitView = [self findViewAtPoint:location];
        
        if (hitView && hitView != self.selectedView) {
            [self selectView:hitView];
        }
    }
}

#pragma mark - View view selection option for the views

- (void)selectView:(UIView *)view {
    if (self.mutableSelectedView == view) return;
    
    // Clears the selection option before clearing previous
    [self clearSelectionHighlight];
    
    self.mutableSelectedView = view;
    
    // Highlighting the highlighted selected view of a high-high
    [self highlightSelectedView];
    
    // Notification to the agent- agency,
    if ([self.delegate respondsToSelector:@selector(lookinInspector:didSelectView:)]) {
        [self.delegate lookinInspector:self didSelectView:view];
    }
}

- (void)clearSelection {
    [self clearSelectionHighlight];
    self.mutableSelectedView = nil;
}

- (void)highlightSelectedView {
    if (!self.selectedView) return;
    
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [self.selectedView.superview convertRect:self.selectedView.frame toView:keyWindow];
    
    // Create a bright and highlighted border frame box to create an
    UIView *highlightView = [[UIView alloc] initWithFrame:frame];
    highlightView.layer.borderWidth = 2;
    highlightView.layer.borderColor = [UIColor systemBlueColor].CGColor;
    highlightView.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.2];
    highlightView.tag = 99999; // Special tabs are used to identify special tag label
    
    [self.overlayView addSubview:highlightView];
}

- (void)clearSelectionHighlight {
    // Remove all highlighted and bright view views to remove All Highlight
    NSArray *subviews = [self.overlayView.subviews copy];
    for (UIView *view in subviews) {
        if (view.tag == 99999) {
            [view removeFromSuperview];
        }
    }
}

- (UIView *)findViewAtPoint:(CGPoint)point {
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    return [self findViewAtPoint:point inView:keyWindow];
}

- (UIView *)findViewAtPoint:(CGPoint)point inView:(UIView *)view {
    if (view.hidden || view.alpha < 0.01) return nil;
    if (view == self.inspectorWindow || view == self.overlayView) return nil;
    
    CGPoint localPoint = [view convertPoint:point fromView:[UIApplication sharedApplication].keyWindow];
    
    if (![view pointInside:localPoint withEvent:nil]) return nil;
    
    // Check sub-view view to check the Sub View (reverse order, top front priority) by checking
    for (UIView *subview in view.subviews.reverseObjectEnumerator) {
        UIView *hitView = [self findViewAtPoint:point inView:subview];
        if (hitView) return hitView;
    }
    
    return view;
}

#pragma mark - Level-level analytical level analysis of

- (void)refreshViewHierarchy {
    [self.mutableViewHierarchy removeAllObjects];
    
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        AVX512LookinViewNode *rootNode = [self createNodeForView:keyWindow depth:0];
        [self.mutableViewHierarchy addObject:rootNode];
        [self buildHierarchyForNode:rootNode];
    }
    
    // Notification to the agent- agency,
    if ([self.delegate respondsToSelector:@selector(lookinInspector:didUpdateHierarchy:)]) {
        [self.delegate lookinInspector:self didUpdateHierarchy:self.viewHierarchy];
    }
}

- (AVX512LookinViewNode *)createNodeForView:(UIView *)view depth:(NSInteger)depth {
    AVX512LookinViewNode *node = [[AVX512LookinViewNode alloc] init];
    node.view = view;
    node.frame = view.frame;
    node.bounds = view.bounds;
    node.transform = view.layer.transform;
    node.alpha = view.alpha;
    node.hidden = view.hidden;
    node.backgroundColor = view.backgroundColor;
    node.className = NSStringFromClass([view class]);
    node.depth = depth;
    node.children = [NSMutableArray new];
    
    return node;
}

- (void)buildHierarchyForNode:(AVX512LookinViewNode *)node {
    NSMutableArray *children = [NSMutableArray new];
    
    for (UIView *subview in node.view.subviews) {
        // Skip skips the view views related to a checker '
        if (subview == self.inspectorWindow || 
            [subview isDescendantOfView:self.inspectorWindow]) {
            continue;
        }
        
        AVX512LookinViewNode *childNode = [self createNodeForView:subview depth:node.depth + 1];
        childNode.parent = node;
        [children addObject:childNode];
        
        // Construct sub-level of the Sub layer level to build
        [self buildHierarchyForNode:childNode];
    }
    
    node.children = [children copy];
}

- (AVX512LookinViewNode *)nodeForView:(UIView *)view {
    return [self findNodeForView:view inNodes:self.viewHierarchy];
}

- (AVX512LookinViewNode *)findNodeForView:(UIView *)view inNodes:(NSArray<AVX512LookinViewNode *> *)nodes {
    for (AVX512LookinViewNode *node in nodes) {
        if (node.view == view) {
            return node;
        }
        
        AVX512LookinViewNode *foundNode = [self findNodeForView:view inNodes:node.children];
        if (foundNode) {
            return foundNode;
        }
    }
    return nil;
}

- (NSArray<AVX512LookinViewNode *> *)flattenedHierarchy {
    NSMutableArray *flattened = [NSMutableArray new];
    [self flattenNodes:self.viewHierarchy intoArray:flattened];
    return [flattened copy];
}

- (void)flattenNodes:(NSArray<AVX512LookinViewNode *> *)nodes intoArray:(NSMutableArray *)array {
    for (AVX512LookinViewNode *node in nodes) {
        [array addObject:node];
        [self flattenNodes:node.children intoArray:array];
    }
}

#pragma mark - A quick-shot, snapshots

- (UIImage *)captureViewSnapshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (void)saveHierarchySnapshot:(NSString *)name {
    NSMutableDictionary *snapshot = [NSMutableDictionary new];
    snapshot[@"name"] = name;
    snapshot[@"timestamp"] = [NSDate date];
    snapshot[@"hierarchy"] = [self serializeHierarchy:self.viewHierarchy];
    
    self.savedSnapshots[name] = snapshot;
    
    NSLog(@"Save saved save already saving stored snapshotshot: %@", name);
}

- (NSArray *)loadSavedSnapshots {
    return [self.savedSnapshots.allValues sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]
    ]];
}

- (NSArray *)serializeHierarchy:(NSArray<AVX512LookinViewNode *> *)nodes {
    NSMutableArray *serialized = [NSMutableArray new];
    
    for (AVX512LookinViewNode *node in nodes) {
        NSMutableDictionary *nodeDict = [NSMutableDictionary new];
        nodeDict[@"className"] = node.className;
        nodeDict[@"frame"] = NSStringFromCGRect(node.frame);
        nodeDict[@"bounds"] = NSStringFromCGRect(node.bounds);
        nodeDict[@"alpha"] = @(node.alpha);
        nodeDict[@"hidden"] = @(node.hidden);
        nodeDict[@"depth"] = @(node.depth);
        
        if (node.backgroundColor) {
            nodeDict[@"backgroundColor"] = [self colorToHexString:node.backgroundColor];
        }
        
        if (node.children.count > 0) {
            nodeDict[@"children"] = [self serializeHierarchy:node.children];
        }
        
        [serialized addObject:nodeDict];
    }
    
    return [serialized copy];
}

#pragma mark - Contras the function to compare functions

- (void)compareWithSnapshot:(NSString *)snapshotName {
    NSDictionary *snapshot = self.savedSnapshots[snapshotName];
    if (!snapshot) {
        NSLog(@"The absence of a non-existent: %@", snapshotName);
        return;
    }
    
    // Refreshs the current level-level structural structure to refresh
    [self refreshViewHierarchy];
    
    // Comparative comparison of comparative variances, variance
    NSArray *changes = [self findChangedViewsBetweenSnapshot:snapshotName];
    
    // brightly highlighted view views on high-highed changes
    [self highlightChangedViews:changes];
    
    NSLog(@"Found find found in a %lu individual change changes in the number of", (unsigned long)changes.count);
}

- (NSArray *)findChangedViewsBetweenSnapshot:(NSString *)snapshotName {
    NSDictionary *snapshot = self.savedSnapshots[snapshotName];
    if (!snapshot) return @[];
    
    NSArray *savedHierarchy = snapshot[@"hierarchy"];
    NSArray *currentHierarchy = [self serializeHierarchy:self.viewHierarchy];
    
    return [self compareHierarchy:currentHierarchy withSaved:savedHierarchy];
}

- (NSArray *)compareHierarchy:(NSArray *)current withSaved:(NSArray *)saved {
    NSMutableArray *changes = [NSMutableArray new];
    
    // A simple comparison of a simpler contrast ratio - Further optimization could be further optimized
    if (current.count != saved.count) {
        [changes addObject:@{@"type": @"count_changed", @"current": @(current.count), @"saved": @(saved.count)}];
    }
    
    // TODO: Achievement of a more detailed, comparable comparative comparison and
    
    return [changes copy];
}

- (void)highlightChangedViews:(NSArray *)changes {
    // TODO: To achieve change view changes views for a high, bright and
}

#pragma mark - Supporting methodological methods to assist methodologies and

- (NSString *)colorToHexString:(UIColor *)color {
    if (!color) return @"#000000";
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", 
            (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
}

#pragma mark - 3DViews view level-level of the View

- (void)show3DViewHierarchy {
    if (!self.isInspecting) return;
    
    // Create creation and create created3DLevel-level level view window views the
    if (!self.hierarchyWindow) {
        self.hierarchyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.hierarchyWindow.windowLevel = UIWindowLevelAlert - 10;
        self.hierarchyWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        // Add added hand gesture control controlled controls to add the
        [self setup3DGestures];
    }
    
    self.hierarchyWindow.hidden = NO;
    [self render3DHierarchy];
}

- (void)hide3DViewHierarchy {
    self.hierarchyWindow.hidden = YES;
}

- (void)setup3DGestures {
    // Rotated hand-and rotate hands rotation
    UIPanGestureRecognizer *rotationGesture = [[UIPanGestureRecognizer alloc] 
                                              initWithTarget:self 
                                              action:@selector(handleRotationGesture:)];
    [self.hierarchyWindow addGestureRecognizer:rotationGesture];
    
    // Now, let go and move in the
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] 
                                             initWithTarget:self 
                                             action:@selector(handlePinchGesture:)];
    [self.hierarchyWindow addGestureRecognizer:pinchGesture];
    
    // Click clicking on click to select the selected hand gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handle3DTapGesture:)];
    [self.hierarchyWindow addGestureRecognizer:tapGesture];
}

- (void)render3DHierarchy {
    // Clear the pre-pre clean before clearing3DView view views on the
    [self.hierarchyWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // To create a creation for every view to3DAn expression of an indication
    for (AVX512LookinViewNode *node in self.viewHierarchy) {
        [self create3DRepresentationForNode:node];
    }
}

- (UIView *)create3DRepresentationForNode:(AVX512LookinViewNode *)node {
    if (!node.view || node.view.hidden || node.view.alpha < 0.01) return nil;
    
    // Create creation and create created3DView the view container vessel for a
    UIView *container3D = [[UIView alloc] init];
    container3D.backgroundColor = [UIColor clearColor];
    
    // Create a view- views snapshots image to create
    UIView *snapshot = [self createSnapshotOfView:node.view];
    [container3D addSubview:snapshot];
    
    // Apply application applications to apply3DChange changes change conversion to convert V
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 500.0; // View the effects of a viewing from
    
    // Application of application applications based on level-ZAxi axis-axe offset trans
    CGFloat zOffset = node.depth * 20.0;
    transform = CATransform3DTranslate(transform, 0, 0, zOffset);
    
    container3D.layer.transform = transform;
    container3D.frame = node.frame;
    
    // Adds added to add the addition3DWindow window of the windows
    [self.hierarchyWindow addSubview:container3D];
    
    // Process process sub-view viewing of
    for (AVX512LookinViewNode *childNode in node.children) {
        [self create3DRepresentationForNode:childNode];
    }
    
    return container3D;
}

- (UIView *)createSnapshotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotView = [[UIImageView alloc] initWithImage:snapshotImage];
    snapshotView.frame = view.bounds;
    snapshotView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Add Borders to add a border box so that borders
    snapshotView.layer.borderWidth = 1;
    snapshotView.layer.borderColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.5].CGColor;
    
    return snapshotView;
}

#pragma mark - 3DHand gestures and hand-hand handling

- (void)handleRotationGesture:(UIPanGestureRecognizer *)gesture {
    static CGPoint lastTranslation;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastTranslation = CGPointZero;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.hierarchyWindow];
        CGPoint delta = CGPointMake(translation.x - lastTranslation.x, translation.y - lastTranslation.y);
        
        // Apply the application rotation rotates to all, and3DView view views on the
        for (UIView *view in self.hierarchyWindow.subviews) {
            CATransform3D currentTransform = view.layer.transform;
            CATransform3D rotation = CATransform3DRotate(CATransform3DIdentity, 
                                                       delta.y * 0.01, 1, 0, 0);
            rotation = CATransform3DRotate(rotation, delta.x * 0.01, 0, 1, 0);
            view.layer.transform = CATransform3DConcat(currentTransform, rotation);
        }
        
        lastTranslation = translation;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    static CGFloat lastScale = 1.0;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat deltaScale = gesture.scale / lastScale;
        
        // Applys the zoom to all of everything applying3DView view views on the
        for (UIView *view in self.hierarchyWindow.subviews) {
            CATransform3D currentTransform = view.layer.transform;
            CATransform3D scale = CATransform3DScale(CATransform3DIdentity, deltaScale, deltaScale, deltaScale);
            view.layer.transform = CATransform3DConcat(currentTransform, scale);
        }
        
        lastScale = gesture.scale;
    }
}

- (void)handle3DTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.hierarchyWindow];
    
    // Found the click clicking to find hits found3DView view views on the
    UIView *hitView = [self.hierarchyWindow hitTest:location withEvent:nil];
    if (hitView && hitView != self.hierarchyWindow) {
        // Found the corresponding original raw view of an en corresponds to
        UIView *originalView = [self findOriginalViewFor3DView:hitView];
        if (originalView) {
            [self selectView:originalView];
            
            // Highlights highlighted highlights the selected selection to highlight high3DView view views on the
            [self highlight3DView:hitView];
        }
    }
}

- (UIView *)findOriginalViewFor3DView:(UIView *)view3D {
    // Here there is a need here to3DThe map relationship of the view views to a mapping relation between survey and original
    // This is achieved through simplification, simplified and streamlined toframeMatch match matching matches a
    for (AVX512LookinViewNode *node in [self flattenHierarchy:self.viewHierarchy]) {
        if (CGRectEqualToRect(node.frame, view3D.frame)) {
            return node.view;
        }
    }
    return nil;
}

- (void)highlight3DView:(UIView *)view3D {
    // Clear the pre-up high and brighter before
    [self clearAll3DHighlights];
    
    // Adds a bright Highlighting effect to add highlighted
    view3D.layer.borderWidth = 3;
    view3D.layer.borderColor = [UIColor systemRedColor].CGColor;
    view3D.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.3];
}

- (void)clearAll3DHighlights {
    for (UIView *view in self.hierarchyWindow.subviews) {
        view.layer.borderWidth = 1;
        view.layer.borderColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.5].CGColor;
        view.backgroundColor = [UIColor clearColor];
    }
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
    UIPinchGestureRecognizer *resizeGesture = [[UIPinchGestureRecognizer alloc] 
                                              initWithTarget:self 
                                              action:@selector(handleResizeGesture:)];
    [view addGestureRecognizer:resizeGesture];
}

- (void)removeEditingGesturesFromView:(UIView *)view {
    NSArray *gestures = [view.gestureRecognizers copy];
    for (UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] ||
            [gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [view removeGestureRecognizer:gesture];
        }
    }
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.liveEditingEnabled) return;
    
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    
    CGRect newFrame = view.frame;
    newFrame.origin.x += translation.x;
    newFrame.origin.y += translation.y;
    
    view.frame = newFrame;
    [gesture setTranslation:CGPointZero inView:view.superview];
    
    // Update update updating updates updated3DView view views on the
    [self render3DHierarchy];
}

- (void)handleResizeGesture:(UIPinchGestureRecognizer *)gesture {
    if (!self.liveEditingEnabled) return;
    
    UIView *view = gesture.view;
    CGFloat scale = gesture.scale;
    
    CGRect newFrame = view.frame;
    newFrame.size.width *= scale;
    newFrame.size.height *= scale;
    
    view.frame = newFrame;
    gesture.scale = 1.0;
    
    // Update update updating updates updated3DView view views on the
    [self render3DHierarchy];
}

#pragma mark - Supporting methodological methods to assist methodologies and

- (NSArray<AVX512LookinViewNode *> *)flattenHierarchy:(NSArray<AVX512LookinViewNode *> *)hierarchy {
    NSMutableArray *flattened = [NSMutableArray new];
    
    for (AVX512LookinViewNode *node in hierarchy) {
        [flattened addObject:node];
        if (node.children.count > 0) {
            [flattened addObjectsFromArray:[self flattenHierarchy:node.children]];
        }
    }
    
    return flattened;
}

@end