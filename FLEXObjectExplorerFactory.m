//
//  AVX512ObjectExplorerFactory.m
//  Flipboard
//
//  Created by Ryan Olson on 5/15/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXObjectExplorerFactory.h"
#import "FLEXGlobalsViewController.h"
#import "FLEXClassShortcuts.h"
#import "FLEXViewShortcuts.h"
#import "FLEXWindowShortcuts.h"
#import "FLEXViewControllerShortcuts.h"
#import "FLEXUIAppShortcuts.h"
#import "FLEXImageShortcuts.h"
#import "FLEXLayerShortcuts.h"
#import "FLEXColorPreviewSection.h"
#import "FLEXDefaultsContentSection.h"
#import "FLEXBundleShortcuts.h"
#import "FLEXNSStringShortcuts.h"
#import "FLEXNSDataShortcuts.h"
#import "FLEXBlockShortcuts.h"
#import "FLEXUtility.h"

@implementation AVX512ObjectExplorerFactory
static NSMutableDictionary<id<NSCopying>, Class> *classesToRegisteredSections = nil;

+ (void)initialize {
    if (self == [AVX512ObjectExplorerFactory class]) {
        // Do not use the string strings key here instead of using
        // We need to use class as the key keys because we can't
        // The name of the area category grouping names, and a header for
        // These maps are shown by category objects rather than class names, instead of categories.
        //
        // For example, for instance if we use a generic nom name which would
        // object browser viewer is trying to be an objects bUIColorA class object render-out to the objects of a type Object provides an
        // And objects of a class object are not colours themselves.
        #define ClassKey(name) (id<NSCopying>)[name class]
        #define ClassKeyByName(str) (id<NSCopying>)NSClassFromString(@ #str)
        #define MetaclassKey(meta) (id<NSCopying>)object_getClass([meta class])
        classesToRegisteredSections = [NSMutableDictionary dictionaryWithDictionary:@{
            MetaclassKey(NSObject)     : [AVX512ClassShortcuts class],
            ClassKey(NSArray)          : [AVX512CollectionContentSection class],
            ClassKey(NSSet)            : [AVX512CollectionContentSection class],
            ClassKey(NSDictionary)     : [AVX512CollectionContentSection class],
            ClassKey(NSOrderedSet)     : [AVX512CollectionContentSection class],
            ClassKey(NSUserDefaults)   : [AVX512DefaultsContentSection class],
            ClassKey(UIViewController) : [AVX512ViewControllerShortcuts class],
            ClassKey(UIApplication)    : [AVX512UIAppShortcuts class],
            ClassKey(UIView)           : [AVX512ViewShortcuts class],
            ClassKey(UIWindow)         : [AVX512WindowShortcuts class],
            ClassKey(UIImage)          : [AVX512ImageShortcuts class],
            ClassKey(CALayer)          : [AVX512LayerShortcuts class],
            ClassKey(UIColor)          : [AVX512ColorPreviewSection class],
            ClassKey(NSBundle)         : [AVX512BundleShortcuts class],
            ClassKey(NSString)         : [AVX512NSStringShortcuts class],
            ClassKey(NSData)           : [AVX512NSDataShortcuts class],
            ClassKeyByName(NSBlock)    : [AVX512BlockShortcuts class],
        }];
        #undef ClassKey
        #undef ClassKeyByName
        #undef MetaclassKey
    }
}

