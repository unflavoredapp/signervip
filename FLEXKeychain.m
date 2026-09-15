//
//  AVX512Keychain.m
//
//  Forked from:
//  SSKeychain.m in SSKeychain
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "FLEXKeychain.h"
#import "FLEXKeychainQuery.h"

NSString * const kAVX512KeychainErrorDomain = @"com.flipboard.flex";
NSString * const kAVX512KeychainAccountKey = @"acct";
NSString * const kAVX512KeychainCreatedAtKey = @"cdat";
NSString * const kAVX512KeychainClassKey = @"labl";
NSString * const kAVX512KeychainDescriptionKey = @"desc";
NSString * const kAVX512KeychainGroupKey = @"agrp";
NSString * const kAVX512KeychainLabelKey = @"labl";
NSString * const kAVX512KeychainLastModifiedKey = @"mdat";
NSString * const kAVX512KeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
static CFTypeRef AVX512KeychainAccessibilityType = NULL;
#endif

@implementation AVX512Keychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordForService:serviceName account:account error:nil];
}

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.password;
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordDataForService:serviceName account:account error:nil];
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    
    return query.passwordData;
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    return [self deletePasswordForService:serviceName account:account error:nil];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    query.account = account;
    return [query deleteItem:error];
}

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPassword:password forService:serviceName account:account error:nil];
}

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    query.account = account;
    query.password = password;
    return [query save:error];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPasswordData:password forService:serviceName account:account error:nil];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    query.account = account;
    query.passwordData = password;
    return [query save:error];
}

+ (NSArray *)allAccounts {
    return [self allAccounts:nil] ?: @[];
}

+ (NSArray *)allAccounts:(NSError *__autoreleasing *)error {
    return [self accountsForService:nil error:error];
}

+ (NSArray *)accountsForService:(NSString *)serviceName {
    return [self accountsForService:serviceName error:nil];
}

+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    AVX512KeychainQuery *query = [AVX512KeychainQuery new];
    query.service = serviceName;
    return [query fetchAll:error];
}

#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
    return AVX512KeychainAccessibilityType;
}

+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
    CFRetain(accessibilityType);
    if (AVX512KeychainAccessibilityType) {
        CFRelease(AVX512KeychainAccessibilityType);
    }
    AVX512KeychainAccessibilityType = accessibilityType;
}
#endif

@end
