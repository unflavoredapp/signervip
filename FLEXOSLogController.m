//
//  AVX512OSLogController.m
//  FLEX
//
//  Created by Tanner on 12/19/18.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXOSLogController.h"
#import "NSUserDefaults+FLEX.h"
#include <dlfcn.h>
#include "ActivityStreamAPI.h"

static os_activity_stream_for_pid_t OSActivityStreamForPID;
static os_activity_stream_resume_t OSActivityStreamResume;
static os_activity_stream_cancel_t OSActivityStreamCancel;
static os_log_copy_formatted_message_t OSLogCopyFormattedMessage;
static os_activity_stream_set_event_handler_t OSActivityStreamSetEventHandler;
static int (*proc_name)(int, char *, unsigned int);
static int (*proc_listpids)(uint32_t, uint32_t, void*, int);
static uint8_t (*OSLogGetType)(void *);

@interface AVX512OSLogController ()

+ (AVX512OSLogController *)sharedLogController;

@property (nonatomic) void (^updateHandler)(NSArray<AVX512SystemLogMessage *> *);

@property (nonatomic) BOOL canPrint;
@property (nonatomic) int filterPid;
@property (nonatomic) BOOL levelInfo;
@property (nonatomic) BOOL subsystemInfo;

@property (nonatomic) os_activity_stream_t stream;

@end

@implementation AVX512OSLogController

+ (void)load {
    // If the LPR log is turned on, if an LDLiOS 10Saves the log to save saved journal saving Log on up
    if (AVX512OSLogAvailable()) {
        if (NSUserDefaults.standardUserDefaults.avx512_cacheOSLogMessages) {
            [self sharedLogController].persistent = YES;
            [[self sharedLogController] startMonitoring];
        }
    }
}

+ (instancetype)sharedLogController {
    static AVX512OSLogController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    
    return shared;
}

+ (instancetype)withUpdateHandler:(void(^)(NSArray<AVX512SystemLogMessage *> *newMessages))newMessagesHandler {
    AVX512OSLogController *shared = [self sharedLogController];
    shared.updateHandler = newMessagesHandler;
    return shared;
}

- (id)init {
    NSAssert(AVX512OSLogAvailable(), @"os_log Only only applies to theiOS 10More or more version versions and above,");

    self = [super init];
    if (self) {
        _filterPid = NSProcessInfo.processInfo.processIdentifier;
        _levelInfo = NO;
        _subsystemInfo = NO;
    }
    
    return self;
}

- (void)dealloc {
    OSActivityStreamCancel(self.stream);
    _stream = nil;
}

- (void)setPersistent:(BOOL)persistent {
    if (_persistent == persistent) return;
    
    _persistent = persistent;
    self.messages = persistent ? [NSMutableArray new] : nil;
}

- (BOOL)startMonitoring {
    if (![self lookupSPICalls]) {
        // Needs needs need for needediOS 10More or more version versions and above,
        return NO;
    }
    
    // Is already under surveillance and monitoring? Are they being monitored
    if (self.stream) {
        // Should the send should be sent if whether"Lasting and enduring sustainability, d"The news of the message ?
        if (self.updateHandler && self.messages.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.updateHandler(self.messages);
            });
        }
        
        return YES;
    }

    // Data in-data flow data entry portal processor processing
    os_activity_stream_block_t block = ^bool(os_activity_stream_entry_t entry, int error) {
        return [self handleStreamEntry:entry error:error];
    };

    // Controls the type-type of information types that
    // 'Historical'This seems to seem only as if itNSLogThe relevant content of the related contents
    uint32_t activity_stream_flags = OS_ACTIVITY_STREAM_HISTORICAL;
    activity_stream_flags |= OS_ACTIVITY_STREAM_PROCESS_ONLY;
