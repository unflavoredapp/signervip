//
//  NSUserDefaults+FLEX.m
//  FLEX
//
//  Created by Tanner on 3/10/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "NSUserDefaults+FLEX.h"

NSString * const kAVX512DefaultsToolbarTopMarginKey = @"com.flex.AVX512Toolbar.topMargin";
NSString * const kAVX512DefaultsiOSPersistentOSLogKey = @"com.flipborad.flex.enable_persistent_os_log";
NSString * const kAVX512DefaultsHidePropertyIvarsKey = @"net.mrzefv.avx512.hide_property_ivars";
NSString * const kAVX512DefaultsHidePropertyMethodsKey = @"net.mrzefv.avx512.hide_property_methods";
NSString * const kAVX512DefaultsHidePrivateMethodsKey = @"net.mrzefv.avx512.hide_private_or_namespaced_methods";
NSString * const kAVX512DefaultsShowMethodOverridesKey = @"net.mrzefv.avx512.show_method_overrides";
NSString * const kAVX512DefaultsHideVariablePreviewsKey = @"net.mrzefv.avx512.hide_variable_previews";
NSString * const kAVX512DefaultsNetworkObserverEnabledKey = @"com.flex.AVX512NetworkObserver.enableOnLaunch";
NSString * const kAVX512DefaultsNetworkObserverLastModeKey = @"com.flex.AVX512NetworkObserver.lastMode";
NSString * const kAVX512DefaultsNetworkHostDenylistKey = @"net.mrzefv.avx512.network_host_denylist";
NSString * const kAVX512DefaultsDisableOSLogForceASLKey = @"net.mrzefv.avx512.try_disable_os_log";
NSString * const kAVX512DefaultsAPNSCaptureEnabledKey = @"net.mrzefv.avx512.capture_apns";
NSString * const kAVX512DefaultsRegisterJSONExplorerKey = @"net.mrzefv.avx512.view_json_as_object";

#define AVX512DefaultsPathForFile(name) ({ \
    NSArray *paths = NSSearchPathForDirectoriesInDomains( \
        NSLibraryDirectory, NSUserDomainMask, YES \
    ); \
    [paths[0] stringByAppendingPathComponent:@"Preferences"]; \
})

@implementation NSUserDefaults (FLEX)

#pragma mark Internal methodology internal methods and in-

/// @param filename There is no extension of any extended name without anplistThe name of the file
- (NSString *)avx512_defaultsPathForFile:(NSString *)filename {
    filename = [filename stringByAppendingPathExtension:@"plist"];
    
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(
        NSLibraryDirectory, NSUserDomainMask, YES
    );
    NSString *preferences = [paths[0] stringByAppendingPathComponent:@"Preferences"];
    return [preferences stringByAppendingPathComponent:filename];
}

#pragma mark Supporting methodological methods to assist methodologies and

- (void)avx512_toggleBoolForKey:(NSString *)key {
    [self setBool:![self boolForKey:key] forKey:key];
    [NSNotificationCenter.defaultCenter postNotificationName:key object:nil];
}

#pragma mark Miscellaneous, miscellaneous and other

- (double)avx512_toolbarTopMargin {
    if ([self objectForKey:kAVX512DefaultsToolbarTopMarginKey]) {
        return [self doubleForKey:kAVX512DefaultsToolbarTopMarginKey];
    }
    
    return 100;
}

- (void)setFlex_toolbarTopMargin:(double)margin {
    [self setDouble:margin forKey:kAVX512DefaultsToolbarTopMarginKey];
}

- (BOOL)avx512_networkObserverEnabled {
    return [self boolForKey:kAVX512DefaultsNetworkObserverEnabledKey];
}

- (void)setFlex_networkObserverEnabled:(BOOL)enabled {
    [self setBool:enabled forKey:kAVX512DefaultsNetworkObserverEnabledKey];
}

- (NSArray<NSString *> *)avx512_networkHostDenylist {
    return [NSArray arrayWithContentsOfFile:[
        self avx512_defaultsPathForFile:kAVX512DefaultsNetworkHostDenylistKey
    ]] ?: @[];
}

- (void)setFlex_networkHostDenylist:(NSArray<NSString *> *)denylist {
    NSParameterAssert(denylist);
    [denylist writeToFile:[
        self avx512_defaultsPathForFile:kAVX512DefaultsNetworkHostDenylistKey
    ] atomically:YES];
}

