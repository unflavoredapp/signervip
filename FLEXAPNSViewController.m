//
//  AVX512APNSViewController.m
//  FLEX
//
//  Created by Tanner Bennett on 6/28/22.
//  Copyright © 2022 FLEX Team. All rights reserved.
//

#import "FLEXAPNSViewController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXMutableListSection.h"
#import "FLEXSingleRowSection.h"
#import "NSUserDefaults+FLEX.h"
#import "UIBarButtonItem+FLEX.h"
#import "NSDateFormatter+FLEX.h"
#import "FLEXResources.h"
#import "FLEXUtility.h"
#import "FLEXRuntimeUtility.h"
#import "flex_fishhook.h"
#import <dlfcn.h>
#import <UserNotifications/UserNotifications.h>

#define orig(method, ...) if (orig_##method) { orig_##method(__VA_ARGS__); }
#define method_lookup(__selector, __cls, __return, ...) \
    ([__cls instancesRespondToSelector:__selector] ? \
        (__return(*)(__VA_ARGS__))class_getMethodImplementation(__cls, __selector) : nil)

@interface AVX512APNSViewController ()
@property (nonatomic, readonly, class) Class appDelegateClass;
@property (nonatomic, class) NSData *deviceToken;
@property (nonatomic, class) NSError *registrationError;
@property (nonatomic, readonly, class) NSString *deviceTokenString;
@property (nonatomic, readonly, class) NSMutableArray<NSDictionary *> *remoteNotifications;
@property (nonatomic, readonly, class) NSMutableArray<UNNotification *> *userNotifications API_AVAILABLE(ios(10.0));

@property (nonatomic) AVX512SingleRowSection *deviceToken;
@property (nonatomic) AVX512MutableListSection<NSDictionary *> *remoteNotifications;
@property (nonatomic) AVX512MutableListSection<UNNotification *> *userNotifications API_AVAILABLE(ios(10.0));
@end

@implementation AVX512APNSViewController

#pragma mark Swizzles

/// Hook User Notifications related methods on the app delegate
/// and UNUserNotificationCenter delegate classes
+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    if (!NSUserDefaults.standardUserDefaults.avx512_enableAPNSCapture) {
        return;
    }
    
    //──────────────────────//
    //     App Delegate     //
    //──────────────────────//

    // Hook UIApplication to intercept app delegate
    Class uiapp = UIApplication.self;
    auto orig_uiapp_setDelegate = (void(*)(id, SEL, id))class_getMethodImplementation(
        uiapp, @selector(setDelegate:)
    );
    
    IMP uiapp_setDelegate = imp_implementationWithBlock(^(id _, id delegate) {
        [self hookAppDelegateClass:[delegate class]];
        orig_uiapp_setDelegate(_, @selector(setDelegate:), delegate);
    });
    
    class_replaceMethod(
        uiapp,
        @selector(setDelegate:),
        uiapp_setDelegate,
        "v@:@"
    );
    
    //───────────────────────────────────────────//
    //     UNUserNotificationCenter Delegate     //
    //───────────────────────────────────────────//
    
    if (@available(iOS 10.0, *)) {
        Class unusernc = UNUserNotificationCenter.self;
        auto orig_unusernc_setDelegate = (void(*)(id, SEL, id))class_getMethodImplementation(
            unusernc, @selector(setDelegate:)
        );
        
        IMP unusernc_setDelegate = imp_implementationWithBlock(^(id _, id delegate) {
            [self hookUNUserNotificationCenterDelegateClass:[delegate class]];
            orig_unusernc_setDelegate(_, @selector(setDelegate:), delegate);
        });
        
        class_replaceMethod(
            unusernc,
            @selector(setDelegate:),
            unusernc_setDelegate,
            "v@:@"
        );
    }
}