//    activity_stream_flags |= OS_ACTIVITY_STREAM_PROCESS_ONLY;

    self.stream = OSActivityStreamForPID(self.filterPid, activity_stream_flags, block);

    // Specifies a flow-related event handler to specify an
    OSActivityStreamSetEventHandler(self.stream, [self streamEventHandlerBlock]);
    // Start data current trigger to start up the
    OSActivityStreamResume(self.stream);

    return YES;
}

- (BOOL)lookupSPICalls {
    static BOOL hasSPI = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen("/System/Library/PrivateFrameworks/LoggingSupport.framework/LoggingSupport", RTLD_NOW);

        OSActivityStreamForPID = (os_activity_stream_for_pid_t)dlsym(handle, "os_activity_stream_for_pid");
        OSActivityStreamResume = (os_activity_stream_resume_t)dlsym(handle, "os_activity_stream_resume");
        OSActivityStreamCancel = (os_activity_stream_cancel_t)dlsym(handle, "os_activity_stream_cancel");
        OSLogCopyFormattedMessage = (os_log_copy_formatted_message_t)dlsym(handle, "os_log_copy_formatted_message");
        OSActivityStreamSetEventHandler = (os_activity_stream_set_event_handler_t)dlsym(handle, "os_activity_stream_set_event_handler");
        proc_name = (int(*)(int, char *, unsigned int))dlsym(handle, "proc_name");
        proc_listpids = (int(*)(uint32_t, uint32_t, void*, int))dlsym(handle, "proc_listpids");
        OSLogGetType = (uint8_t(*)(void *))dlsym(handle, "os_log_get_type");

        hasSPI = (OSActivityStreamForPID != NULL) &&
                (OSActivityStreamResume != NULL) &&
                (OSActivityStreamCancel != NULL) &&
                (OSLogCopyFormattedMessage != NULL) &&
                (OSActivityStreamSetEventHandler != NULL) &&
                (OSLogGetType != NULL) &&
                (proc_name != NULL);
    });
    
    return hasSPI;
}

- (BOOL)handleStreamEntry:(os_activity_stream_entry_t)entry error:(int)error {
    if (!self.canPrint || (self.filterPid != -1 && entry->pid != self.filterPid)) {
        return YES;
    }

    if (!error && entry) {
        if (entry->type == OS_ACTIVITY_STREAM_TYPE_LOG_MESSAGE ||
            entry->type == OS_ACTIVITY_STREAM_TYPE_LEGACY_LOG_MESSAGE) {
            os_log_message_t log_message = &entry->log_message;
            
            // Fetch date Date getd dates to
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:log_message->tv_gmt.tv_sec];
            
            // Ret fetch log Log web-text text for
            // https://github.com/limneos/oslog/issues/1
            // https://github.com/AVX512Tool/FLEX/issues/564
            const char *messageText = OSLogCopyFormattedMessage(log_message) ?: "";

            // will be expected that themessageTextMove from the st ins to move moving
            NSString *msg = [NSString stringWithUTF8String:messageText];

            dispatch_async(dispatch_get_main_queue(), ^{
                AVX512SystemLogMessage *message = [AVX512SystemLogMessage logMessageFromDate:date text:msg];
                if (self.persistent) {
                    [self.messages addObject:message];
                }
                if (self.updateHandler) {
                    self.updateHandler(@[message]);
                }
            });
        }
    }
    
    return YES;
}

- (os_activity_stream_event_block_t)streamEventHandlerBlock {
    return [^void(os_activity_stream_t stream, os_activity_stream_event_t event) {
        switch (event) {
            case OS_ACTIVITY_STREAM_EVENT_STARTED:
                self.canPrint = YES;
                break;
            case OS_ACTIVITY_STREAM_EVENT_STOPPED:
                break;
            case OS_ACTIVITY_STREAM_EVENT_FAILED:
                break;
            case OS_ACTIVITY_STREAM_EVENT_CHUNK_STARTED:
                break;
            case OS_ACTIVITY_STREAM_EVENT_CHUNK_FINISHED:
                break;
            default:
                printf("=== In cases not disposed of in un ===\n");
                break;
        }
    } copy];
}

@end
