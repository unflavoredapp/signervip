//
//  PTMultiColumnTableView.h
//  PTMultiColumnTableViewDemo
//
//  Created by Peng Tao on 15/11/16.
//  Copyright © 2015Year year and years of Peng Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEXTableColumnHeader.h"

@class AVX512MultiColumnTableView;

@protocol AVX512MultiColumnTableViewDelegate <NSObject>

@required
- (void)multiColumnTableView:(AVX512MultiColumnTableView *)tableView didSelectRow:(NSInteger)row;
- (void)multiColumnTableView:(AVX512MultiColumnTableView *)tableView didSelectHeaderForColumn:(NSInteger)column sortType:(AVX512TableColumnHeaderSortType)sortType;

@end

@protocol AVX512MultiColumnTableViewDataSource <NSObject>

@required

- (NSInteger)numberOfColumnsInTableView:(AVX512MultiColumnTableView *)tableView;
- (NSInteger)numberOfRowsInTableView:(AVX512MultiColumnTableView *)tableView;
- (NSString *)columnTitle:(NSInteger)column;
- (NSString *)rowTitle:(NSInteger)row;
- (NSArray<NSString *> *)contentForRow:(NSInteger)row;

- (CGFloat)multiColumnTableView:(AVX512MultiColumnTableView *)tableView minWidthForContentCellInColumn:(NSInteger)column;
- (CGFloat)multiColumnTableView:(AVX512MultiColumnTableView *)tableView heightForContentCellInRow:(NSInteger)row;
- (CGFloat)heightForTopHeaderInTableView:(AVX512MultiColumnTableView *)tableView;
- (CGFloat)widthForLeftHeaderInTableView:(AVX512MultiColumnTableView *)tableView;

@end


@interface AVX512MultiColumnTableView : UIView

@property (nonatomic, weak) id<AVX512MultiColumnTableViewDataSource> dataSource;
@property (nonatomic, weak) id<AVX512MultiColumnTableViewDelegate> delegate;

- (void)reloadData;

@end