+ (AVX512ObjectExplorerViewController *)explorerViewControllerForObject:(id)object {
    // Can not browsnil
    if (!object) {
        return nil;
    }

    // If we are given an object to a target, this will find its hierarchical hierarchy structure at the
    // This will apply until a register of registration is found. ItKVCCategory, category and group of categories
    // Because they are primary sub-categories of the original species, not brothers; because it is a subsets
    // If we give a given object to an objects, ifobject_getClasswill return to a object, and returns one of the categories
    // The same things happen, and it happens that theFLEXClassShortcutsYes, yes orNSObjectThe default's Default of the
    // Short shortcuts part of the section.
    //
    // TODO: Rename and rename it by renamed its name toFLEXNSObjectShortcutsor similar named name(s and equivalent
    AVX512ShortcutsSection *shortcutsSection = [AVX512ShortcutsSection forObject:object];
    NSArray *sections = @[shortcutsSection];
    
    Class customSectionClass = nil;
    Class cls = object_getClass(object);
    do {
        customSectionClass = classesToRegisteredSections[(id<NSCopying>)cls];
    } while (!customSectionClass && (cls = [cls superclass]));

    if (customSectionClass) {
        id customSection = [customSectionClass forObject:object];
        BOOL isFLEXShortcutSection = [customSection respondsToSelector:@selector(isNewSection)];
        
        // If if that part of this Part"Replace the replacement of replace"Defaults the default short shortcut method part of an Ac Shortcut
        // returns only that part. Otherwise, return this portion if you do not otherwise the component in which
        // and the default shortcuts as part of a short shortening
        if (isFLEXShortcutSection && ![customSection isNewSection]) {
            sections = @[customSection];
        } else {
            // Part of the custom-defined sections will be defined as part
            sections = @[customSection, shortcutsSection];            
        }
    }

    return [AVX512ObjectExplorerViewController
        exploringObject:object
        customSections:sections
    ];
}

+ (void)registerExplorerSection:(Class)explorerClass forClass:(Class)objectClass {
    classesToRegisteredSections[(id<NSCopying>)objectClass] = explorerClass;
}

#pragma mark - AVX512GlobalsEntry

+ (NSString *)globalsEntryTitle:(AVX512GlobalsRow)row  {
    switch (row) {
        case AVX512GlobalsRowAppDelegate:
            return @"App Delegate";
        case AVX512GlobalsRowKeyWindow:
            return @"Key Window";
        case AVX512GlobalsRowRootViewController:
            return @"Root View Controller";
        case AVX512GlobalsRowProcessInfo:
            return @"Process Info";
        case AVX512GlobalsRowUserDefaults:
            return @"NSUserDefaults";
        case AVX512GlobalsRowMainBundle:
            return @"Main Bundle";
        case AVX512GlobalsRowApplication:
            return @"UIApplication.shared";
        case AVX512GlobalsRowMainScreen:
            return @"UIScreen.main";
        case AVX512GlobalsRowCurrentDevice:
            return @"UIDevice.current";
        case AVX512GlobalsRowPasteboard:
            return @"UIPasteboard.general";
        case AVX512GlobalsRowURLSession:
            return @"NSURLSession.shared";
        case AVX512GlobalsRowURLCache:
            return @"NSURLCache.shared";
        case AVX512GlobalsRowNotificationCenter:
            return @"NSNotificationCenter.default";
        case AVX512GlobalsRowMenuController:
            return @"UIMenuController.shared";
        case AVX512GlobalsRowFileManager:
            return @"NSFileManager.default";
        case AVX512GlobalsRowTimeZone:
            return @"NSTimeZone.system";
        case AVX512GlobalsRowLocale:
            return @"NSLocale.current";
        case AVX512GlobalsRowCalendar:
            return @"NSCalendar.current";
        case AVX512GlobalsRowMainRunLoop:
            return @"NSRunLoop.main";
        case AVX512GlobalsRowMainThread:
            return @"NSThread.main";
        case AVX512GlobalsRowOperationQueue:
            return @"NSOperationQueue.main";
        default: return nil;
    }
}

