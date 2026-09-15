//
//  AVX512SystemLogCell.h
//  FLEX
//
//  Created by Ryan Olson on 1/25/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableViewCell.h"

@class AVX512SystemLogMessage;

extern NSString *const kAVX512SystemLogCellIdentifier;

@interface AVX512SystemLogCell : AVX512TableViewCell

@property (nonatomic) AVX512SystemLogMessage *logMessage;
@property (nonatomic, copy) NSString *highlightedText;

+ (NSString *)displayedTextForLogMessage:(AVX512SystemLogMessage *)logMessage;
+ (CGFloat)preferredHeightForLogMessage:(AVX512SystemLogMessage *)logMessage inWidth:(CGFloat)width;

@end
