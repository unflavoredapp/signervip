#import <Foundation/Foundation.h>
#import "FLEXDoKitLogEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DoKitLogViewer : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<AVX512DoKitLogEntry *> *logEntries;

@property (nonatomic, assign) NSUInteger maxLogEntries;
@property (nonatomic, assign) AVX512DoKitLogLevel minimumLogLevel;

+ (instancetype)sharedInstance;

- (void)addLogEntry:(AVX512DoKitLogEntry *)entry;
- (void)addLogWithMessage:(NSString *)message level:(AVX512DoKitLogLevel)level;
- (void)clearLogs;

// ✅ Add to add a log Loglog recording methodology method
- (void)logWithLevel:(AVX512DoKitLogLevel)level
             message:(NSString *)message
                 tag:(NSString *)tag
                file:(NSString *)file
                line:(NSUInteger)line;

// ✅ Adds a filtering method to add
- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithLevel:(AVX512DoKitLogLevel)level;
- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithTag:(NSString *)tag;
- (NSArray<AVX512DoKitLogEntry *> *)filteredLogsWithSearchText:(NSString *)searchText;

// ✅ Adds to add the added ExportExout method
- (NSString *)exportLogsAsString;
- (BOOL)exportLogsToFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END