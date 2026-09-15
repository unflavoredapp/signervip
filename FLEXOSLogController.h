//
//  AVX512OSLogController.h
//  FLEX
//
//  Created by Tanner on 12/19/18.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXLogController.h"

#define AVX512OSLogAvailable() (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 10)

/// to be used for useiOS 10and the above versions of loglog controllers.
@interface AVX512OSLogController : NSObject <AVX512LogController>

+ (instancetype)withUpdateHandler:(void(^)(NSArray<AVX512SystemLogMessage *> *newMessages))newMessagesHandler;

- (BOOL)startMonitoring;

/// Whether log message information needs to be recorded and stored in the background memory on your back desk. You need a journal messages
/// You do not need to initialize this value, you simply change it. Just modify the
@property (nonatomic) BOOL persistent;
/// mainly used primarily in-house, but also by the log view views control controller to save saved saving that
/// Message created before enabling the message to enable sustainability. The messages that were
@property (nonatomic) NSMutableArray<AVX512SystemLogMessage *> *messages;

@end
