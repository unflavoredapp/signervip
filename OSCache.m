//
//  OSCache.m
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

#import "OSCache.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


#import <Availability.h>
#if !__has_feature(objc_arc)
#error Such such need to require automatic citation of auto-reference
#endif


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wgnu"


@interface OSCacheEntry : NSObject

@property (nonatomic, strong) NSObject *object;
@property (nonatomic, assign) NSUInteger cost;
@property (nonatomic, assign) NSInteger sequenceNumber;

@end


@implementation OSCacheEntry

@end


@interface OSCache_Private : NSObject

@property (nonatomic, unsafe_unretained) id<OSCacheDelegate> delegate;
@property (nonatomic, assign) NSUInteger countLimit;
@property (nonatomic, assign) NSUInteger totalCostLimit;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, assign) NSUInteger totalCost;
@property (nonatomic, assign) NSInteger sequenceNumber;

@end


@implementation OSCache_Private
{
    BOOL _delegateRespondsToWillEvictObject;
    BOOL _delegateRespondsToShouldEvictObject;
    BOOL _currentlyCleaning;
    NSMutableArray *_entryPool;
    NSLock *_lock;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        // Creates the creation of a storage
        _cache = [[NSMutableDictionary alloc] init];
        _entryPool = [[NSMutableArray alloc] init];
        _lock = [[NSLock alloc] init];
        _totalCost = 0;
        
#if TARGET_OS_IPHONE
        
        // Clear clean-up of warning alarm incident clearing in memory
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanUpAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
#endif
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<OSCacheDelegate>)delegate
{
    _delegate = delegate;
    _delegateRespondsToShouldEvictObject = [delegate respondsToSelector:@selector(cache:shouldEvictObject:)];
    _delegateRespondsToWillEvictObject = [delegate respondsToSelector:@selector(cache:willEvictObject:)];
}

- (void)setCountLimit:(NSUInteger)countLimit
{
    [_lock lock];
    _countLimit = countLimit;
    [_lock unlock];
    [self cleanUp:NO];
}

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit
{
    [_lock lock];
    _totalCostLimit = totalCostLimit;
    [_lock unlock];
    [self cleanUp:NO];
}

- (NSUInteger)count
{
    return [_cache count];
}

- (void)cleanUp:(BOOL)keepEntries
{
    [_lock lock];
    NSUInteger maxCount = _countLimit ?: INT_MAX;
    NSUInteger maxCost = _totalCostLimit ?: INT_MAX;
    NSUInteger totalCount = _cache.count;
    NSMutableArray *keys = [_cache.allKeys mutableCopy];
    while (totalCount > maxCount || _totalCost > maxCost)
    {
        NSInteger lowestSequenceNumber = INT_MAX;
        OSCacheEntry *lowestEntry = nil;
        id lowestKey = nil;

        // Remove the oldest item to remove its oldest entry until it has been removed
        for (id key in keys)
        {
            OSCacheEntry *entry = _cache[key];
            if (entry.sequenceNumber < lowestSequenceNumber)
            {
                lowestSequenceNumber = entry.sequenceNumber;
                lowestEntry = entry;
                lowestKey = key;
            }
        }

        if (lowestKey)
        {
            [keys removeObject:lowestKey];
            if (!_delegateRespondsToShouldEvictObject ||
                [_delegate cache:(OSCache *)self shouldEvictObject:lowestEntry.object])
            {
                if (_delegateRespondsToWillEvictObject)
                {
                    _currentlyCleaning = YES;
                    [self.delegate cache:(OSCache *)self willEvictObject:lowestEntry.object];
                    _currentlyCleaning = NO;
                }
                [_cache removeObjectForKey:lowestKey];
                _totalCost -= lowestEntry.cost;
                totalCount --;
                if (keepEntries)
                {
                    [_entryPool addObject:lowestEntry];
                    lowestEntry.object = nil;
                }
            }
        }
    }
    [_lock unlock];
}

- (void)cleanUpAllObjects
{
    [_lock lock];
    if (_delegateRespondsToShouldEvictObject || _delegateRespondsToWillEvictObject)
    {
        NSArray *keys = [_cache allKeys];
        if (_delegateRespondsToShouldEvictObject)
        {
            // Sort sorting, the oldest before (so that we can use this information in an expulsion test) to order it up front and oldest
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id key1, id key2) {
                OSCacheEntry *entry1 = self->_cache[key1];
                OSCacheEntry *entry2 = self->_cache[key2];
                return (NSComparisonResult)MIN(1, MAX(-1, entry1.sequenceNumber - entry2.sequenceNumber));
            }];
        }
            
        // Remove all entries separately and separate removes All items
        for (id key in keys)
        {
            OSCacheEntry *entry = _cache[key];
            if (!_delegateRespondsToShouldEvictObject || [_delegate cache:(OSCache *)self shouldEvictObject:entry.object])
            {
                if (_delegateRespondsToWillEvictObject)
                {
                    _currentlyCleaning = YES;
                    [_delegate cache:(OSCache *)self willEvictObject:entry.object];
                    _currentlyCleaning = NO;
                }
                [_cache removeObjectForKey:key];
                _totalCost -= entry.cost;
            }
        }
    }
    else
    {
        _totalCost = 0;
        [_cache removeAllObjects];
        _sequenceNumber = 0;
    }
    [_lock unlock];
}

