#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVX512DoKitCrashType) {
    AVX512DoKitCrashTypeSignal,
    AVX512DoKitCrashTypeException,
    AVX512DoKitCrashTypeKVO,
    AVX512DoKitCrashTypeUnrecognizedSelector
};

@interface AVX512DoKitCrashInfo : NSObject
@property (nonatomic, assign) AVX512DoKitCrashType type;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSArray *callStack;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSDictionary *deviceInfo;

// ✅ It merely states the method of stating, without realizing
- (NSDictionary *)dictionaryRepresentation;

@end

@interface AVX512DoKitCrashMonitor : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<AVX512DoKitCrashInfo *> *crashLogs;

+ (instancetype)sharedInstance;

// crashing of a collapse-of
- (void)startCrashMonitoring;
- (void)stopCrashMonitoring;

// Cr crash log management collapsesL entry
- (void)clearCrashLogs;
- (NSString *)exportCrashLogsAsString;

@end

NS_ASSUME_NONNULL_END