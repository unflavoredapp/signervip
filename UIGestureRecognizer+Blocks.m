//
//  UIGestureRecognizer+Blocks.m
//  FLEX
//
//  Created by Tanner Bennett on 12/20/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "UIGestureRecognizer+Blocks.h"
#import <objc/runtime.h>


@implementation UIGestureRecognizer (Blocks)

static void * actionKey;

+ (instancetype)avx512_action:(GestureBlock)action {
    UIGestureRecognizer *gesture = [[self alloc] initWithTarget:nil action:nil];
    [gesture addTarget:gesture action:@selector(avx512_invoke)];
    gesture.avx512_action = action;
    return gesture;
}

- (void)avx512_invoke {
    self.avx512_action(self);
}

- (GestureBlock)avx512_action {
    return objc_getAssociatedObject(self, &actionKey);
}

- (void)avx512_setAction:(GestureBlock)action {
    objc_setAssociatedObject(self, &actionKey, action, OBJC_ASSOCIATION_COPY);
}

@end
