//
//  AVX512NSStringShortcuts.m
//  FLEX
//
//  Created by Tanner on 3/29/21.
//

#import "FLEXNSStringShortcuts.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXShortcut.h"

@implementation AVX512NSStringShortcuts

+ (instancetype)forObject:(NSString *)string {
    NSUInteger length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytesNoCopy:(void *)string.UTF8String length:length freeWhenDone:NO];
    
    return [self forObject:string additionalRows:@[
        [AVX512ActionShortcut title:@"UTF-8 The data of the Data" subtitle:^NSString *(id _) {
            return data.description;
        } viewer:^UIViewController *(id _) {
            return [AVX512ObjectExplorerFactory explorerViewControllerForObject:data];
        } accessoryType:^UITableViewCellAccessoryType(id _) {
            return UITableViewCellAccessoryDisclosureIndicator;
        }]
    ]];
}

@end
