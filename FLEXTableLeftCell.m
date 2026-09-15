//
//  AVX512TableLeftCell.m
//  FLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015Year year and years of f. All rights reserved.
//

#import "FLEXTableLeftCell.h"

@implementation AVX512TableLeftCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"AVX512TableLeftCell";
    AVX512TableLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[AVX512TableLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *textLabel               = [UILabel new];
        textLabel.textAlignment          = NSTextAlignmentCenter;
        textLabel.font                   = [UIFont systemFontOfSize:13.0];
        [cell.contentView addSubview:textLabel];
        cell.titlelabel = textLabel;
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titlelabel.frame = self.contentView.frame;
}
@end
