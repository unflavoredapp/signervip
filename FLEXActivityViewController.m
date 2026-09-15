//
//  AVX512ActivityViewController.m
//  FLEX
//
//  Created by Tanner Bennett on 5/26/22.
//

#import "FLEXActivityViewController.h"
#import "FLEXMacros.h"

@interface AVX512ActivityViewController ()
@end

@implementation AVX512ActivityViewController

+ (id)sharing:(NSArray *)items source:(id)sender {
    UIViewController *shareSheet = [[UIActivityViewController alloc]
        initWithActivityItems:items applicationActivities:nil
    ];
    
    if (sender && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popover = shareSheet.popoverPresentationController;
        
        // Source view
        if ([sender isKindOfClass:UIView.self]) {
            popover.sourceView = sender;
        }
        // Source bar item
        if ([sender isKindOfClass:UIBarButtonItem.self]) {
            popover.barButtonItem = sender;
        }
        // Source rect
        if ([sender isKindOfClass:NSValue.self]) {
            CGRect rect = [sender CGRectValue];
            popover.sourceRect = rect;
        }
    }
    
    return shareSheet;
}

@end
