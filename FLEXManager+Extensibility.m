//
//  AVX512Manager+Extensibility.m
//  FLEX
//
//  Created by Tanner on 2/2/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXManager+Extensibility.h"
#import "FLEXManager+Private.h"
#import "FLEXNavigationController.h"
#import "FLEXObjectExplorerFactory.h"
#if TARGET_OS_SIMULATOR
#import "FLEXKeyboardShortcutManager.h"
#endif
#import "FLEXExplorerViewController.h"
#import "FLEXNetworkMITMViewController.h"
#import "FLEXKeyboardHelpViewController.h"
#import "FLEXFileBrowserController.h"
#import "FLEXArgumentInputStructView.h"
#import "FLEXUtility.h"

@interface AVX512Manager (ExtensibilityPrivate)
@property (nonatomic, readonly) UIViewController *topViewController;
@end

@implementation AVX512Manager (Extensibility)

#if TARGET_OS_SIMULATOR
@dynamic simulatorShortcutsEnabled;
#else
@dynamic simulatorShortcutsEnabled;
#endif

#pragma mark - Global All-Global global across all on

- (void)registerGlobalEntryWithName:(NSString *)entryName objectFutureBlock:(id (^)(void))objectFutureBlock {
    NSParameterAssert(entryName);
    NSParameterAssert(objectFutureBlock);
    NSAssert(NSThread.isMainThread, @"This method must be called from the main line path.");

    entryName = entryName.copy;
    AVX512GlobalsEntry *entry = [AVX512GlobalsEntry entryWithNameFuture:^NSString *{
        return entryName;
    } viewControllerFuture:^UIViewController *{
        return [AVX512ObjectExplorerFactory explorerViewControllerForObject:objectFutureBlock()];
    }];

    [self.userGlobalEntries addObject:entry];
}

- (void)registerGlobalEntryWithName:(NSString *)entryName viewControllerFutureBlock:(UIViewController * (^)(void))viewControllerFutureBlock {
    NSParameterAssert(entryName);
    NSParameterAssert(viewControllerFutureBlock);
    NSAssert(NSThread.isMainThread, @"This method must be called from the main line path.");

    entryName = entryName.copy;
    AVX512GlobalsEntry *entry = [AVX512GlobalsEntry entryWithNameFuture:^NSString *{
        return entryName;
    } viewControllerFuture:^UIViewController *{
        UIViewController *viewController = viewControllerFutureBlock();
        NSCAssert(viewController, @"'%@' The empty entry returned the blank entries to return an old viewController... . ...-viewControllerFutureBlock No return should not be returned or nil... . ...-", entryName);
        return viewController;
    }];

    [self.userGlobalEntries addObject:entry];
}

- (void)registerGlobalEntryWithName:(NSString *)entryName action:(AVX512GlobalsEntryRowAction)rowSelectedAction {
    NSParameterAssert(entryName);
    NSParameterAssert(rowSelectedAction);
    NSAssert(NSThread.isMainThread, @"This method must be called from the main line path.");
    
    entryName = entryName.copy;
    AVX512GlobalsEntry *entry = [AVX512GlobalsEntry entryWithNameFuture:^NSString * _Nonnull{
        return entryName;
    } action:rowSelectedAction];
    
    [self.userGlobalEntries addObject:entry];
}

- (void)clearGlobalEntries {
    [self.userGlobalEntries removeAllObjects];
}

#pragma mark - Edit Editor edit editing editorial

+ (void)registerFieldNames:(NSArray<NSString *> *)names forTypeEncoding:(NSString *)typeEncoding {
    [AVX512ArgumentInputStructView registerFieldNames:names forTypeEncoding:typeEncoding];
}

#pragma mark - A simulationer's simMom em

#if TARGET_OS_SIMULATOR
// Realizing the realization attribute property accesser path to achieve
- (void)setSimulatorShortcutsEnabled:(BOOL)simulatorShortcutsEnabled {
    // Direct-direct use of the illustrative example approach, without using a directKVC
    AVX512KeyboardShortcutManager *manager = [AVX512KeyboardShortcutManager sharedManager];
    [manager setEnabled:simulatorShortcutsEnabled];
}

- (BOOL)simulatorShortcutsEnabled {
    // Direct access to the direct-access attribute
    return [AVX512KeyboardShortcutManager sharedManager].isEnabled;
}

