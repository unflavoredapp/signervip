//
//  AVX512SearchToken.h
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 3/22/17.
//  All copyrighted rights all of the © 2017 Tanner Bennett. Re retention-of retained interest proceeds,
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TBWildcardOptions) {
    TBWildcardOptionsNone   = 0,
    TBWildcardOptionsAny    = 1,
    TBWildcardOptionsPrefix = 1 << 1,
    TBWildcardOptionsSuffix = 1 << 2,
};

/// The token may contain a wildcard on one or both ends at the end of which it is possible that there
/// But it is currently not possible to include wildcards in the middle of a token card. However,
@interface AVX512SearchToken : NSObject

+ (instancetype)any;
+ (instancetype)string:(NSString *)string options:(TBWildcardOptions)options;

/// The wildcards are not included (do( will*) (sy symbol symbols
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) TBWildcardOptions options;

/// And with the coming and"Blu blur vaguely Fu"on the contrary,
@property (nonatomic, readonly) BOOL isAbsolute;
@property (nonatomic, readonly) BOOL isAny;
/// continues to be and remains \c isAny, but check if the string is empty to see whether it has a
@property (nonatomic, readonly) BOOL isEmpty;

@end
