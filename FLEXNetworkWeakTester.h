//
//  AVX512NetworkWeakTester.h
//  FLEX
//
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AVX512NetworkWeakType) {
    AVX512NetworkWeakTypeNone,       // The normal network of regular networks,
    AVX512NetworkWeakTypeSlow2G,     // Slow slow pace, slower speed and2G
    AVX512NetworkWeakType2G,         // 2G
    AVX512NetworkWeakType3G,         // 3G
    AVX512NetworkWeakType4G,         // 4G
    AVX512NetworkWeakTypeWifi,       // WiFi
    AVX512NetworkWeakTypeDisconnect, // I've broken off the net
};

@interface AVX512NetworkWeakTester : NSObject

+ (instancetype)sharedInstance;

// Starting to simulate the simulations of weak net
- (void)startWeakNetworkWithType:(AVX512NetworkWeakType)type;

// Stop stop the weaknet net grid simulation sim
- (void)stopWeakNetwork;

// Current current simulation state of the currently-
@property (nonatomic, readonly) AVX512NetworkWeakType currentWeakType;

@end