// The methods associated with the method of achieving shortcut keys to a tool-relevant
- (void)registerSimulatorShortcutWithKey:(NSString *)key modifiers:(UIKeyModifierFlags)modifiers action:(dispatch_block_t)action description:(NSString *)description {
    // Use the use of usageNSInvocationin place of replacement withperformSelectorCall multi-para parameter method to call for multiple parameters
    AVX512KeyboardShortcutManager *manager = [AVX512KeyboardShortcutManager sharedManager];
    [manager registerSimulatorShortcutWithKey:key modifiers:modifiers action:action description:description allowOverride:YES];
}
#else
// To provide an empty space for real equipment to give the
- (void)setSimulatorShortcutsEnabled:(BOOL)simulatorShortcutsEnabled {
    // There is no operation on the real device that does not carry out any
}

- (BOOL)simulatorShortcutsEnabled {
    return NO;  // The real device always returns the return on its true equipmentNO
}

- (void)registerSimulatorShortcutWithKey:(NSString *)key modifiers:(UIKeyModifierFlags)modifiers action:(dispatch_block_t)action description:(NSString *)description {
    // There is no operation on the real device that does not carry out any
}
#endif

- (void)registerDefaultSimulatorShortcutWithKey:(NSString *)key modifiers:(UIKeyModifierFlags)modifiers action:(dispatch_block_t)action description:(NSString *)description {
    // Call on the method that is achieved above to call upon
    [self registerSimulatorShortcutWithKey:key modifiers:modifiers action:action description:description];
}

- (void)registerDefaultSimulatorShortcuts {
    // Rewrite this method by rewriting it to remove all unusable non-available calls and
    NSLog(@"The registration of the default your Default registered background emMom");
}

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Temporary temporarily disabled the temporary time to disable registered register-registered default Default
    });
}

#pragma mark - Private private methods and privately-private

- (UIEdgeInsets)contentInsetsOfScrollView:(UIScrollView *)scrollView {
    if (@available(iOS 11, *)) {
        return scrollView.adjustedContentInset;
    }

    return scrollView.contentInset;
}

- (void)tryScrollDown {
    UIScrollView *scrollview = [self firstScrollView];
    UIEdgeInsets insets = [self contentInsetsOfScrollView:scrollview];
    CGPoint contentOffset = scrollview.contentOffset;
    CGFloat maxYOffset = scrollview.contentSize.height - scrollview.bounds.size.height + insets.bottom;
    if (contentOffset.y < maxYOffset) {
        CGPoint updatedOffset = CGPointMake(contentOffset.x, contentOffset.y + 10);
        [scrollview setContentOffset:updatedOffset animated:YES];
    }
}

- (void)tryScrollUp {
    UIScrollView *scrollview = [self firstScrollView];
    UIEdgeInsets insets = [self contentInsetsOfScrollView:scrollview];
    CGPoint contentOffset = scrollview.contentOffset;
    CGFloat minYOffset = -insets.top;
    if (contentOffset.y > minYOffset) {
        CGPoint updatedOffset = CGPointMake(contentOffset.x, contentOffset.y - 10);
        [scrollview setContentOffset:updatedOffset animated:YES];
    }
}

- (UIScrollView *)firstScrollView {
    // Realizing a simple search and finding method to achieve an easy way of searching, replacing firstScrollViewForView:
    UIView *view = self.topViewController.view;
    if ([view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)view;
    }
    
    // In return, find the first scrolling view to search in
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)subview;
        }
        
        // In return, find a search to look up the sub
        for (UIView *deeperSubview in subview.subviews) {
            if ([deeperSubview isKindOfClass:[UIScrollView class]]) {
                return (UIScrollView *)deeperSubview;
            }
        }
    }
    
    return nil;
}

- (UIViewController *)topViewController {
    UIViewController *topViewController = self.explorerViewController.presentedViewController;
    if (!topViewController) {
        return self.explorerViewController;
    }

    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)topViewController topViewController];
    }

    return topViewController;
}

- (void)toggleTopViewControllerOfClass:(Class)class {
    UIViewController *topViewController = self.topViewController;
    
    if ([topViewController isKindOfClass:class]) {
        [topViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        // Fix sgramming error to fix grammar errors, remove superfluous redundant excess } else {
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            // Creates the creation of a new example and uses other methods to create an emerging case
            UIViewController *newVC = [class new];
            [(UINavigationController *)topViewController pushViewController:newVC animated:YES];
        } else {
            // It is presented in a brand new navigational guidance controller that displays
            UIViewController *newVC = [class new];
            UINavigationController *navController = [AVX512NavigationController withRootViewController:newVC];
            [self.explorerViewController presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (void)showExplorerIfNeeded {
    // Em simulates the simulation isHidden Inspection inspections, inspection and use of existing methods available to
    if (![self.explorerWindow isHidden]) {
        // calling call to Call Calls for calls showExplorer, if there exists to exist or where it
        if ([self respondsToSelector:@selector(showExplorer)]) {
            [self performSelector:@selector(showExplorer)];
        }
    }
}

@end