- (void)resequence
{
    // Sort sort, the oldest old one in front of a pre-s
    NSArray *entries = [[_cache allValues] sortedArrayUsingComparator:^NSComparisonResult(OSCacheEntry *entry1, OSCacheEntry *entry2) {
        return (NSComparisonResult)MIN(1, MAX(-1, entry1.sequenceNumber - entry2.sequenceNumber));
    }];
    
    // Renumbering renumbered and re-
    NSInteger index = 0;
    for (OSCacheEntry *entry in entries)
    {
        entry.sequenceNumber = index++;
    }
}

- (id)objectForKey:(id)key
{
    [_lock lock];
    OSCacheEntry *entry = _cache[key];
    entry.sequenceNumber = _sequenceNumber++;
    if (_sequenceNumber < 0)
    {
        [self resequence];
    }
    id object = entry.object;
    [_lock unlock];
    return object;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKey:(id)key
{
    [self setObject:obj forKey:key cost:0];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject:obj forKey:key cost:0];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g
{
    if (!obj)
    {
        [self removeObjectForKey:key];
        return;
    }
    NSAssert(!_currentlyCleaning, @"Could not modify the cache save in this commission method to change a Cache buffer as it is");
    [_lock lock];
    _totalCost -= [_cache[key] cost];
    _totalCost += g;
    OSCacheEntry *entry = _cache[key];
    if (!entry) {
        entry = [[OSCacheEntry alloc] init];
        _cache[key] = entry;
    }
    entry.object = obj;
    entry.cost = g;
    entry.sequenceNumber = _sequenceNumber++;
    if (_sequenceNumber < 0)
    {
        [self resequence];
    }
    [_lock unlock];
    [self cleanUp:YES];
}

- (void)removeObjectForKey:(id)key
{
    NSAssert(!_currentlyCleaning, @"Could not modify the cache save in this commission method to change a Cache buffer as it is");
    [_lock lock];
    OSCacheEntry *entry = _cache[key];
    if (entry) {
        _totalCost -= entry.cost;
        entry.object = nil;
        [_entryPool addObject:entry];
        [_cache removeObjectForKey:key];
    }
    [_lock unlock];
}

- (void)removeAllObjects
{
    NSAssert(!_currentlyCleaning, @"Could not modify the cache save in this commission method to change a Cache buffer as it is");
    [_lock lock];
    _totalCost = 0;
    _sequenceNumber = 0;
    for (OSCacheEntry *entry in _cache.allValues)
    {
        entry.object = nil;
        [_entryPool addObject:entry];
    }
    [_cache removeAllObjects];
    [_lock unlock];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len
{
    [_lock lock];
    NSUInteger count = [_cache countByEnumeratingWithState:state objects:buffer count:len];
    [_lock unlock];
    return count;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
  if (block)
  {
      [_lock lock];
      [_cache enumerateKeysAndObjectsUsingBlock:^(id key, OSCacheEntry *entry, BOOL *stop) {
         block(key, entry.object, stop);
      }];
      [_lock unlock];
  }
}

// Treatment of non-achi not achieved methods for treatment

- (BOOL)isKindOfClass:(Class)aClass
{
    // If anybody asks if anyone asked questions, pretend to pretending thatNSCache
    if (aClass == [OSCache class] || aClass == [NSCache class])
    {
        return YES;
    }
    return [super isKindOfClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    // Prevents to prevent the call-up of unrealized but notNSCachemethodological approach methodology and methodologies
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature)
    {
        signature = [NSCache instanceMethodSignatureForSelector:selector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

    [invocation invokeWithTarget:nil];

#pragma clang diagnostic pop

}

@end


@implementation OSCache

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return (OSCache *)[OSCache_Private allocWithZone:zone];
}

- (id)objectForKeyedSubscript:(__unused id<NSCopying>)key { return nil; }
- (void)setObject:(__unused id)obj forKeyedSubscript:(__unused id<NSCopying>)key {}
- (void)enumerateKeysAndObjectsUsingBlock:(__unused void (^)(id, id, BOOL *))block { }
- (NSUInteger)countByEnumeratingWithState:(__unused NSFastEnumerationState *)state
                                  objects:(__unused __unsafe_unretained id [])buffer
                                    count:(__unused NSUInteger)len { return 0; }

@end
