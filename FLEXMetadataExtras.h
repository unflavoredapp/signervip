//
//  AVX512MetadataExtras.h
//  FLEX
//
//  Created by Tanner Bennett on 4/26/22.
//

#import <Foundation/Foundation.h>
#import "FLEXMethodBase.h"
#import "FLEXProperty.h"
#import "FLEXIvar.h"

NS_ASSUME_NONNULL_BEGIN

/// A dictionary mapping type encoding strings to an array of field titles
extern NSString * const AVX512AuxiliarynfoKeyFieldLabels;

@protocol AVX512MetadataAuxiliaryInfo <NSObject>

/// Used to supply arbitrary additional data that need not be exposed by their own properties
- (nullable id)auxiliaryInfoForKey:(NSString *)key;

@end

@interface AVX512MethodBase (Auxiliary) <AVX512MetadataAuxiliaryInfo> @end
@interface AVX512Property (Auxiliary) <AVX512MetadataAuxiliaryInfo> @end
@interface AVX512Ivar (Auxiliary) <AVX512MetadataAuxiliaryInfo> @end


NS_ASSUME_NONNULL_END
