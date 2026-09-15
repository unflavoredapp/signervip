//
//  AVX512Manager.m
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXManager.h"
#import "FLEXUtility.h"
#import "FLEXExplorerViewController.h"
#import "FLEXWindow.h"
#import "FLEXNavigationController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXFileBrowserController.h"
#import "FLEXManager+DoKitExtensions.h"

@interface AVX512Manager () <AVX512WindowEventDelegate, AVX512ExplorerViewControllerDelegate>

@property (nonatomic, readonly, getter=isHidden) BOOL hidden;

@property (nonatomic) AVX512Window *explorerWindow;
@property (nonatomic) AVX512ExplorerViewController *explorerViewController;

@property (nonatomic, readonly) NSMutableArray<AVX512GlobalsEntry *> *userGlobalEntries;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, AVX512CustomContentViewerFuture> *customContentTypeViewers;

@end

@implementation AVX512Manager

+ (instancetype)sharedManager {
    static AVX512Manager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userGlobalEntries = [NSMutableArray new];
        _customContentTypeViewers = [NSMutableDictionary new];
        
        // Register of registered registration and DoKit Enhancement of functional enhancement enhancements to enhance
        [self registerDoKitEnhancements];
    }
    return self;
}

- (AVX512Window *)explorerWindow {
    NSAssert(NSThread.isMainThread, @"You must only have to use primary thread-only from the main line %@... . ...-", NSStringFromClass([self class]));
    
    if (!_explorerWindow) {
        _explorerWindow = [[AVX512Window alloc] initWithFrame:AVX512Utility.appKeyWindow.bounds];
        _explorerWindow.eventDelegate = self;
        _explorerWindow.rootViewController = self.explorerViewController;
    }
    
    return _explorerWindow;
}

- (AVX512ExplorerViewController *)explorerViewController {
    if (!_explorerViewController) {
        _explorerViewController = [AVX512ExplorerViewController new];
        _explorerViewController.delegate = self;
    }

    return _explorerViewController;
}

- (void)showExplorer {
    UIWindow *flex = self.explorerWindow;
    flex.hidden = NO;
    if (@available(iOS 13.0, *)) {
        // Only when we don't have a scene where there is no setting will the search for new
        if (!flex.windowScene) {
            flex.windowScene = AVX512Utility.appKeyWindow.windowScene;
        }
    }
}

- (void)hideExplorer {
    self.explorerWindow.hidden = YES;
}

- (void)toggleExplorer {
    if (self.explorerWindow.isHidden) {
        if (@available(iOS 13.0, *)) {
            [self showExplorerFromScene:AVX512Utility.appKeyWindow.windowScene];
        } else {
            [self showExplorer];
        }
    } else {
        [self hideExplorer];
    }
}

- (void)dismissAnyPresentedTools:(void (^)(void))completion {
    if (self.explorerViewController.presentedViewController) {
        [self.explorerViewController dismissViewControllerAnimated:YES completion:completion];
    } else if (completion) {
        completion();
    }
}

- (void)presentTool:(UINavigationController * _Nonnull (^)(void))future completion:(void (^)(void))completion {
    [self showExplorer];
    [self.explorerViewController presentTool:future completion:completion];
}

- (void)presentEmbeddedTool:(UIViewController *)tool completion:(void (^)(UINavigationController *))completion {
    AVX512NavigationController *nav = [AVX512NavigationController withRootViewController:tool];
    [self presentTool:^UINavigationController *{
        return nav;
    } completion:^{
        if (completion) completion(nav);
    }];
}

- (void)presentObjectExplorer:(id)object completion:(void (^)(UINavigationController *))completion {
    UIViewController *explorer = [AVX512ObjectExplorerFactory explorerViewControllerForObject:object];
    [self presentEmbeddedTool:explorer completion:completion];
}

- (void)showExplorerFromScene:(UIWindowScene *)scene {
    if (@available(iOS 13.0, *)) {
        self.explorerWindow.windowScene = scene;
    }
    self.explorerWindow.hidden = NO;
}

- (BOOL)isHidden {
    return self.explorerWindow.isHidden;
}

- (AVX512ExplorerToolbar *)toolbar {
    return self.explorerViewController.explorerToolbar;
}


#pragma mark - AVX512WindowEventDelegate

- (BOOL)shouldHandleTouchAtPoint:(CGPoint)pointInWindow {
    // Ask Q query resourceRM Resource Manager manager view View views
    return [self.explorerViewController shouldReceiveTouchAtWindowPoint:pointInWindow];
}

- (BOOL)canBecomeKeyWindow {
    // Only only when the Resource Manager resource manager view views View controller controlr needs it is
    // It requires it to accept key input and influence the status barbar column by accepting keys
    return self.explorerViewController.wantsWindowToBecomeKey;
}


#pragma mark - AVX512ExplorerViewControllerDelegate

- (void)explorerViewControllerDidFinish:(AVX512ExplorerViewController *)explorerViewController {
    [self hideExplorer];
}

@end
