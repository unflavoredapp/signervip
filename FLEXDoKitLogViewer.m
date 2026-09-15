#import "FLEXDoKitLogViewer.h"

@interface AVX512DoKitLogViewer ()
@property (nonatomic, strong) NSMutableArray<AVX512DoKitLogEntry *> *mutableLogEntries;
@property (nonatomic, strong) dispatch_queue_t logQueue;
@end

@implementation AVX512DoKitLogViewer

+ (instancetype)sharedInstance {
    static AVX512DoKitLogViewer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableLogEntries = [NSMutableArray new];
        _maxLogEntries = 10000;
        _minimumLogLevel = AVX512DoKitLogLevelVerbose;
        _logQueue = dispatch_queue_create("com.flex.dokit.log", DISPATCH_QUEUE_SERIAL);
        
        [self hookNSLog];
    }
    return self;
}

- (NSMutableArray<AVX512DoKitLogEntry *> *)logEntries {
    return self.mutableLogEntries;
}

#pragma mark - NSLog Hook

- (void)hookNSLog {
    // Re-directed and retargetedNSLogOutput output of the outputs
    freopen("/tmp/flexdokit.log", "a+", stderr);
    
    // Listen listen bug log Log file changes over listening to logging
    [self startLogFileMonitoring];
}

- (void)startLogFileMonitoring {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *logPath = @"/tmp/flexdokit.log";
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:logPath];
        
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(logFileChanged:) 
                                                         name:NSFileHandleDataAvailableNotification 
                                                       object:fileHandle];
            [fileHandle waitForDataInBackgroundAndNotify];
        }
    });
}

- (void)logFileChanged:(NSNotification *)notification {
    NSFileHandle *fileHandle = notification.object;
    NSData *data = [fileHandle availableData];
    
    if (data.length > 0) {
        NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self parseLogString:logString];
        [fileHandle waitForDataInBackgroundAndNotify];
    }
}

- (void)parseLogString:(NSString *)logString {
    NSArray *lines = [logString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        if (line.length > 0) {
            [self parseLogLine:line];
        }
    }
}

- (void)parseLogLine:(NSString *)line {
    // Simple, simple and plain easy log-log resolution
    AVX512DoKitLogEntry *entry = [[AVX512DoKitLogEntry alloc] init];
    entry.timestamp = [NSDate date];
    entry.level = AVX512DoKitLogLevelInfo;
    entry.message = line;
    entry.tag = @"NSLog";      // ✅ Now that the properties now exist, and
    entry.file = @"";          // ✅ Now that the properties now exist, and
    entry.line = 0;            // ✅ Now that the properties now exist, and
    
    [self addLogEntry:entry];
}

#pragma mark - Log log logging of the journal record

- (void)logWithLevel:(AVX512DoKitLogLevel)level 
             message:(NSString *)message 
                 tag:(NSString *)tag 
                file:(NSString *)file 
                line:(NSUInteger)line {
    
    if (level < self.minimumLogLevel) {    // ✅ Now that the properties now exist, and
        return;
    }
    
    AVX512DoKitLogEntry *entry = [[AVX512DoKitLogEntry alloc] init];
    entry.timestamp = [NSDate date];
    entry.level = level;
    entry.message = message;
    entry.tag = tag ?: @"";       // ✅ Now that the properties now exist, and
    entry.file = file ?: @"";     // ✅ Now that the properties now exist, and
    entry.line = line;            // ✅ Now that the properties now exist, and
    
    [self addLogEntry:entry];
}

- (void)addLogEntry:(AVX512DoKitLogEntry *)entry {
    dispatch_async(self.logQueue, ^{
        [self.mutableLogEntries addObject:entry];
        
        // ✅ Fix restoration: Use properties instead of using attributes and not wrong to use
        if (self.mutableLogEntries.count > self.maxLogEntries) {
            [self.mutableLogEntries removeObjectAtIndex:0];
        }
        
        // Send notification to send a notice sending
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitLogEntryAdded" object:entry];
        });
    });
}

// ✅ How to achieve the missing means of how
- (void)addLogWithMessage:(NSString *)message level:(AVX512DoKitLogLevel)level {
    [self logWithLevel:level message:message tag:@"Manual" file:@"" line:0];
}

#pragma mark - LogLlog administration of the log

- (void)clearLogs {
    dispatch_async(self.logQueue, ^{
        [self.mutableLogEntries removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitLogsCleared" object:nil];
        });
    });
}

- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithLevel:(AVX512DoKitLogLevel)level {
    return [self.logEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"level >= %d", level]];
}

- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithTag:(NSString *)tag {
    return [self.logEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag CONTAINS[cd] %@", tag]];
}

- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithSearchText:(NSString *)searchText {
    return [self.logEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"message CONTAINS[cd] %@", searchText]];
}

#pragma mark - LogEx Export export of the log entry

- (NSString *)exportLogsAsString {
    NSMutableString *exportString = [NSMutableString string];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    for (AVX512DoKitLogEntry *entry in self.logEntries) {
        NSString *levelString = [self stringForLogLevel:entry.level];
        NSString *timestamp = [formatter stringFromDate:entry.timestamp];
        
        // ✅ Repairs: Now now is the timeentry.tagThe properties of the property exist, and
        [exportString appendFormat:@"[%@] %@ [%@] %@\n", 
         timestamp, levelString, entry.tag, entry.message];
    }
    
    return [exportString copy];
}

- (BOOL)exportLogsToFile:(NSString *)filePath {
    NSString *logContent = [self exportLogsAsString];
    NSError *error;
    
    BOOL success = [logContent writeToFile:filePath 
                                atomically:YES 
                                  encoding:NSUTF8StringEncoding 
                                     error:&error];
    
    if (!success) {
        NSLog(@"Failed failed failure to fail the delay error: %@", error.localizedDescription);
    }
    
    return success;
}

- (NSString *)stringForLogLevel:(AVX512DoKitLogLevel)level {
    switch (level) {
        case AVX512DoKitLogLevelVerbose: return @"VERBOSE";
        case AVX512DoKitLogLevelDebug: return @"DEBUG";
        case AVX512DoKitLogLevelInfo: return @"INFO";
        case AVX512DoKitLogLevelWarning: return @"WARNING";
        case AVX512DoKitLogLevelError: return @"ERROR";
        default: return @"UNKNOWN";
    }
}

@end