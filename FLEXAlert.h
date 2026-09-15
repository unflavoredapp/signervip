//
//  AVX512Alert.h
//  FLEX
//
//  Created by Tanner Bennett on 8/20/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AVX512Alert, AVX512AlertAction;

typedef void (^AVX512AlertReveal)(void);
typedef void (^AVX512AlertBuilder)(AVX512Alert *make);
typedef AVX512Alert * _Nonnull (^AVX512AlertStringProperty)(NSString * _Nullable);
typedef AVX512Alert * _Nonnull (^AVX512AlertStringArg)(NSString * _Nullable);
typedef AVX512Alert * _Nonnull (^AVX512AlertTextField)(void(^configurationHandler)(UITextField *textField));
typedef AVX512AlertAction * _Nonnull (^AVX512AlertAddAction)(NSString *title);
typedef AVX512AlertAction * _Nonnull (^AVX512AlertActionStringProperty)(NSString * _Nullable);
typedef AVX512AlertAction * _Nonnull (^AVX512AlertActionProperty)(void);
typedef AVX512AlertAction * _Nonnull (^AVX512AlertActionBOOLProperty)(BOOL);
typedef AVX512AlertAction * _Nonnull (^AVX512AlertActionHandler)(void(^handler)(NSArray<NSString *> *strings));

@interface AVX512Alert : NSObject

/// Shows a simple alert with one button which says "Dismiss"
+ (void)showAlert:(NSString * _Nullable)title message:(NSString * _Nullable)message from:(UIViewController *)viewController;

/// Shows a simple alert with no buttons and only a title, for half a second
+ (void)showQuickAlert:(NSString *)title from:(UIViewController *)viewController;

/// Construct and display an alert
+ (void)makeAlert:(AVX512AlertBuilder)block showFrom:(UIViewController *)viewController;
/// Construct and display an action sheet-style alert
+ (void)makeSheet:(AVX512AlertBuilder)block
         showFrom:(UIViewController *)viewController
           source:(id)viewOrBarItem;

/// Construct an alert
+ (UIAlertController *)makeAlert:(AVX512AlertBuilder)block;
/// Construct an action sheet-style alert
+ (UIAlertController *)makeSheet:(AVX512AlertBuilder)block;

/// Set the alert's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) AVX512AlertStringProperty title;
/// Set the alert's message.
///
/// Call in succession to append strings to the message.
@property (nonatomic, readonly) AVX512AlertStringProperty message;
/// Add a button with a given title with the default style and no action.
@property (nonatomic, readonly) AVX512AlertAddAction button;
/// Add a text field with the given (optional) placeholder text.
@property (nonatomic, readonly) AVX512AlertStringArg textField;
/// Add and configure the given text field.
///
/// Use this if you need to more than set the placeholder, such as
/// supply a delegate, make it secure entry, or change other attributes.
@property (nonatomic, readonly) AVX512AlertTextField configuredTextField;

@end

@interface AVX512AlertAction : NSObject

/// Set the action's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) AVX512AlertActionStringProperty title;
/// Make the action destructive. It appears with red text.
@property (nonatomic, readonly) AVX512AlertActionProperty destructiveStyle;
/// Make the action cancel-style. It sometimes appears with a bolder font.
@property (nonatomic, readonly) AVX512AlertActionProperty cancelStyle;
/// Make the action the preferred action. It appears with a bolder font.
/// The first action that is set as preferred will be used as the preferred action.
@property (nonatomic, readonly) AVX512AlertActionProperty preferred;
/// Enable or disable the action. Enabled by default.
@property (nonatomic, readonly) AVX512AlertActionBOOLProperty enabled;
/// Give the button an action. The action takes an array of text field strings.
@property (nonatomic, readonly) AVX512AlertActionHandler handler;
/// Access the underlying UIAlertAction, should you need to change it while
/// the encompassing alert is being displayed. For example, you may want to
/// enable or disable a button based on the input of some text fields in the alert.
/// Do not call this more than once per instance.
@property (nonatomic, readonly) UIAlertAction *action;

@end

NS_ASSUME_NONNULL_END
