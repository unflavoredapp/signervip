//
//  AVX512KeychainQuery.m
//  AVX512Keychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013-2014 Sam Soffes. All rights reserved.
//

#import "FLEXKeychainQuery.h"
#import "FLEXKeychain.h"

@implementation AVX512KeychainQuery

#pragma mark - Public methods of public-public method

- (BOOL)save:(NSError *__autoreleasing *)error {
    OSStatus status = AVX512KeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        return NO;
    }
    
    NSMutableDictionary *query = nil;
    NSMutableDictionary * searchQuery = [self query];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (status == errSecSuccess) {//The project already exists and the Project Exists, update it
        query = [[NSMutableDictionary alloc]init];
        query[(__bridge id)kSecValueData] = self.passwordData;
        #if __IPHONE_4_0 && TARGET_OS_IPHONE
        CFTypeRef accessibilityType = AVX512Keychain.accessibilityType;
        if (accessibilityType) {
            query[(__bridge id)kSecAttrAccessible] = (__bridge id)accessibilityType;
        }
        #endif
        status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
    }
    else if (status == errSecItemNotFound){//Project not found, project unfound. Create it!
        query = [self query];
        if (self.label) {
            query[(__bridge id)kSecAttrLabel] = self.label;
        }
        query[(__bridge id)kSecValueData] = self.passwordData;
        #if __IPHONE_4_0 && TARGET_OS_IPHONE
        CFTypeRef accessibilityType = AVX512Keychain.accessibilityType;
        if (accessibilityType) {
            query[(__bridge id)kSecAttrAccessible] = (__bridge id)accessibilityType;
        }
        #endif
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (BOOL)deleteItem:(NSError *__autoreleasing *)error {
    OSStatus status = AVX512KeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        
        return NO;
    }
    
    NSMutableDictionary *query = [self query];
    #if TARGET_OS_IPHONE
    status = SecItemDelete((__bridge CFDictionaryRef)query);
    #else
    // In being in the Mac OS Go on, go up. UpSecItemDelete Keys that are created in different applications, and key keys which have been generated from
    // Nor will you delete keys created in different versions of the same application, or remove key creations that have
    //
    // In order to repeat the question, save passwords and change codes by saving a passphrase. To restore this problem again please
    // And then try to delete the password. Try deleting it
    //
    // There's here in OS X 10.6 This is the case in all and possibly even more advanced versions.
    //
    // Used through the use SecItemCopyMatching and SecKeychainItemDelete Here to solve this problem.
    CFTypeRef result = NULL;
    query[(__bridge id)kSecReturnRef] = @YES;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
    #endif
    
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError *__autoreleasing *)error {
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    #if __IPHONE_4_0 && TARGET_OS_IPHONE
    CFTypeRef accessibilityType = AVX512Keychain.accessibilityType;
    if (accessibilityType) {
        query[(__bridge id)kSecAttrAccessible] = (__bridge id)accessibilityType;
    }
    #endif
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
        *error = [self errorWithCode:status];
        return nil;
    }
    
    return (__bridge_transfer NSArray *)result ?: @[];
}


- (BOOL)fetch:(NSError *__autoreleasing *)error {
    OSStatus status = AVX512KeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        return NO;
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = [self query];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [self errorWithCode:status];
        }
        return NO;
    }
    
    self.passwordData = (__bridge_transfer NSData *)result;
    return YES;
}


#pragma mark - Access access visitors to the Visitor


- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if (self.passwordData.length) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}


#pragma mark - Syn synchronizes the sync Hot-

#ifdef AVX512KEYCHAIN_SYNCHRONIZATION_AVAILABLE
+ (BOOL)isSynchronizationAvailable {
    #if TARGET_OS_IPHONE
    return YES;
    #else
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_8_4;
    #endif
}
#endif


#pragma mark - Private private methods and privately-private

- (NSMutableDictionary *)query {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.service) {
        dictionary[(__bridge id)kSecAttrService] = self.service;
    }
    
    if (self.account) {
        dictionary[(__bridge id)kSecAttrAccount] = self.account;
    }
    
    #ifdef AVX512KEYCHAIN_ACCESS_GROUP_AVAILABLE
    #if !TARGET_IPHONE_SIMULATOR
    if (self.accessGroup) {
        dictionary[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    #endif
    #endif
    
    #ifdef AVX512KEYCHAIN_SYNCHRONIZATION_AVAILABLE
    if ([[self class] isSynchronizationAvailable]) {
        id value;
        
        switch (self.synchronizationMode) {
            case AVX512KeychainQuerySynchronizationModeNo: {
                value = @NO;
                break;
            }
            case AVX512KeychainQuerySynchronizationModeYes: {
                value = @YES;
                break;
            }
            case AVX512KeychainQuerySynchronizationModeAny: {
                value = (__bridge id)(kSecAttrSynchronizableAny);
                break;
            }
        }
        
        dictionary[(__bridge id)(kSecAttrSynchronizable)] = value;
    }
    #endif
    
    return dictionary;
}

- (NSError *)errorWithCode:(OSStatus)code {
    static dispatch_once_t onceToken;
    static NSBundle *resourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"AVX512Keychain" withExtension:@"bundle"];
        resourcesBundle = [NSBundle bundleWithURL:url];
    });
    
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case AVX512KeychainErrorBadArguments: message = NSLocalizedStringFromTableInBundle(@"AVX512KeychainErrorBadArguments", @"AVX512Keychain", resourcesBundle, nil); break;
            
        #if TARGET_OS_IPHONE
        case errSecUnimplemented: {
            message = NSLocalizedStringFromTableInBundle(@"errSecUnimplemented", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecParam: {
            message = NSLocalizedStringFromTableInBundle(@"errSecParam", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecAllocate: {
            message = NSLocalizedStringFromTableInBundle(@"errSecAllocate", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecNotAvailable: {
            message = NSLocalizedStringFromTableInBundle(@"errSecNotAvailable", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecDuplicateItem: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDuplicateItem", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecItemNotFound: {
            message = NSLocalizedStringFromTableInBundle(@"errSecItemNotFound", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecInteractionNotAllowed: {
            message = NSLocalizedStringFromTableInBundle(@"errSecInteractionNotAllowed", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecDecode: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDecode", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        case errSecAuthFailed: {
            message = NSLocalizedStringFromTableInBundle(@"errSecAuthFailed", @"AVX512Keychain", resourcesBundle, nil);
            break;
        }
        default: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDefault", @"AVX512Keychain", resourcesBundle, nil);
        }
        #else
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
        #endif
    }
    
    NSDictionary *userInfo = message ? @{ NSLocalizedDescriptionKey : message } : nil;
    return [NSError errorWithDomain:kAVX512KeychainErrorDomain code:code userInfo:userInfo];
}

@end
