//
//  NSDateFormatter+FLEX.m
//  libflex:FLEX
//
//  Created by Tanner Bennett on 7/24/22.
//  Copyright © 2022 Flipboard. All rights reserved.
//

#import "NSDateFormatter+FLEX.h"

@implementation NSDateFormatter (FLEX)

+ (NSString *)avx512_stringFrom:(NSDate *)date format:(AVX512DateFormat)format {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [NSDateFormatter new];
    }
    
    switch (format) {
        case AVX512DateFormatClock:
            formatter.dateFormat = @"h:mm a";
            break;
        case AVX512DateFormatPreciseClock:
            formatter.dateFormat = @"h:mm:ss a";
            break;
        case AVX512DateFormatVerbose:
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            break;
    }
    
    return [formatter stringFromDate:date];
}

@end
