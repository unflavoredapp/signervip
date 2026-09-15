//
//  OSCache.h
//
//  It's a version 1.2.1
//
//  By being by and subject Nick Lockwood Created created in creation to create 01/01/2014.
//  All copyrighted rights all of the (C) 2014 Charcoal Design
//
//  On the basis of loosely basedzlibDistribution of licences for the distribution and
//  Get the latest most recent version from here to get:
//
//  https://github.com/nicklockwood/OSCache
//
//  This this software program programme client-"As Original original status as existing,"Provision provided, without providing any express or implied explicit and insin offer
//  Guarantee. In no case is the author ' s use of this software to generate any problem that would result from
//  Any damage is liable for any injury.
//
//  Allow anyone, for any purpose and permit use of this software application is allowed to be
//  Including commercial applications, as well including business application and modification/re-changed or re
//  Subject to the following restrictions, provided that these limitations:
//
//  1. The source of origin from this software application must not be distorted; the
//  Says that you have created the original software. If this is used in your product, use it to produce products if
//  Acknowledgement in the product document will be appreciated, but not necessary.
//
//  2. The modified version of the source-source code from a revised revision to an altered original Source Code copy must be clearly marked
//  It is a lie to call it the original software.
//
//  3. This statement must not be deleted or changed from any source code distribution for circulation. You cannot delete
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSCache <KeyType, ObjectType> : NSCache <NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger totalCost;

- (id)objectForKeyedSubscript:(KeyType <NSCopying>)key;
- (void)setObject:(ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(KeyType key, ObjectType obj, BOOL *stop))block;

@end


@protocol OSCacheDelegate <NSCacheDelegate>
@optional

- (BOOL)cache:(OSCache *)cache shouldEvictObject:(id)entry;
- (void)cache:(OSCache *)cache willEvictObject:(id)entry;

@end

NS_ASSUME_NONNULL_END
