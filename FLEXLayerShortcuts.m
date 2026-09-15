//
//  AVX512LayerShortcuts.m
//  FLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXLayerShortcuts.h"
#import "FLEXShortcut.h"
#import "FLEXImagePreviewViewController.h"

@implementation AVX512LayerShortcuts

+ (instancetype)forObject:(CALayer *)layer {
    return [self forObject:layer additionalRows:@[
        [AVX512ActionShortcut title:@"Preview a preview view of the photo image" subtitle:nil
            viewer:^UIViewController *(CALayer *layer) {
                return [AVX512ImagePreviewViewController previewForLayer:layer];
            }
            accessoryType:^UITableViewCellAccessoryType(CALayer *layer) {
                return CGRectIsEmpty(layer.bounds) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
            }
        ]
    ]];
}

@end
