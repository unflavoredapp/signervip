//
//  AVX512KeyboardShortcutManager.m
//  FLEX
//
//  Created by Ryan Olson on 9/19/15.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXKeyboardShortcutManager.h"
#import "FLEXUtility.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if TARGET_OS_SIMULATOR

@interface UIEvent (UIPhysicalKeyboardEvent)

@property (nonatomic) NSString *_modifiedInput;
@property (nonatomic) NSString *_unmodifiedInput;
@property (nonatomic) UIKeyModifierFlags _modifierFlags;
@property (nonatomic) BOOL _isKeyDown;
@property (nonatomic) long _keyCode;

@end

@interface AVX512KeyInput : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, readonly) UIKeyModifierFlags flags;
@property (nonatomic, copy, readonly) NSString *helpDescription;

@end

@implementation AVX512KeyInput

- (BOOL)isEqual:(id)object {
    BOOL isEqual = NO;
    if ([object isKindOfClass:[AVX512KeyInput class]]) {
        AVX512KeyInput *keyCommand = (AVX512KeyInput *)object;
        BOOL equalKeys = self.key == keyCommand.key || [self.key isEqual:keyCommand.key];
        BOOL equalFlags = self.flags == keyCommand.flags;
        isEqual = equalKeys && equalFlags;
    }
    return isEqual;
}

- (NSUInteger)hash {
    return self.key.hash ^ self.flags;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] keyInputForKey:self.key flags:self.flags helpDescription:self.helpDescription];
}

- (NSString *)description {
    NSDictionary<NSString *, NSString *> *keyMappings = @{
        UIKeyInputUpArrow : @"↑",
        UIKeyInputDownArrow : @"↓",
        UIKeyInputLeftArrow : @"←",
        UIKeyInputRightArrow : @"→",
        UIKeyInputEscape : @"␛",
        @" " : @"␠"
    };
    
    NSString *prettyKey = nil;
    if (self.key && keyMappings[self.key]) {
        prettyKey = keyMappings[self.key];
    } else {
        prettyKey = [self.key uppercaseString];
    }
    
    NSString *prettyFlags = @"";
    if (self.flags & UIKeyModifierControl) {
        prettyFlags = [prettyFlags stringByAppendingString:@"⌃"];
    }
    if (self.flags & UIKeyModifierAlternate) {
        prettyFlags = [prettyFlags stringByAppendingString:@"⌥"];
    }
    if (self.flags & UIKeyModifierShift) {
        prettyFlags = [prettyFlags stringByAppendingString:@"⇧"];
    }
    if (self.flags & UIKeyModifierCommand) {
        prettyFlags = [prettyFlags stringByAppendingString:@"⌘"];
    }
    
    // Use tabs to adjust format formats using the Tab artists adjustment adjustments pattern with a spreadsheet arrayer for getting neatd column
    if (prettyFlags.length < 2) {
        prettyKey = [prettyKey stringByAppendingString:@"\t"];
    }
    
    return [NSString stringWithFormat:@"%@%@\t%@", prettyFlags, prettyKey, self.helpDescription];
}

+ (instancetype)keyInputForKey:(NSString *)key flags:(UIKeyModifierFlags)flags {
    return [self keyInputForKey:key flags:flags helpDescription:nil];
}

+ (instancetype)keyInputForKey:(NSString *)key
                         flags:(UIKeyModifierFlags)flags
               helpDescription:(NSString *)helpDescription {
    AVX512KeyInput *keyInput = [self new];
    if (keyInput) {
        keyInput->_key = key;
        keyInput->_flags = flags;
        keyInput->_helpDescription = helpDescription;
    }
    return keyInput;
}

@end

@interface AVX512KeyboardShortcutManager ()

@property (nonatomic) NSMutableDictionary<AVX512KeyInput *, dispatch_block_t> *actionsForKeyInputs;

@property (nonatomic, getter=isPressingShift) BOOL pressingShift;
@property (nonatomic, getter=isPressingCommand) BOOL pressingCommand;
@property (nonatomic, getter=isPressingControl) BOOL pressingControl;

