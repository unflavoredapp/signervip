//
//  AVX512DoKitNetworkMonitor.h
//  FLEX++
//
//  On the basis of FLEX Enhanced, enhanced web-based Increased Web network monitor enhancement of the networks' security controllers
//  Provision of network requests for web-based request monitoring,Mock Data, weak net-net simulations and functional functions such as data
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Network request for network requests to record change notice notification of
extern NSString *const AVX512DoKitNetworkRequestRecordedNotification;
extern NSString *const AVX512DoKitNetworkResponseRecordedNotification;

@interface AVX512DoKitNetworkMonitor : NSObject

/// All network request records of all Network Request logs (dictionary array set formats for the verction dictionary fields,
@property (nonatomic, strong, readonly) NSMutableArray *networkRequests;

/// One single case for a one-
+ (instancetype)sharedInstance;

#pragma mark - Web-based network surveillance and cyber

/// Launch the launch of network web-based
- (void)startNetworkMonitoring;

/// Stop network surveillance web-based monitoring and
- (void)stopNetworkMonitoring;

/// Clears all network request log records for requests to clear
- (void)clearAllNetworkRequests;

/// Whether or whether it is being monitored for
@property (nonatomic, assign, readonly) BOOL isMonitoring;

#pragma mark - MockFunction function of a functional

/// Mock Whether to enable the mode model whether or
- (BOOL)isMockEnabled;

/// Enable enable-to make Mock Mode mode modes the format
- (void)enableMockMode;

/// Disabled disabled disable Dis Use dis- Mock Mode mode modes the format
- (void)disableMockMode;

/// Add added add to the Mock Rules and rules rule Rule
/// @param rule Rule diction dictionary Dictionary of rules, which needs urlAnd the whole, andmethodAnd the whole, andresponseDataAnd the whole, andstatusCode In the last paragraph, delete existing
- (void)addMockRule:(NSDictionary *)rule;

/// Remove ReSre Mock Rules and rules rule Rule
- (void)removeMockRule:(NSDictionary *)rule;

/// Fetch all fetch access to and get Mock Rules and rules rule Rule
- (NSDictionary *)allMockRules;

#pragma mark - Were net-net simulations of

/// Sim-slow and slow network networks
/// @param delay Delay time delay (s second) delayed due to the
- (void)simulateSlowNetwork:(NSTimeInterval)delay;

/// Sim simulates network bug error-m
- (void)simulateNetworkError;

/// Resets the network networks to reset web-
- (void)resetNetworkSimulation;

/// Current network delay of the current Network Delay
@property (nonatomic, assign, readonly) NSTimeInterval networkDelay;

/// Whether to simulate the network bug error in whether or
@property (nonatomic, assign, readonly) BOOL shouldSimulateError;

@end

NS_ASSUME_NONNULL_END
