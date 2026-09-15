//
//  AVX512NetworkTransactionCell.h
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVX512NetworkTransaction;

@interface AVX512NetworkTransactionCell : UITableViewCell

@property (nonatomic) AVX512NetworkTransaction *transaction;

@property (nonatomic, readonly, class) NSString *reuseID;
@property (nonatomic, readonly, class) CGFloat preferredCellHeight;

@end
