//
//  NSMapTable+AVX512_Subscripting.h
//  FLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMapTable<KeyType, ObjectType> (AVX512_Subscripting)

- (nullable ObjectType)objectForKeyedSubscript:(KeyType)key;
- (void)setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
