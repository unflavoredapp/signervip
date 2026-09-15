//
//  AVX512HierarchyViewController.m
//  FLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXHierarchyViewController.h"
#import "FLEXHierarchyTableViewController.h"
#import "FHSViewController.h"
#import "FLEXUtility.h"
#import "FLEXTabList.h"
#import "FLEXResources.h"
#import "UIBarButtonItem+FLEX.h"

typedef NS_ENUM(NSUInteger, AVX512HierarchyViewMode) {
    AVX512HierarchyViewModeTree = 1,
    AVX512HierarchyViewMode3DSnapshot
};

@interface AVX512HierarchyViewController ()
@property (nonatomic, readonly, weak) id<AVX512HierarchyDelegate> hierarchyDelegate;
@property (nonatomic, readonly) FHSViewController *snapshotViewController;
@property (nonatomic, readonly) AVX512HierarchyTableViewController *treeViewController;

@property (nonatomic) AVX512HierarchyViewMode mode;

@property (nonatomic, readonly) UIView *selectedView;
@end

@implementation AVX512HierarchyViewController

#pragma mark - Initialization

+ (instancetype)delegate:(id<AVX512HierarchyDelegate>)delegate {
    return [self delegate:delegate viewsAtTap:nil selectedView:nil];
}

+ (instancetype)delegate:(id<AVX512HierarchyDelegate>)delegate
              viewsAtTap:(NSArray<UIView *> *)viewsAtTap
            selectedView:(UIView *)selectedView {
    return [[self alloc] initWithDelegate:delegate viewsAtTap:viewsAtTap selectedView:selectedView];
}

- (id)initWithDelegate:(id)delegate viewsAtTap:(NSArray<UIView *> *)viewsAtTap selectedView:(UIView *)view {
    self = [super init];
    if (self) {
        NSArray<UIWindow *> *allWindows = AVX512Utility.allWindows;
        _hierarchyDelegate = delegate;
        _treeViewController = [AVX512HierarchyTableViewController
            windows:allWindows viewsAtTap:viewsAtTap selectedView:view
        ];

        if (viewsAtTap) {
            _snapshotViewController = [FHSViewController snapshotViewsAtTap:viewsAtTap selectedView:view];
        } else {
            _snapshotViewController = [FHSViewController snapshotWindows:allWindows];
        }

        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }

    return self;
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // 3D toggle button
    self.treeViewController.navigationItem.leftBarButtonItem = [UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.toggle3DIcon target:self action:@selector(toggleHierarchyMode)
    ];

    // Dismiss when tree view row is selected
    __weak id<AVX512HierarchyDelegate> delegate = self.hierarchyDelegate;
    self.treeViewController.didSelectRowAction = ^(UIView *selectedView) {
        [delegate viewHierarchyDidDismiss:selectedView];
    };

    // Start of in tree view
    _mode = AVX512HierarchyViewModeTree;
    [self pushViewController:self.treeViewController animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Done button: manually added here because the hierarhcy screens need to actually pass
    // data back to the explorer view controller so that it can highlight selected views
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)
    ];

    [super pushViewController:viewController animated:animated];
}


#pragma mark - Private

- (void)donePressed {
    // We need to manually close ourselves here because
    // AVX512NavigationController doesn't ever close tabs itself 
    [AVX512TabList.sharedList closeTab:self];
    [self.hierarchyDelegate viewHierarchyDidDismiss:self.selectedView];
}

- (void)toggleHierarchyMode {
    switch (self.mode) {
        case AVX512HierarchyViewModeTree:
            self.mode = AVX512HierarchyViewMode3DSnapshot;
            break;
        case AVX512HierarchyViewMode3DSnapshot:
            self.mode = AVX512HierarchyViewModeTree;
            break;
    }
}

- (void)setMode:(AVX512HierarchyViewMode)mode {
    if (mode != _mode) {
        // The tree view controller is our top stack view controller, and
        // changing the mode simply pushes the snapshot view. In the future,
        // I would like to have the 3D toggle button transparently switch
        // between two views instead of pushing a new view controller.
        // This way the views should share the search controller somehow.
        switch (mode) {
            case AVX512HierarchyViewModeTree:
                [self popViewControllerAnimated:NO];
                self.toolbarHidden = YES;
                self.treeViewController.selectedView = self.selectedView;
                break;
            case AVX512HierarchyViewMode3DSnapshot:
                [self pushViewController:self.snapshotViewController animated:NO];
                self.toolbarHidden = NO;
                self.snapshotViewController.selectedView = self.selectedView;
                break;
        }

        // Change this last so that self.selectedView works right above
        _mode = mode;
    }
}

- (UIView *)selectedView {
    switch (self.mode) {
        case AVX512HierarchyViewModeTree:
            return self.treeViewController.selectedView;
        case AVX512HierarchyViewMode3DSnapshot:
            return self.snapshotViewController.selectedView;
    }
}

@end
