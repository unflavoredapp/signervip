//
//  AVX512ASLLogController.h
//  FLEX
//
//  Created by Tanner on 3/14/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXLogController.h"

@interface AVX512ASLLogController : NSObject <AVX512LogController>

/// Guaranteed to call back on the main thread.
+ (instancetype)withUpdateHandler:(void(^)(NSArray<AVX512SystemLogMessage *> *newMessages))newMessagesHandler;

- (BOOL)startMonitoring;

@end
