//
//  AVX512MultilineTableViewCell.h
//  FLEX
//
//  Created by Ryan Olson on 2/13/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableViewCell.h"

/// A cell with both labels set to be multi-line capable.
@interface AVX512MultilineTableViewCell : AVX512TableViewCell

+ (CGFloat)preferredHeightWithAttributedText:(NSAttributedString *)attributedText
                                    maxWidth:(CGFloat)contentViewWidth
                                       style:(UITableViewStyle)style
                              showsAccessory:(BOOL)showsAccessory;

@end

/// A \c AVX512MultilineTableViewCell initialized with \c UITableViewCellStyleSubtitle
@interface AVX512MultilineDetailTableViewCell : AVX512MultilineTableViewCell

@end
