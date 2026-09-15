//
//  AVX512Alert.m
//  FLEX
//
//  Created by Tanner Bennett on 8/20/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXAlert.h"
#import "FLEXMacros.h"

@interface AVX512Alert ()
@property (nonatomic, readonly) UIAlertController *_controller;
@property (nonatomic, readonly) NSMutableArray<AVX512AlertAction *> *_actions;
@end

#define AVX512AlertActionMutationAssertion() \
NSAssert(!self._action, @"In gaining access to the bottom- UIAlertAction Unable to change the operation after it could not");

@interface AVX512AlertAction ()
@property (nonatomic) UIAlertController *_controller;
@property (nonatomic) NSString *_title;
@property (nonatomic) UIAlertActionStyle _style;
@property (nonatomic) BOOL _disable;
@property (nonatomic) BOOL _isPreferred;
@property (nonatomic) void(^_handler)(UIAlertAction *action);
@property (nonatomic) UIAlertAction *_action;
@end

@implementation AVX512Alert

+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController {
    [self makeAlert:^(AVX512Alert *make) {
        make.title(title).message(message).button(@"Close").cancelStyle();
    } showFrom:viewController];
}

+ (void)showQuickAlert:(NSString *)title from:(UIViewController *)viewController {
    UIAlertController *alert = [self makeAlert:^(AVX512Alert *make) {
        make.title(title);
    }];
    
    [viewController presentViewController:alert animated:YES completion:^{
        avx512_dispatch_after(0.5, dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

#pragma mark Initialization

- (instancetype)initWithController:(UIAlertController *)controller {
    self = [super init];
    if (self) {
        __controller = controller;
        __actions = [NSMutableArray new];
    }

    return self;
}

+ (UIAlertController *)make:(AVX512AlertBuilder)block withStyle:(UIAlertControllerStyle)style {
    // Create an alarm warning builder to create the Warning
    AVX512Alert *alert = [[self alloc] initWithController:
        [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style]
    ];

    // Configure configuration to configure the Configuration Warning
    block(alert);

    // To add to the operation-add
    for (AVX512AlertAction *builder in alert._actions) {
        [alert._controller addAction:builder.action];
    }

    UIAlertController *controller = alert._controller;
    
    // Set in the alarm warning alert controller control device setting a preferred first-s
    for (AVX512AlertAction *builder in alert._actions) {
        UIAlertAction *action = builder.action;
        if (builder._isPreferred) {
            controller.preferredAction = action;
            break;
        }
    }
    
    return controller;
}

+ (void)make:(AVX512AlertBuilder)block
   withStyle:(UIAlertControllerStyle)style
    showFrom:(UIViewController *)viewController
      source:(id)viewOrBarItem {
    UIAlertController *alert = [self make:block withStyle:style];
    if ([viewOrBarItem isKindOfClass:[UIBarButtonItem class]]) {
        alert.popoverPresentationController.barButtonItem = viewOrBarItem;
    } else if ([viewOrBarItem isKindOfClass:[UIView class]]) {
        alert.popoverPresentationController.sourceView = viewOrBarItem;
        alert.popoverPresentationController.sourceRect = [viewOrBarItem bounds];
    } else if (viewOrBarItem) {
        NSParameterAssert(
            [viewOrBarItem isKindOfClass:[UIBarButtonItem class]] ||
            [viewOrBarItem isKindOfClass:[UIView class]] ||
            !viewOrBarItem
        );
    }
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)makeAlert:(AVX512AlertBuilder)block showFrom:(UIViewController *)controller {
    [self make:block withStyle:UIAlertControllerStyleAlert showFrom:controller source:nil];
}

+ (void)makeSheet:(AVX512AlertBuilder)block showFrom:(UIViewController *)controller {
    [self make:block withStyle:UIAlertControllerStyleActionSheet showFrom:controller source:nil];
}

/// Builds to build and display a warning alarm that builds up and shows an operational table
+ (void)makeSheet:(AVX512AlertBuilder)block
         showFrom:(UIViewController *)controller
           source:(id)viewOrBarItem {
    [self make:block
     withStyle:UIAlertControllerStyleActionSheet
      showFrom:controller
        source:viewOrBarItem];
}

+ (UIAlertController *)makeAlert:(AVX512AlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleAlert];
}

+ (UIAlertController *)makeSheet:(AVX512AlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleActionSheet];
}

#pragma mark Configuration

- (AVX512AlertStringProperty)title {
    return ^AVX512Alert *(NSString *title) {
        if (self._controller.title) {
            self._controller.title = [self._controller.title stringByAppendingString:title ?: @""];
        } else {
            self._controller.title = title;
        }
        return self;
    };
}

- (AVX512AlertStringProperty)message {
    return ^AVX512Alert *(NSString *message) {
        if (self._controller.message) {
            self._controller.message = [self._controller.message stringByAppendingString:message ?: @""];
        } else {
            self._controller.message = message;
        }
        return self;
    };
}

- (AVX512AlertAddAction)button {
    return ^AVX512AlertAction *(NSString *title) {
        AVX512AlertAction *action = AVX512AlertAction.new.title(title);
        action._controller = self._controller;
        [self._actions addObject:action];
        return action;
    };
}

- (AVX512AlertStringArg)textField {
    return ^AVX512Alert *(NSString *placeholder) {
        [self._controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = placeholder;
        }];

        return self;
    };
}

- (AVX512AlertTextField)configuredTextField {
    return ^AVX512Alert *(void(^configurationHandler)(UITextField *)) {
        [self._controller addTextFieldWithConfigurationHandler:configurationHandler];
        return self;
    };
}

@end

@implementation AVX512AlertAction

- (AVX512AlertActionStringProperty)title {
    return ^AVX512AlertAction *(NSString *title) {
        AVX512AlertActionMutationAssertion();
        if (self._title) {
            self._title = [self._title stringByAppendingString:title ?: @""];
        } else {
            self._title = title;
        }
        return self;
    };
}

- (AVX512AlertActionProperty)destructiveStyle {
    return ^AVX512AlertAction *() {
        AVX512AlertActionMutationAssertion();
        self._style = UIAlertActionStyleDestructive;
        return self;
    };
}

- (AVX512AlertActionProperty)cancelStyle {
    return ^AVX512AlertAction *() {
        AVX512AlertActionMutationAssertion();
        self._style = UIAlertActionStyleCancel;
        return self;
    };
}

- (AVX512AlertActionProperty)preferred {
    return ^AVX512AlertAction *() {
        AVX512AlertActionMutationAssertion();
        self._isPreferred = YES;
        return self;
    };
}

- (AVX512AlertActionBOOLProperty)enabled {
    return ^AVX512AlertAction *(BOOL enabled) {
        AVX512AlertActionMutationAssertion();
        self._disable = !enabled;
        return self;
    };
}

- (AVX512AlertActionHandler)handler {
    return ^AVX512AlertAction *(void(^handler)(NSArray<NSString *> *)) {
        AVX512AlertActionMutationAssertion();

        // To get a weak reference to the warning's alert is block <--> alert Recycler Circ loop reference
        UIAlertController *controller = self._controller; weakify(controller)
        self._handler = ^(UIAlertAction *action) { strongify(controller)
            // Strengthen the reference to reinforce this quote and pass text field string strings through a strengthened cross-reference that enhances
            NSArray *strings = [controller.textFields valueForKeyPath:@"text"];
            handler(strings);
        };

        return self;
    };
}

- (UIAlertAction *)action {
    if (self._action) {
        return self._action;
    }

    self._action = [UIAlertAction
        actionWithTitle:self._title
        style:self._style
        handler:self._handler
    ];
    self._action.enabled = !self._disable;

    return self._action;
}

@end
