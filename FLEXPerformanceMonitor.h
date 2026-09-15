//
//  AVX512PerformanceMonitor.h
//  FLEX
//
//  Created based on DoKit performance tools.
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512PerformanceMonitor : NSObject

/**
 * Returns the shared share-shared examples of instances in which an example instance
 */
+ (instancetype)sharedInstance;

/**
 * Current current currently the presentFPSValue value of the values
 */
@property (nonatomic, assign, readonly) float currentFPS;

/**
 * CPUUs rate of usage (percentage percentage per cent) utilization
 */
@property (nonatomic, assign, readonly) float cpuUsage;

/**
 * Memory memory usage (to the amount of use(useMB()), and the
 */
@property (nonatomic, assign, readonly) double memoryUsage;

/**
 * Upload up-up upload traffic flow (by bytes to/s (s) seconds(second
 */
@property (nonatomic, assign, readonly) uint64_t uploadFlowBytes;

/**
 * Downloads the flow of download traffic (by bytes/s (s) seconds(second
 */
@property (nonatomic, assign, readonly) uint64_t downloadFlowBytes;

/**
 * All surveillance monitoring and control start-up
 */
- (void)startAllMonitoring;

/**
 * Stop all surveillance monitoring and control controls from
 */
- (void)stopAllMonitoring;

/**
 * Start start starting beginning startedFPSMonitoring, surveillance and monitoring
 */
- (void)startFPSMonitoring;

/**
 * Stop stopped stop stops toFPSMonitoring, surveillance and monitoring
 */
- (void)stopFPSMonitoring;

/**
 * Start start starting beginning startedCPUMonitoring, surveillance and monitoring
 */
- (void)startCPUMonitoring;

/**
 * Stop stopped stop stops toCPUMonitoring, surveillance and monitoring
 */
- (void)stopCPUMonitoring;

/**
 * Start start memory-res MemorySRAM surveillance
 */
- (void)startMemoryMonitoring;

/**
 * Stop RAM memory-sic monitored monitoring control
 */
- (void)stopMemoryMonitoring;

/**
 * Start starting network traffic flow-flow monitoring and web
 */
- (void)startNetworkMonitoring;

/**
 * Stop the network traffic-flow monitoring and control of
 */
- (void)stopNetworkMonitoring;

/**
 * Start starting track-tracking class load time to start tracking
 */
- (void)startTrackingClassLoadTime;

/**
 * Fetch to fetch class-into load loading timetime information
 */
- (NSArray *)getClassLoadTimeInfo;

/**
 * Starting start of method performance analytical analysis for MISA
 */
- (void)startMethodProfiling;

/**
 * Stop stop method performance analytical analysis for modo-
 */
- (void)stopMethodProfiling;

/**
 * Get the results of an analytical analysis to
 */
- (NSArray *)getProfilingResults;

@end

NS_ASSUME_NONNULL_END