+ (void)hookAppDelegateClass:(Class)appDelegate {
    // Abort if we already hooked something
    if (_appDelegateClass) {
        return;
    }
    
    _appDelegateClass = appDelegate;
    
    // Better documentation for what's happening is in hookUNUserNotificationCenterDelegateClass: below
    
    auto types_didRegisterForRemoteNotificationsWithDeviceToken = "v@:@@";
    auto types_didFailToRegisterForRemoteNotificationsWithError = "v@:@@";
    auto types_didReceiveRemoteNotification = "v@:@@@?";
    
    auto sel_didRegisterForRemoteNotifications = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    auto sel_didFailToRegisterForRemoteNotifs = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
    auto sel_didReceiveRemoteNotification = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
    
    auto orig_didRegisterForRemoteNotificationsWithDeviceToken = method_lookup(
        sel_didRegisterForRemoteNotifications, appDelegate, void, id, SEL, id, id);
    auto orig_didFailToRegisterForRemoteNotificationsWithError = method_lookup(
        sel_didFailToRegisterForRemoteNotifs, appDelegate, void, id, SEL, id, id);
    auto orig_didReceiveRemoteNotification = method_lookup(
        sel_didReceiveRemoteNotification, appDelegate, void, id, SEL, id, id, id);
    
    IMP didRegisterForRemoteNotificationsWithDeviceToken = imp_implementationWithBlock(^(id _, id app, NSData *token) {
        self.deviceToken = token;
        orig(didRegisterForRemoteNotificationsWithDeviceToken, _, nil, app, token);
    });
    IMP didFailToRegisterForRemoteNotificationsWithError = imp_implementationWithBlock(^(id _, id app, NSError *error) {
        self.registrationError = error;
        orig(didFailToRegisterForRemoteNotificationsWithError, _, nil, app, error);
    });
    IMP didReceiveRemoteNotification = imp_implementationWithBlock(^(id _, id app, NSDictionary *payload, id handler) {
        // TODO: notify when new notifications are added
        @synchronized(_flexAPNSLock) {
            [self.remoteNotifications addObject:payload];
        }
        orig(didReceiveRemoteNotification, _, nil, app, payload, handler);
    });
    
    class_replaceMethod(
        appDelegate,
        sel_didRegisterForRemoteNotifications,
        didRegisterForRemoteNotificationsWithDeviceToken,
        types_didRegisterForRemoteNotificationsWithDeviceToken
    );
    class_replaceMethod(
        appDelegate,
        sel_didFailToRegisterForRemoteNotifs,
        didFailToRegisterForRemoteNotificationsWithError,
        types_didFailToRegisterForRemoteNotificationsWithError
    );
    class_replaceMethod(
        appDelegate,
        sel_didReceiveRemoteNotification,
        didReceiveRemoteNotification,
        types_didReceiveRemoteNotification
    );
}

+ (void)hookUNUserNotificationCenterDelegateClass:(Class)delegate API_AVAILABLE(ios(10.0)) {
    // Selector
    auto sel_didReceiveNotification =
        @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
    // Original implementation (or nil if unimplemented)
    auto orig_didReceiveNotification = method_lookup(
        sel_didReceiveNotification, delegate, void, id, SEL, id, id, id);
    // Our hook (ignores self and other unneeded parameters)
    IMP didReceiveNotification = imp_implementationWithBlock(^(id _, id __, UNNotification *notification, id ___) {
        @synchronized(_flexAPNSLock) {
            [self.userNotifications addObject:notification];
        }
        // This macro is a no-op if there is no original implementation
        orig(didReceiveNotification, _, nil, __, notification, ___);
    });
    
    // Set the hook
    class_replaceMethod(
        delegate,
        sel_didReceiveNotification,
        didReceiveNotification,
        "v@:@@@?"
    );
}

#pragma mark Class Properties

static id _flexAPNSLock = nil;
+ (void)initialize {
    if (self == [AVX512APNSViewController class]) {
        _flexAPNSLock = [NSObject new];
    }
}

static Class _appDelegateClass = nil;
+ (Class)appDelegateClass {
    return _appDelegateClass;
}

static NSData *_apnsDeviceToken = nil;
+ (NSData *)deviceToken {
    return _apnsDeviceToken;
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    _apnsDeviceToken = deviceToken;
}

+ (NSString *)deviceTokenString {
    static NSString *_deviceTokenString = nil;
    
    if (!_deviceTokenString && self.deviceToken) {
        NSData *token = self.deviceToken;
        NSUInteger capacity = token.length * 2;
        NSMutableString *tokenString = [NSMutableString stringWithCapacity:capacity];
        
        const UInt8 *tokenData = token.bytes;
        for (NSUInteger idx = 0; idx < token.length; ++idx) {
            [tokenString appendFormat:@"%02X", (int)tokenData[idx]];
        }
        
        _deviceTokenString = tokenString;
    }
    
    return _deviceTokenString;
}

static NSError *_apnsRegistrationError = nil;
+ (NSError *)registrationError {
    return _apnsRegistrationError;
}

+ (void)setRegistrationError:(NSError *)error {
    _apnsRegistrationError = error;
}

+ (NSMutableArray<UNNotification *> *)userNotifications API_AVAILABLE(ios(10.0)) {
    static NSMutableArray *_userNotifications = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userNotifications = [NSMutableArray new];
    });
    
    return _userNotifications;
}

+ (NSMutableArray<NSDictionary *> *)remoteNotifications {
    static NSMutableArray *_remoteNotifications = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _remoteNotifications = [NSMutableArray new];
    });
    
    return _remoteNotifications;
}

#pragma mark Instance stuff

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"push sent notification notice to send notifications not";
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    [self addToolbarItems:@[
        [UIBarButtonItem
            avx512_itemWithImage:AVX512Resources.gearIcon
            target:self
            action:@selector(settingsButtonTapped)
        ],
    ]];
}