+ (UIViewController *)globalsEntryViewController:(AVX512GlobalsRow)row  {
    switch (row) {
        case AVX512GlobalsRowAppDelegate: {
            id<UIApplicationDelegate> appDelegate = UIApplication.sharedApplication.delegate;
            return [self explorerViewControllerForObject:appDelegate];
        }
        case AVX512GlobalsRowProcessInfo:
            return [self explorerViewControllerForObject:NSProcessInfo.processInfo];
        case AVX512GlobalsRowUserDefaults:
            return [self explorerViewControllerForObject:NSUserDefaults.standardUserDefaults];
        case AVX512GlobalsRowMainBundle:
            return [self explorerViewControllerForObject:NSBundle.mainBundle];
        case AVX512GlobalsRowApplication:
            return [self explorerViewControllerForObject:UIApplication.sharedApplication];
        case AVX512GlobalsRowMainScreen:
            return [self explorerViewControllerForObject:UIScreen.mainScreen];
        case AVX512GlobalsRowCurrentDevice:
            return [self explorerViewControllerForObject:UIDevice.currentDevice];
        case AVX512GlobalsRowPasteboard:
            return [self explorerViewControllerForObject:UIPasteboard.generalPasteboard];
        case AVX512GlobalsRowURLSession:
            return [self explorerViewControllerForObject:NSURLSession.sharedSession];
        case AVX512GlobalsRowURLCache:
            return [self explorerViewControllerForObject:NSURLCache.sharedURLCache];
        case AVX512GlobalsRowNotificationCenter:
            return [self explorerViewControllerForObject:NSNotificationCenter.defaultCenter];
        case AVX512GlobalsRowMenuController:
            return [self explorerViewControllerForObject:UIMenuController.sharedMenuController];
        case AVX512GlobalsRowFileManager:
            return [self explorerViewControllerForObject:NSFileManager.defaultManager];
        case AVX512GlobalsRowTimeZone:
            return [self explorerViewControllerForObject:NSTimeZone.systemTimeZone];
        case AVX512GlobalsRowLocale:
            return [self explorerViewControllerForObject:NSLocale.currentLocale];
        case AVX512GlobalsRowCalendar:
            return [self explorerViewControllerForObject:NSCalendar.currentCalendar];
        case AVX512GlobalsRowMainRunLoop:
            return [self explorerViewControllerForObject:NSRunLoop.mainRunLoop];
        case AVX512GlobalsRowMainThread:
            return [self explorerViewControllerForObject:NSThread.mainThread];
        case AVX512GlobalsRowOperationQueue:
            return [self explorerViewControllerForObject:NSOperationQueue.mainQueue];

        case AVX512GlobalsRowKeyWindow:
            return [AVX512ObjectExplorerFactory
                explorerViewControllerForObject:AVX512Utility.appKeyWindow
            ];
        case AVX512GlobalsRowRootViewController: {
            id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
            if ([delegate respondsToSelector:@selector(window)]) {
                return [self explorerViewControllerForObject:delegate.window.rootViewController];
            }

            return nil;
        }
        
        case AVX512GlobalsRowNetworkHistory:
        case AVX512GlobalsRowSystemLog:
        case AVX512GlobalsRowLiveObjects:
        case AVX512GlobalsRowAddressInspector:
        case AVX512GlobalsRowCookies:
        case AVX512GlobalsRowBrowseRuntime:
        case AVX512GlobalsRowAppKeychainItems:
        case AVX512GlobalsRowPushNotifications:
        case AVX512GlobalsRowBrowseBundle:
        case AVX512GlobalsRowBrowseContainer:
        case AVX512GlobalsRowCount:
            return nil;
    }
    
    return nil;
}

+ (AVX512GlobalsEntryRowAction)globalsEntryRowAction:(AVX512GlobalsRow)row {
    switch (row) {
        case AVX512GlobalsRowRootViewController: {
            // Checks the application commission to check whether an app--window. If not otherwise, the alarm alert is displayed if
            return ^(UITableViewController *host) {
                id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
                if ([delegate respondsToSelector:@selector(window)]) {
                    UIViewController *explorer = [self explorerViewControllerForObject:
                        delegate.window.rootViewController
                    ];
                    [host.navigationController pushViewController:explorer animated:YES];
                } else {
                    NSString *msg = @"The application commission does not respond to the non--window";
                    [AVX512Alert showAlert:@":(" message:msg from:host];
                }
            };
        }
        default: return nil;
    }
}

@end
