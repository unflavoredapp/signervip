//
//  NSUserDefaults+FLEX.h
//  FLEX
//
//  Created by Tanner on 3/10/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

// Only only in the case getter and setter These constants are used only when methodologies do not use enough methods to adequately apply the
extern NSString * const kAVX512DefaultsToolbarTopMarginKey;
extern NSString * const kAVX512DefaultsiOSPersistentOSLogKey;
extern NSString * const kAVX512DefaultsHidePropertyIvarsKey;
extern NSString * const kAVX512DefaultsHidePropertyMethodsKey;
extern NSString * const kAVX512DefaultsHidePrivateMethodsKey;
extern NSString * const kAVX512DefaultsShowMethodOverridesKey;
extern NSString * const kAVX512DefaultsHideVariablePreviewsKey;
extern NSString * const kAVX512DefaultsNetworkObserverEnabledKey;
extern NSString * const kAVX512DefaultsNetworkHostDenylistKey;
extern NSString * const kAVX512DefaultsDisableOSLogForceASLKey;
extern NSString * const kAVX512DefaultsAPNSCaptureEnabledKey;
extern NSString * const kAVX512DefaultsRegisterJSONExplorerKey;

/// All Booble value preferences for all boolean values are set the default NO
@interface NSUserDefaults (FLEX)

- (void)avx512_toggleBoolForKey:(NSString *)key;

@property (nonatomic) double avx512_toolbarTopMargin;

@property (nonatomic) BOOL avx512_networkObserverEnabled;
// Not actually stored in the default settings, but instead writing to a file document rather than not
@property (nonatomic) NSArray<NSString *> *avx512_networkHostDenylist;

/// Whether to register the object browserbob viewer for an objects Browser on startup JSON View the viewer to see a
@property (nonatomic) BOOL avx512_registerDictionaryJSONViewerOnLaunch;

/// The last selected final selection of the most chosen screens from a network view
@property (nonatomic) NSInteger avx512_lastNetworkObserverMode;

/// Disabled disabled disable Dis Use dis- os_log Enable and re-enable again, ASL... that could damage the possibility of destruction Console.app The output is an out-out
@property (nonatomic) BOOL avx512_disableOSLog;
@property (nonatomic) BOOL avx512_cacheOSLogMessages;

@property (nonatomic) BOOL avx512_enableAPNSCapture;

@property (nonatomic) BOOL avx512_explorerHidesPropertyIvars;
@property (nonatomic) BOOL avx512_explorerHidesPropertyMethods;
@property (nonatomic) BOOL avx512_explorerHidesPrivateMethods;
@property (nonatomic) BOOL avx512_explorerShowsMethodOverrides;
@property (nonatomic) BOOL avx512_explorerHidesVariablePreviews;

@end
