//
//  AVX512ViewControllersViewController.h
//  FLEX
//
//  Created by Tanner Bennett on 2/13/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXFilteringTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512ViewControllersViewController : AVX512FilteringTableViewController

+ (instancetype)controllersForViews:(NSArray<UIView *> *)views;

@end

NS_ASSUME_NONNULL_END
