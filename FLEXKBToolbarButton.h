//
//  AVX512KBToolbarButton.h
//  FLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AVX512KBToolbarAction)(NSString *buttonTitle, BOOL isSuggestion);


@interface AVX512KBToolbarButton : UIButton

/// Set to `default` to use the system appearance on iOS 13+
@property (nonatomic) UIKeyboardAppearance appearance;

+ (instancetype)buttonWithTitle:(NSString *)title;
+ (instancetype)buttonWithTitle:(NSString *)title action:(AVX512KBToolbarAction)eventHandler;
+ (instancetype)buttonWithTitle:(NSString *)title action:(AVX512KBToolbarAction)action forControlEvents:(UIControlEvents)controlEvents;

/// Adds the event handler for the button.
///
/// @param eventHandler The event handler block.
/// @param controlEvents The type of event.
- (void)addEventHandler:(AVX512KBToolbarAction)eventHandler forControlEvents:(UIControlEvents)controlEvents;

@end

@interface AVX512KBToolbarSuggestedButton : AVX512KBToolbarButton @end
