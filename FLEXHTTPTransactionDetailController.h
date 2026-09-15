//
//  AVX512HTTPTransactionDetailController.h
//  Flipboard
//
//  Created by Ryan Olson on 2/10/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVX512HTTPTransaction;

@interface AVX512HTTPTransactionDetailController : UITableViewController

+ (instancetype)withTransaction:(AVX512HTTPTransaction *)transaction;

@end
