//
//  AVX512RuntimeBrowserToolbar.m
//  FLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXRuntimeBrowserToolbar.h"
#import "FLEXRuntimeKeyPathTokenizer.h"

@interface AVX512RuntimeBrowserToolbar ()
@property (nonatomic, copy) AVX512KBToolbarAction tapHandler;
@end

@implementation AVX512RuntimeBrowserToolbar

+ (instancetype)toolbarWithHandler:(AVX512KBToolbarAction)tapHandler suggestions:(NSArray<NSString *> *)suggestions {
    NSArray *buttons = [self
        buttonsForKeyPath:AVX512RuntimeKeyPath.empty suggestions:suggestions handler:tapHandler
    ];

    AVX512RuntimeBrowserToolbar *me = [self toolbarWithButtons:buttons];
    me.tapHandler = tapHandler;
    return me;
}

+ (NSArray<AVX512KBToolbarButton*> *)buttonsForKeyPath:(AVX512RuntimeKeyPath *)keyPath
                                     suggestions:(NSArray<NSString *> *)suggestions
                                         handler:(AVX512KBToolbarAction)handler {
    NSMutableArray *buttons = [NSMutableArray new];
    AVX512SearchToken *lastKey = nil;
    BOOL lastKeyIsMethod = NO;

    if (keyPath.methodKey) {
        lastKey = keyPath.methodKey;
        lastKeyIsMethod = YES;
    } else {
        lastKey = keyPath.classKey ?: keyPath.bundleKey;
    }

    switch (lastKey.options) {
        case TBWildcardOptionsNone:
        case TBWildcardOptionsAny:
            if (lastKeyIsMethod) {
                if (!keyPath.instanceMethods) {
                    [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"-" action:handler]];
                    [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"+" action:handler]];
                }
                [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*" action:handler]];
            } else {
                [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*" action:handler]];
                [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*." action:handler]];
            }
            break;

        default: {
            if (lastKey.options & TBWildcardOptionsPrefix) {
                if (lastKeyIsMethod) {
                    if (lastKey.string.length) {
                        [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*" action:handler]];
                    }
                } else {
                    if (lastKey.string.length) {
                        [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*." action:handler]];
                    }
                }
            }

            else if (lastKey.options & TBWildcardOptionsSuffix) {
                if (!lastKeyIsMethod) {
                    [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*" action:handler]];
                    [buttons addObject:[AVX512KBToolbarButton buttonWithTitle:@"*." action:handler]];
                }
            }
        }
    }
    
    for (NSString *suggestion in suggestions) {
        [buttons addObject:[AVX512KBToolbarSuggestedButton buttonWithTitle:suggestion action:handler]];
    }

    return buttons;
}

- (void)setKeyPath:(AVX512RuntimeKeyPath *)keyPath suggestions:(NSArray<NSString *> *)suggestions {
    self.buttons = [self.class
        buttonsForKeyPath:keyPath suggestions:suggestions handler:self.tapHandler
    ];
}

@end
