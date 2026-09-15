#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DoKitLeakInfo : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, assign) NSUInteger instanceCount;
@property (nonatomic, strong) NSDate *detectedTime;
@property (nonatomic, strong, nullable) NSArray *suspiciousInstances;

- (NSString *)formattedDetectionTime;
- (NSString *)severityLevel;

@end

@interface AVX512DoKitMemoryLeakDetector : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<AVX512DoKitLeakInfo *> *leakInfos;
@property (nonatomic, assign) BOOL isDetecting;

+ (instancetype)sharedInstance;

// RAM memory leaks detection and investigation of a
- (void)startLeakDetection;
- (void)stopLeakDetection;

// Manual manual, hand- and manually detect
- (void)performLeakDetection;

// Le leaks of information management and
- (void)clearLeakInfos;

@end

NS_ASSUME_NONNULL_END