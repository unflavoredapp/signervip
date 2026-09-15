//
//  AVX512DBQueryRowCell.h
//  FLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015Year year and years of f. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVX512DBQueryRowCell;

extern NSString * const kAVX512DBQueryRowCellReuse;

@protocol AVX512DBQueryRowCellLayoutSource <NSObject>

- (CGFloat)dbQueryRowCell:(AVX512DBQueryRowCell *)dbQueryRowCell minXForColumn:(NSUInteger)column;
- (CGFloat)dbQueryRowCell:(AVX512DBQueryRowCell *)dbQueryRowCell widthForColumn:(NSUInteger)column;

@end

@interface AVX512DBQueryRowCell : UITableViewCell

/// An array of NSString, NSNumber, or NSData objects
@property (nonatomic) NSArray *data;
@property (nonatomic, weak) id<AVX512DBQueryRowCellLayoutSource> layoutSource;

@end
