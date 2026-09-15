//
//  AVX512TableContentHeaderCell.h
//  FLEX
//
//  Created by Peng Tao on 15/11/26.
//  Copyright © 2015Year year and years of f. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AVX512TableColumnHeaderSortType) {
    AVX512TableColumnHeaderSortTypeNone = 0,
    AVX512TableColumnHeaderSortTypeAsc,
    AVX512TableColumnHeaderSortTypeDesc,
};

NS_INLINE AVX512TableColumnHeaderSortType AVX512NextTableColumnHeaderSortType(
    AVX512TableColumnHeaderSortType current) {
    switch (current) {
        case AVX512TableColumnHeaderSortTypeAsc:
            return AVX512TableColumnHeaderSortTypeDesc;
        case AVX512TableColumnHeaderSortTypeNone:
        case AVX512TableColumnHeaderSortTypeDesc:
            return AVX512TableColumnHeaderSortTypeAsc;
    }
    
    return AVX512TableColumnHeaderSortTypeNone;
}

@interface AVX512TableColumnHeader : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic) AVX512TableColumnHeaderSortType sortType;

@end

