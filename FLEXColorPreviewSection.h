//
//  AVX512ColorPreviewSection.h
//  FLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXSingleRowSection.h"
#import "FLEXObjectInfoSection.h"

@interface AVX512ColorPreviewSection : AVX512SingleRowSection <AVX512ObjectInfoSection>

+ (instancetype)forObject:(UIColor *)color;

@end
