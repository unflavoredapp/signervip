//
//  AVX512GlobalsEntry.h
//  FLEX
//
//  Created by Javier Soto on 7/26/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVX512GlobalsRow) {
    AVX512GlobalsRowProcessInfo,
    AVX512GlobalsRowNetworkHistory,
    AVX512GlobalsRowSystemLog,
    AVX512GlobalsRowLiveObjects,
    AVX512GlobalsRowAddressInspector,
    AVX512GlobalsRowCookies,
    AVX512GlobalsRowBrowseRuntime,
    AVX512GlobalsRowAppKeychainItems,
    AVX512GlobalsRowPushNotifications,
    AVX512GlobalsRowAppDelegate,
    AVX512GlobalsRowRootViewController,
    AVX512GlobalsRowUserDefaults,
    AVX512GlobalsRowMainBundle,
    AVX512GlobalsRowBrowseBundle,
    AVX512GlobalsRowBrowseContainer,
    AVX512GlobalsRowApplication,
    AVX512GlobalsRowKeyWindow,
    AVX512GlobalsRowMainScreen,
    AVX512GlobalsRowCurrentDevice,
    AVX512GlobalsRowPasteboard,
    AVX512GlobalsRowURLSession,
    AVX512GlobalsRowURLCache,
    AVX512GlobalsRowNotificationCenter,
    AVX512GlobalsRowMenuController,
    AVX512GlobalsRowFileManager,
    AVX512GlobalsRowTimeZone,
    AVX512GlobalsRowLocale,
    AVX512GlobalsRowCalendar,
    AVX512GlobalsRowMainRunLoop,
    AVX512GlobalsRowMainThread,
    AVX512GlobalsRowOperationQueue,
    AVX512GlobalsRowCount
};

typedef NSString * _Nonnull (^AVX512GlobalsEntryNameFuture)(void);
/// Simply return a view controller to be pushed on the navigation stack
typedef UIViewController * _Nullable (^AVX512GlobalsEntryViewControllerFuture)(void);
/// Do something like present an alert, then use the host
/// view controller to present or push another view controller.
typedef void (^AVX512GlobalsEntryRowAction)(__kindof UITableViewController * _Nonnull host);

/// For view controllers to conform to to indicate they support being used
/// in the globals table view controller. These methods help create concrete entries.
///
/// Previously, the concrete entries relied on "futures" for the view controller and title.
/// With this protocol, the conforming class itself can act as a future, since the methods
/// will not be invoked until the title and view controller / row action are needed.
///
/// Entries can implement \c globalsEntryViewController: to unconditionally provide a
/// view controller, or \c globalsEntryRowAction: to conditionally provide one and
/// perform some action (such as present an alert) if no view controller is available,
/// or both if there is a mix of rows where some are guaranteed to work and some are not.
/// Where both are implemented, \c globalsEntryRowAction: takes precedence; if it returns
/// an action for the requested row, that will be used instead of \c globalsEntryViewController:
@protocol AVX512GlobalsEntry <NSObject>

+ (NSString *)globalsEntryTitle:(AVX512GlobalsRow)row;

// Must respond to at least one of the below.
// globalsEntryRowAction: takes precedence if both are implemented.
@optional

+ (nullable UIViewController *)globalsEntryViewController:(AVX512GlobalsRow)row;
+ (nullable AVX512GlobalsEntryRowAction)globalsEntryRowAction:(AVX512GlobalsRow)row;

@end

@interface AVX512GlobalsEntry : NSObject

@property (nonatomic, readonly, nonnull)  AVX512GlobalsEntryNameFuture entryNameFuture;
@property (nonatomic, readonly, nullable) AVX512GlobalsEntryViewControllerFuture viewControllerFuture;
@property (nonatomic, readonly, nullable) AVX512GlobalsEntryRowAction rowAction;

+ (instancetype)entryWithEntry:(Class<AVX512GlobalsEntry>)entry row:(AVX512GlobalsRow)row;

+ (instancetype)entryWithNameFuture:(AVX512GlobalsEntryNameFuture)nameFuture
               viewControllerFuture:(AVX512GlobalsEntryViewControllerFuture)viewControllerFuture;

+ (instancetype)entryWithNameFuture:(AVX512GlobalsEntryNameFuture)nameFuture
                             action:(AVX512GlobalsEntryRowAction)rowSelectedAction;

@end


@interface NSObject (AVX512GlobalsEntry)

/// @return The result of passing self to +[AVX512GlobalsEntry entryWithEntry:]
/// if the class conforms to AVX512GlobalsEntry, else, nil.
+ (nullable AVX512GlobalsEntry *)avx512_concreteGlobalsEntry:(AVX512GlobalsRow)row;

@end

NS_ASSUME_NONNULL_END
