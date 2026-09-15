//
//  AVX512MetadataExtras.m
//  FLEX
//
//  Created by Tanner Bennett on 4/26/22.
//

#import "FLEXMetadataExtras.h"

NSString * const AVX512AuxiliarynfoKeyFieldLabels = @"AVX512AuxiliarynfoKeyFieldLabels";

@implementation AVX512MethodBase (Auxiliary)
- (id)auxiliaryInfoForKey:(NSString *)key { return nil; }
@end

@implementation AVX512Property (Auxiliary)
- (id)auxiliaryInfoForKey:(NSString *)key { return nil; }
@end

@implementation AVX512Ivar (Auxiliary)
- (id)auxiliaryInfoForKey:(NSString *)key { return nil; }
@end
