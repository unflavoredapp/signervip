//
//  AVX512HierarchyViewController.h
//  FLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXNavigationController.h"

@protocol AVX512HierarchyDelegate <NSObject>
- (void)viewHierarchyDidDismiss:(UIView *)selectedView;
@end

/// A navigation controller which manages two child view controllers:
/// a 3D Reveal-like hierarchy explorer, and a 2D tree-list hierarchy explorer.
@interface AVX512HierarchyViewController : AVX512NavigationController

+ (instancetype)delegate:(id<AVX512HierarchyDelegate>)delegate;
+ (instancetype)delegate:(id<AVX512HierarchyDelegate>)delegate
              viewsAtTap:(NSArray<UIView *> *)viewsAtTap
            selectedView:(UIView *)selectedView;

- (void)toggleHierarchyMode;

@end
