//
//  AVX512TableLeftCell.h
//  FLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015Year year and years of f. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVX512TableLeftCell : UITableViewCell

@property (nonatomic) UILabel *titlelabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