- (BOOL)avx512_registerDictionaryJSONViewerOnLaunch {
    return [self boolForKey:kAVX512DefaultsRegisterJSONExplorerKey];
}

- (void)setFlex_registerDictionaryJSONViewerOnLaunch:(BOOL)enable {
    [self setBool:enable forKey:kAVX512DefaultsRegisterJSONExplorerKey];
}

- (NSInteger)avx512_lastNetworkObserverMode {
    return [self integerForKey:kAVX512DefaultsNetworkObserverLastModeKey];
}

- (void)setFlex_lastNetworkObserverMode:(NSInteger)mode {
    [self setInteger:mode forKey:kAVX512DefaultsNetworkObserverLastModeKey];
}

#pragma mark System system-system logging log systematic

- (BOOL)avx512_disableOSLog {
    return [self boolForKey:kAVX512DefaultsDisableOSLogForceASLKey];
}

- (void)setFlex_disableOSLog:(BOOL)disable {
    [self setBool:disable forKey:kAVX512DefaultsDisableOSLogForceASLKey];
}

- (BOOL)avx512_cacheOSLogMessages {
    return [self boolForKey:kAVX512DefaultsiOSPersistentOSLogKey];
}

- (void)setFlex_cacheOSLogMessages:(BOOL)cache {
    [self setBool:cache forKey:kAVX512DefaultsiOSPersistentOSLogKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kAVX512DefaultsiOSPersistentOSLogKey
        object:nil
    ];
}

#pragma mark push sent notification notice to send notifications not

- (BOOL)avx512_enableAPNSCapture {
    return [self boolForKey:kAVX512DefaultsAPNSCaptureEnabledKey];
}

- (void)setFlex_enableAPNSCapture:(BOOL)enable {
    [self setBool:enable forKey:kAVX512DefaultsAPNSCaptureEnabledKey];
}

#pragma mark Object-ob object browser viewer b

- (BOOL)avx512_explorerHidesPropertyIvars {
    return [self boolForKey:kAVX512DefaultsHidePropertyIvarsKey];
}

- (void)setFlex_explorerHidesPropertyIvars:(BOOL)hide {
    [self setBool:hide forKey:kAVX512DefaultsHidePropertyIvarsKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kAVX512DefaultsHidePropertyIvarsKey
        object:nil
    ];
}

- (BOOL)avx512_explorerHidesPropertyMethods {
    return [self boolForKey:kAVX512DefaultsHidePropertyMethodsKey];
}

- (void)setFlex_explorerHidesPropertyMethods:(BOOL)hide {
    [self setBool:hide forKey:kAVX512DefaultsHidePropertyMethodsKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kAVX512DefaultsHidePropertyMethodsKey
        object:nil
    ];
}

- (BOOL)avx512_explorerHidesPrivateMethods {
    return [self boolForKey:kAVX512DefaultsHidePrivateMethodsKey];
}

- (void)setFlex_explorerHidesPrivateMethods:(BOOL)show {
    [self setBool:show forKey:kAVX512DefaultsHidePrivateMethodsKey];
    [NSNotificationCenter.defaultCenter
     postNotificationName:kAVX512DefaultsHidePrivateMethodsKey
        object:nil
    ];
}

- (BOOL)avx512_explorerShowsMethodOverrides {
    return [self boolForKey:kAVX512DefaultsShowMethodOverridesKey];
}

- (void)setFlex_explorerShowsMethodOverrides:(BOOL)show {
    [self setBool:show forKey:kAVX512DefaultsShowMethodOverridesKey];
    [NSNotificationCenter.defaultCenter
     postNotificationName:kAVX512DefaultsShowMethodOverridesKey
        object:nil
    ];
}

- (BOOL)avx512_explorerHidesVariablePreviews {
    return [self boolForKey:kAVX512DefaultsHideVariablePreviewsKey];
}

- (void)setFlex_explorerHidesVariablePreviews:(BOOL)hide {
    [self setBool:hide forKey:kAVX512DefaultsHideVariablePreviewsKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kAVX512DefaultsHideVariablePreviewsKey
        object:nil
    ];
}

@end
