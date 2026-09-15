//
//  AVX512HierarchyTableViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-01.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableViewController.h"

@interface AVX512HierarchyTableViewController : AVX512TableViewController

+ (instancetype)windows:(NSArray<UIWindow *> *)allWindows
             viewsAtTap:(NSArray<UIView *> *)viewsAtTap
           selectedView:(UIView *)selectedView;

@property (nonatomic) UIView *selectedView;
@property (nonatomic) void(^didSelectRowAction)(UIView *selectedView);

@end
