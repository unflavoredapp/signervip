//
//  AVX512ClassShortcuts.m
//  FLEX
//
//  Created by Tanner Bennett on 11/22/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXClassShortcuts.h"
#import "FLEXShortcut.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXObjectListViewController.h"
#import "NSObject+FLEX_Reflection.h"

@interface AVX512ClassShortcuts ()
@property (nonatomic, readonly) Class cls;
@end

@implementation AVX512ClassShortcuts

+ (instancetype)forObject:(Class)cls {
    // These additional rows will appear at the beginning of a shortcut section.
    // The method of methodological preparation below is prepared in a way that
    // Properties with which these properties that register the attributes registered together are/Waiting waiting, etc
    return [self forObject:cls additionalRows:@[
        [AVX512ActionShortcut title:@"Finds active and dynamic instance for finding" subtitle:nil
            viewer:^UIViewController *(id obj) {
                return [AVX512ObjectListViewController
                    instancesOfClassWithName:NSStringFromClass(obj)
                    retained:NO
                ];
            }
            accessoryType:^UITableViewCellAccessoryType(id obj) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
        [AVX512ActionShortcut title:@"Lists a list of sub-sub" subtitle:nil
            viewer:^UIViewController *(id obj) {
                NSString *name = NSStringFromClass(obj);
                return [AVX512ObjectListViewController subclassesOfClassWithName:name];
            }
            accessoryType:^UITableViewCellAccessoryType(id view) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
        [AVX512ActionShortcut title:@"Browse a browsing class ofBundle"
            subtitle:^NSString *(id obj) {
                return [self shortNameForBundlePath:[NSBundle bundleForClass:obj].executablePath];
            }
            viewer:^UIViewController *(id obj) {
                NSBundle *bundle = [NSBundle bundleForClass:obj];
                return [AVX512ObjectExplorerFactory explorerViewControllerForObject:bundle];
            }
            accessoryType:^UITableViewCellAccessoryType(id view) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
    ]];
}

+ (NSString *)shortNameForBundlePath:(NSString *)imageName {
    NSArray<NSString *> *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        return [NSString stringWithFormat:@"%@/%@",
            components[components.count - 2],
            components[components.count - 1]
        ];
    }

    return imageName.lastPathComponent;
}

@end
