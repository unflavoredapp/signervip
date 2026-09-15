//
//  AVX512Runtime+Compare.h
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLEXProperty.h"
#import "FLEXIvar.h"
#import "FLEXMethodBase.h"
#import "FLEXProtocol.h"

@interface AVX512Property (Compare)
- (NSComparisonResult)compare:(AVX512Property *)other;
@end

@interface AVX512Ivar (Compare)
- (NSComparisonResult)compare:(AVX512Ivar *)other;
@end

@interface AVX512MethodBase (Compare)
- (NSComparisonResult)compare:(AVX512MethodBase *)other;
@end

@interface AVX512Protocol (Compare)
- (NSComparisonResult)compare:(AVX512Protocol *)other;
@end