- (NSArray<AVX512TableViewSection *> *)makeSections {
    self.deviceToken = [AVX512SingleRowSection title:@"APNS Device device (equi devices/ gears" reuse:nil cell:^(UITableViewCell *cell) {
        NSString *tokenString = AVX512APNSViewController.deviceTokenString;
        if (tokenString) {
            cell.textLabel.text = tokenString;
            cell.textLabel.numberOfLines = 0;
        }
        else if (!NSUserDefaults.standardUserDefaults.avx512_enableAPNSCapture) {
            cell.textLabel.text = @"APNS Capture is no longer used to capture.";
        }
        else {
            cell.textLabel.text = @"Not yet registered and not Registered";
        }
    }];
    self.deviceToken.selectionAction = ^(UIViewController *host) {
        UIPasteboard.generalPasteboard.string = AVX512APNSViewController.deviceTokenString;
        [AVX512Alert showQuickAlert:@"Copyed to the clipboard board has been copied and reproduced" from:host];
    };
    
    // Remote remote notification notice remotely-t //
    
    self.remoteNotifications = [AVX512MutableListSection list:AVX512APNSViewController.remoteNotifications
        cellConfiguration:^(UITableViewCell *cell, NSDictionary *notif, NSInteger row) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // TODO: Date reception date receiving receipt of acceptance
            cell.detailTextLabel.text = [AVX512RuntimeUtility summaryForObject:notif];
        }
        filterMatcher:^BOOL(NSString *filterText, NSDictionary *notif) {
            return [notif.description localizedCaseInsensitiveContainsString:filterText];
        }
    ];
    
    self.remoteNotifications.customTitle = @"Remote remote notification notice remotely-t";
    self.remoteNotifications.selectionHandler = ^(UIViewController *host, NSDictionary *notif) {
        [host.navigationController pushViewController:[
            AVX512ObjectExplorerFactory explorerViewControllerForObject:notif
        ] animated:YES];
    };
    
    // User call notification of user-user //
    
    if (@available(iOS 10.0, *)) {
        self.userNotifications = [AVX512MutableListSection list:AVX512APNSViewController.userNotifications
            cellConfiguration:^(UITableViewCell *cell, UNNotification *notif, NSInteger row) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                // subtitle title by the subhead phy 'subtitle \n date'
                NSString *dateString = [NSDateFormatter avx512_stringFrom:notif.date format:AVX512DateFormatPreciseClock];
                NSString *subtitle = notif.request.content.subtitle;
                subtitle = subtitle ? [NSString stringWithFormat:@"%@\n%@", subtitle, dateString] : dateString;
            
                cell.textLabel.text = notif.request.content.title;
                cell.detailTextLabel.text = subtitle;
            }
            filterMatcher:^BOOL(NSString *filterText, NSDictionary *notif) {
                return [notif.description localizedCaseInsensitiveContainsString:filterText];
            }
        ];
        
        self.userNotifications.customTitle = @"push sent notification notice to send notifications not";
        self.userNotifications.selectionHandler = ^(UIViewController *host, UNNotification *notif) {
            [host.navigationController pushViewController:[
                AVX512ObjectExplorerFactory explorerViewControllerForObject:notif.request
            ] animated:YES];
        };
        
        return @[self.deviceToken, self.remoteNotifications, self.userNotifications];
    }
    else {
        return @[self.deviceToken, self.remoteNotifications];
    }
}

- (void)reloadData {
    [self.refreshControl endRefreshing];
    
    self.remoteNotifications.customTitle = [NSString stringWithFormat:
        @"%@ Article notification of notice notified by the", @(self.remoteNotifications.filteredList.count)
    ];
    [super reloadData];
}

- (void)settingsButtonTapped {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    BOOL enabled = defaults.avx512_enableAPNSCapture;

    NSString *apnsToggle = enabled ? @"Prohibits the use of banned catch capture" : @"Enables the capture catch to enable";
    
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(@"Set the setting of a")
            .message(@"Enable or disable captures that you want to send notice of notification notifications.\n\n")
            .message(@"This this will enable on start-up, theUIApplicationMainUntil it is disabled, until its disableed.")
            .message(@", and brushes some application commissioning methods. Re restarts the applications to make changes effective by re-re");
        
        make.button(apnsToggle).destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            [defaults avx512_toggleBoolForKey:kAVX512DefaultsAPNSCaptureEnabledKey];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

#pragma mark - AVX512GlobalsEntry

+ (NSString *)globalsEntryTitle:(AVX512GlobalsRow)row {
    return @"Push Notifications";
}

+ (UIViewController *)globalsEntryViewController:(AVX512GlobalsRow)row {
    return [self new];
}

@end
