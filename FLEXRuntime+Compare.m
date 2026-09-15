//
//  AVX512Runtime+Compare.m
//  FLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXRuntime+Compare.h"

@implementation AVX512Property (Compare)

- (NSComparisonResult)compare:(AVX512Property *)other {
    NSComparisonResult r = [self.name caseInsensitiveCompare:other.name];
    if (r == NSOrderedSame) {
        // TODO make sure empty image name sorts above an image name
        return [self.imageName ?: @"" compare:other.imageName];
    }

    return r;
}

@end

@implementation AVX512Ivar (Compare)

- (NSComparisonResult)compare:(AVX512Ivar *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation AVX512MethodBase (Compare)

- (NSComparisonResult)compare:(AVX512MethodBase *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation AVX512Protocol (Compare)

- (NSComparisonResult)compare:(AVX512Protocol *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end