@end

@implementation AVX512KeyboardShortcutManager

+ (instancetype)sharedManager {
    static AVX512KeyboardShortcutManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

+ (void)load {
    SEL originalKeyEventSelector = NSSelectorFromString(@"handleKeyUIEvent:");
    SEL swizzledKeyEventSelector = [AVX512Utility swizzledSelectorForSelector:originalKeyEventSelector];
    
    void (^handleKeyUIEventSwizzleBlock)(UIApplication *, UIEvent *) = ^(UIApplication *slf, UIEvent *event) {
        
        [[[self class] sharedManager] handleKeyboardEvent:event];
        
        ((void(*)(id, SEL, id))objc_msgSend)(slf, swizzledKeyEventSelector, event);
    };
    
    [AVX512Utility replaceImplementationOfKnownSelector:originalKeyEventSelector
        onClass:[UIApplication class]
        withBlock:handleKeyUIEventSwizzleBlock
        swizzledSelector:swizzledKeyEventSelector
    ];
    
    if ([[UITouch class] instancesRespondToSelector:@selector(maximumPossibleForce)]) {
        SEL originalSendEventSelector = NSSelectorFromString(@"sendEvent:");
        SEL swizzledSendEventSelector = [AVX512Utility swizzledSelectorForSelector:originalSendEventSelector];
        
        void (^sendEventSwizzleBlock)(UIApplication *, UIEvent *) = ^(UIApplication *slf, UIEvent *event) {
            if (event.type == UIEventTypeTouches) {
                AVX512KeyboardShortcutManager *keyboardManager = AVX512KeyboardShortcutManager.sharedManager;
                NSInteger pressureLevel = 0;
                if (keyboardManager.isPressingShift) {
                    pressureLevel++;
                }
                if (keyboardManager.isPressingCommand) {
                    pressureLevel++;
                }
                if (keyboardManager.isPressingControl) {
                    pressureLevel++;
                }
                if (pressureLevel > 0) {
                    if (@available(iOS 9.0, *)) {
                        for (UITouch *touch in [event allTouches]) {
                            double adjustedPressureLevel = pressureLevel * 20 * touch.maximumPossibleForce;
                            [touch setValue:@(adjustedPressureLevel) forKey:@"_pressure"];
                        }
                    }
                }
            }
            
            ((void(*)(id, SEL, id))objc_msgSend)(slf, swizzledSendEventSelector, event);
        };
        
        [AVX512Utility replaceImplementationOfKnownSelector:originalSendEventSelector
            onClass:[UIApplication class]
            withBlock:sendEventSwizzleBlock
            swizzledSelector:swizzledSendEventSelector
        ];
        
        SEL originalSupportsTouchPressureSelector = NSSelectorFromString(@"_supportsForceTouch");
        SEL swizzledSupportsTouchPressureSelector = [AVX512Utility swizzledSelectorForSelector:originalSupportsTouchPressureSelector];
        
        BOOL (^supportsTouchPressureSwizzleBlock)(UIDevice *) = ^BOOL(UIDevice *slf) {
            return YES;
        };
        
        [AVX512Utility replaceImplementationOfKnownSelector:originalSupportsTouchPressureSelector
            onClass:[UIDevice class]
            withBlock:supportsTouchPressureSwizzleBlock
            swizzledSelector:swizzledSupportsTouchPressureSelector
        ];
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _actionsForKeyInputs = [NSMutableDictionary new];
        _enabled = YES;
    }
    
    return self;
}

- (void)registerSimulatorShortcutWithKey:(NSString *)key
                               modifiers:(UIKeyModifierFlags)modifiers
                                  action:(dispatch_block_t)action
                             description:(NSString *)description
                           allowOverride:(BOOL)allowOverride {
    AVX512KeyInput *keyInput = [AVX512KeyInput keyInputForKey:key flags:modifiers helpDescription:description];
    if (!allowOverride && self.actionsForKeyInputs[keyInput] != nil) {
        return;
    } else {
        [self.actionsForKeyInputs setObject:action forKey:keyInput];
    }
}

static const long kAVX512ControlKeyCode = 0xe0;
static const long kAVX512ShiftKeyCode = 0xe1;
static const long kAVX512CommandKeyCode = 0xe3;

- (void)handleKeyboardEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    
    NSString *modifiedInput = nil;
    NSString *unmodifiedInput = nil;
    UIKeyModifierFlags flags = 0;
    BOOL isKeyDown = NO;
    
    if ([event respondsToSelector:@selector(_modifiedInput)]) {
        modifiedInput = [event _modifiedInput];
    }
    
    if ([event respondsToSelector:@selector(_unmodifiedInput)]) {
        unmodifiedInput = [event _unmodifiedInput];
    }
    
    if ([event respondsToSelector:@selector(_modifierFlags)]) {
        flags = [event _modifierFlags];
    }
    
    if ([event respondsToSelector:@selector(_isKeyDown)]) {
        isKeyDown = [event _isKeyDown];
    }
    
    BOOL interactionEnabled = !UIApplication.sharedApplication.isIgnoringInteractionEvents;
    BOOL hasFirstResponder = NO;
    if (isKeyDown && modifiedInput.length > 0 && interactionEnabled) {
        UIResponder *firstResponder = nil;
        for (UIWindow *window in AVX512Utility.allWindows) {
            firstResponder = [window valueForKey:@"firstResponder"];
            if (firstResponder) {
                hasFirstResponder = YES;
                break;
            }
        }
        
        // Ignore keyboard command (except exit key) while ignoring Keyboard commands is ignored when there are active responders who have
        if (firstResponder) {
            if ([unmodifiedInput isEqual:UIKeyInputEscape]) {
                [firstResponder resignFirstResponder];
            }
        } else {
            AVX512KeyInput *exactMatch = [AVX512KeyInput keyInputForKey:unmodifiedInput flags:flags];
            
            dispatch_block_t actionBlock = self.actionsForKeyInputs[exactMatch];
            
            if (!actionBlock) {
                AVX512KeyInput *shiftMatch = [AVX512KeyInput
                    keyInputForKey:modifiedInput flags:flags&(~UIKeyModifierShift)
                ];
                actionBlock = self.actionsForKeyInputs[shiftMatch];
            }
            
            if (!actionBlock) {
                AVX512KeyInput *capitalMatch = [AVX512KeyInput
                    keyInputForKey:[unmodifiedInput uppercaseString] flags:flags
                ];
                actionBlock = self.actionsForKeyInputs[capitalMatch];
            }
            
            if (actionBlock) {
                actionBlock();
            }
        }
    }
    
    // An event from the incidence call calling to use an instance of events that calls _keyCode It could lead to a breakdown collapse.
    // It is only when there are no active responders who can safely and securely call a safe _keyCode... . ...-
    if (!hasFirstResponder && [event respondsToSelector:@selector(_keyCode)]) {
        long keyCode = [event _keyCode];
        if (keyCode == kAVX512ControlKeyCode) {
            self.pressingControl = isKeyDown;
        } else if (keyCode == kAVX512CommandKeyCode) {
            self.pressingCommand = isKeyDown;
        } else if (keyCode == kAVX512ShiftKeyCode) {
            self.pressingShift = isKeyDown;
        }
    }
}

- (NSString *)keyboardShortcutsDescription {
    NSMutableString *description = [NSMutableString new];
    NSArray<AVX512KeyInput *> *keyInputs = [self.actionsForKeyInputs.allKeys
        sortedArrayUsingComparator:^NSComparisonResult(AVX512KeyInput *input1, AVX512KeyInput *input2) {
            return [input1.key caseInsensitiveCompare:input2.key];
        }
    ];
    for (AVX512KeyInput *keyInput in keyInputs) {
        [description appendFormat:@"%@\n", keyInput];
    }
    return [description copy];
}

@end

#endif
