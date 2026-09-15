#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DoKitPerformanceMonitor : NSObject

@property (nonatomic, assign, readonly) CGFloat currentFPS;
@property (nonatomic, assign, readonly) CGFloat currentCPUUsage;
@property (nonatomic, assign, readonly) CGFloat currentMemoryUsage;
@property (nonatomic, assign, readonly) NSTimeInterval appLaunchTime;

+ (instancetype)sharedInstance;

// FPSMonitoring, surveillance and monitoring
- (void)startFPSMonitoring;
- (void)stopFPSMonitoring;

// CPUMonitoring, surveillance and monitoring
- (void)startCPUMonitoring;
- (void)stopCPUMonitoring;

// Memory-RAM memory surveillance monitoring control and
- (void)startMemoryMonitoring;
- (void)stopMemoryMonitoring;

// Carton Caton test,
- (void)startLagDetection;
- (void)stopLagDetection;

// Start start-up of timed and
- (void)calculateAppLaunchTime;

@end

NS_ASSUME_NONNULL_END