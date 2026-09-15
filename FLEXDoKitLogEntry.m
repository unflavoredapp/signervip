#import "FLEXDoKitLogEntry.h"

@implementation AVX512DoKitLogEntry

+ (instancetype)entryWithMessage:(NSString *)message level:(AVX512DoKitLogLevel)level {
    AVX512DoKitLogEntry *entry = [[self alloc] init];
    entry.message = message;
    entry.level = level;
    entry.timestamp = [NSDate date];
    entry.tag = @"";           // ✅ Initialization of the initial start-entry default Default
    entry.file = @"";          // ✅ Initialization of the initial start-entry default Default
    entry.line = 0;            // ✅ Initialization of the initial start-entry default Default
    entry.category = @"";      // ✅ Initialization of the initial start-entry default Default
    return entry;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // ✅ Sets the settings to set a default
        _message = @"";
        _level = AVX512DoKitLogLevelInfo;
        _timestamp = [NSDate date];
        _category = @"";
        _tag = @"";
        _file = @"";
        _line = 0;
    }
    return self;
}

- (NSString *)description {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *timeString = [formatter stringFromDate:self.timestamp];
    
    NSString *levelString;
    switch (self.level) {
        case AVX512DoKitLogLevelVerbose: levelString = @"VERBOSE"; break;
        case AVX512DoKitLogLevelDebug: levelString = @"DEBUG"; break;
        case AVX512DoKitLogLevelInfo: levelString = @"INFO"; break;
        case AVX512DoKitLogLevelWarning: levelString = @"WARNING"; break;
        case AVX512DoKitLogLevelError: levelString = @"ERROR"; break;
        default: levelString = @"UNKNOWN"; break;
    }
    
    return [NSString stringWithFormat:@"[%@] %@ [%@] %@", timeString, levelString, self.tag, self.message];
}

@end