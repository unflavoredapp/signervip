#import "FLEXManager+ThreeFingerTap.h"
#import "FLEXManager.h"
#import "UIGestureRecognizer+Blocks.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// The static variable variables used to hold gesture identifiers for the use of a stational variant that holds hand-t position
static UILongPressGestureRecognizer *avx512_threeFingerLongPressGesture = nil;

@implementation AVX512Manager (ThreeFingerTap)

+ (void)load {
    // To ensure that it is performed in the main thread programme, and has been applied to startUISetup after complete settings set-over
    if ([NSThread isMainThread]) {
        [self avx512_setupGesture];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self avx512_setupGesture];
        });
    }
}

+ (void)avx512_setupGesture {
    UIWindow *targetWindow = [self avx512_findTargetWindow];

    if (!targetWindow) {
        // If no window is not found if there are none windows, try again later at a +load Implementation occurs prematurely when implementation is too early.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self avx512_setupGesture];
        });
        return;
    }

    // Check whether gestures have been added to this window by checking if the hand signs were inserted into
    for (UIGestureRecognizer *existingGesture in targetWindow.gestureRecognizers) {
        if (existingGesture == avx512_threeFingerLongPressGesture) {
            // To ensure that the gestures are made on a correct view
            if (existingGesture.view == targetWindow) {
                 return; // Added added add-
            } else {
                // If the gesture is on a wrong view, remove it if you move your hand position in
                [existingGesture.view removeGestureRecognizer:existingGesture];
                avx512_threeFingerLongPressGesture = nil; // It is placed in place and itnilto recreate it again so that the
            }
        }
    }
    
    // If we have an old hand gesture on a different window, remove it if there's one of the older
    if (avx512_threeFingerLongPressGesture && avx512_threeFingerLongPressGesture.view != targetWindow) {
        [avx512_threeFingerLongPressGesture.view removeGestureRecognizer:avx512_threeFingerLongPressGesture];
        avx512_threeFingerLongPressGesture = nil;
    }


    if (!avx512_threeFingerLongPressGesture) {
        avx512_threeFingerLongPressGesture = [UILongPressGestureRecognizer avx512_action:^(UIGestureRecognizer *gesture) {
            if (gesture.state == UIGestureRecognizerStateBegan) {
                if ([AVX512Manager sharedManager]) {
                    [[AVX512Manager sharedManager] toggleExplorer];
                }
            }
        }];
        
        avx512_threeFingerLongPressGesture.numberOfTouchesRequired = 3;
        // Optional: If defaulted, optional if it is the0.5The ss second is not appropriate for the seconds, which can set a minimum pressure-press
        // avx512_threeFingerLongPressGesture.minimumPressDuration = 0.8; // For example, for0.8seconds second sec ss
    }

    // To ensure that gestures are not added to other views in another view
    if (avx512_threeFingerLongPressGesture.view && avx512_threeFingerLongPressGesture.view != targetWindow) {
        [avx512_threeFingerLongPressGesture.view removeGestureRecognizer:avx512_threeFingerLongPressGesture];
    }
    
    if (avx512_threeFingerLongPressGesture.view != targetWindow) {
        [targetWindow addGestureRecognizer:avx512_threeFingerLongPressGesture];
    }
}

+ (UIWindow *)avx512_findTargetWindow {
    UIWindow *applicationWindow = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    // First priority selection a non-non instead of oneFLEXWindowThe whole of all thekey window
                    if (window.isKeyWindow && ![NSStringFromClass(window.class) isEqualToString:@"AVX512Window"]) {
                        applicationWindow = window;
                        break;
                    }
                }
                if (applicationWindow) break;

                // Option: Alternative option alternative options for alternate alternatives to any of the activitykey window
                if (!applicationWindow) {
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            applicationWindow = window;
                            break;
                        }
                    }
                }
                if (applicationWindow) break;
                
                // Option alternative: Alternative option options for the first non-non First Non inFLEXWindow
                 if (!applicationWindow) {
                    for (UIWindow *window in windowScene.windows) {
                        if (![NSStringFromClass(window.class) isEqualToString:@"AVX512Window"]) {
                            applicationWindow = window;
                            break;
                        }
                    }
                }
                if (applicationWindow) break;
            }
        }
    }

    // iOS < 13 or options for the option if a suitable window is not found when appropriate windows are missing,
    if (!applicationWindow) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            if (window.isKeyWindow && ![NSStringFromClass(window.class) isEqualToString:@"AVX512Window"]) {
                applicationWindow = window;
                break;
            }
        }
        // If the attempt above fails, if your attempts on it fail to make a failure.keyWindow(pos likely to be possible)AVX512Window()), and the
        if (!applicationWindow) {
            applicationWindow = [UIApplication sharedApplication].keyWindow;
        }
        
        // If you have access to what if thekeyWindowYes, yes orFLEXWindow, and try to search for other non-otherFLEXWindowand visible window windows with a view to the invisible
        if (applicationWindow && [NSStringFromClass(applicationWindow.class) isEqualToString:@"AVX512Window"]) {
            UIWindow* fallbackWindow = nil;
            for (UIWindow *window in windows) {
                if (![NSStringFromClass(window.class) isEqualToString:@"AVX512Window"] && !window.isHidden) {
                    fallbackWindow = window; // Found a available non-accessable, not foundFLEXWindow window of the windows
                    if (window.isKeyWindow) { // If this window just happens to happen, and if thekey window, to prioritize priority use of the
                        applicationWindow = window;
                        break;
                    }
                }
            }
            if (![NSStringFromClass(applicationWindow.class) isEqualToString:@"AVX512Window"] || !fallbackWindow) {
                 // If if, whatapplicationWindowcontinues to be and remainsFLEXWindow, or not found and could have been locatedfallbackWindow, and remain the same as before to keep it
            } else {
                applicationWindow = fallbackWindow; // Use the non-use instead of usingFLEXWindow window of the windows
            }
        }
        #pragma clang diagnostic pop
    }
    
    return applicationWindow;
}

@end