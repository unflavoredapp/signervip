//
//  AVX512Keychain.h
//
//  Derived from:
//  SSKeychain.h in SSKeychain
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Error code specific to AVX512Keychain that can be returned in NSError objects.
/// For codes returned by the operating system, refer to SecBase.h for your
/// platform.
typedef NS_ENUM(OSStatus, AVX512KeychainErrorCode) {
    /// Some of the arguments were invalid.
    AVX512KeychainErrorBadArguments = -1001,
};

/// AVX512Keychain error domain
extern NSString *const kAVX512KeychainErrorDomain;

/// Account name.
extern NSString *const kAVX512KeychainAccountKey;

/// Time the item was created.
///
/// The value will be a string.
extern NSString *const kAVX512KeychainCreatedAtKey;

/// Item class.
extern NSString *const kAVX512KeychainClassKey;

/// Item description.
extern NSString *const kAVX512KeychainDescriptionKey;

/// Item group.
extern NSString *const kAVX512KeychainGroupKey;

/// Item label.
extern NSString *const kAVX512KeychainLabelKey;

/// Time the item was last modified.
///
/// The value will be a string.
extern NSString *const kAVX512KeychainLastModifiedKey;

/// Where the item was created.
extern NSString *const kAVX512KeychainWhereKey;

/// A simple wrapper for accessing accounts, getting passwords,
/// setting passwords, and deleting passwords using the system Keychain.
@interface AVX512Keychain : NSObject

#pragma mark - Classic methods

/// @param serviceName The service for which to return the corresponding password.
/// @param account The account for which to return the corresponding password.
/// @return Returns a string containing the password for a given account and service,
/// or `nil` if the Keychain doesn't have a password for the given parameters.
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

/// Returns a nsdata containing the password for a given account and service,
/// or `nil` if the Keychain doesn't have a password for the given parameters.
///
/// @param serviceName The service for which to return the corresponding password.
/// @param account The account for which to return the corresponding password.
/// @return Returns a nsdata containing the password for a given account and service,
/// or `nil` if the Keychain doesn't have a password for the given parameters.
+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account;
+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;


/// Deletes a password from the Keychain.
///
/// @param serviceName The service for which to delete the corresponding password.
/// @param account The account for which to delete the corresponding password.
/// @return Returns `YES` on success, or `NO` on failure.
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;


/// Sets a password in the Keychain.
///
/// @param password The password to store in the Keychain.
/// @param serviceName The service for which to set the corresponding password.
/// @param account The account for which to set the corresponding password.
/// @return Returns `YES` on success, or `NO` on failure.
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

/// Sets a password in the Keychain.
///
/// @param password The password to store in the Keychain.
/// @param serviceName The service for which to set the corresponding password.
/// @param account The account for which to set the corresponding password.
/// @return Returns `YES` on success, or `NO` on failure.
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;

/// @return An array of dictionaries containing the Keychain's accounts, or `nil` if
/// the Keychain doesn't have any accounts. The order of the objects in the array isn't defined.
///
/// @note See the `NSString` constants declared in AVX512Keychain.h for a list of keys that
/// can be used when accessing the dictionaries returned by this method.
+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts;
+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts:(NSError *__autoreleasing *)error;

/// @param serviceName The service for which to return the corresponding accounts.
/// @return An array of dictionaries containing the Keychain's accounts for a given `serviceName`,
/// or `nil` if the Keychain doesn't have any accounts for the given `serviceName`.
/// The order of the objects in the array isn't defined.
///
/// @note See the `NSString` constants declared in AVX512Keychain.h for a list of keys that
/// can be used when accessing the dictionaries returned by this method.
+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString *)serviceName;
+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error;


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/// Returns the accessibility type for all future passwords saved to the Keychain.
///
/// @return `NULL` or one of the "Keychain Item Accessibility
/// Constants" used for determining when a keychain item should be readable.
+ (CFTypeRef)accessibilityType;

/// Sets the accessibility type for all future passwords saved to the Keychain.
///
/// @param accessibilityType One of the "Keychain Item Accessibility Constants"
/// used for determining when a keychain item should be readable.
/// If the value is `NULL` (the default), the Keychain default will be used which
/// is highly insecure. You really should use at least `kSecAttrAccessibleAfterFirstUnlock`
/// for background applications or `kSecAttrAccessibleWhenUnlocked` for all
/// other applications.
///
/// @note See Security/SecItem.h
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@end

