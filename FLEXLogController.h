//
//  AVX512LogController.h
//  FLEX
//
//  Created by Tanner on 3/17/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLEXSystemLogMessage.h"

@protocol AVX512LogController <NSObject>

/// Guaranteed to call back on the main thread.
+ (instancetype)withUpdateHandler:(void(^)(NSArray<AVX512SystemLogMessage *> *newMessages))newMessagesHandler;

- (BOOL)startMonitoring;

@end
