#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVX512DoKitLogLevel) {
    AVX512DoKitLogLevelVerbose = 0,
    AVX512DoKitLogLevelDebug = 1,
    AVX512DoKitLogLevelInfo = 2,
    AVX512DoKitLogLevelWarning = 3,
    AVX512DoKitLogLevelError = 4
};

@interface AVX512DoKitLogEntry : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) AVX512DoKitLogLevel level;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *category;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSUInteger line;

+ (instancetype)entryWithMessage:(NSString *)message level:(AVX512DoKitLogLevel)level;

@end

NS_ASSUME_NONNULL_END