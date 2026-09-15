//
//  AVX512GlobalsViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXFilteringTableViewController.h"
@protocol AVX512GlobalsTableViewControllerDelegate;

typedef NS_ENUM(NSUInteger, AVX512GlobalsSectionKind) {
    AVX512GlobalsSectionProcessAndEvents = 0,
    AVX512GlobalsSectionAppShortcuts,
    AVX512GlobalsSectionMisc,
    AVX512GlobalsSectionCount
};

@interface AVX512GlobalsViewController : AVX512FilteringTableViewController

@end
