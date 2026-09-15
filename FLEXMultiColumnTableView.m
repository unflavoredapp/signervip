//
//  PTMultiColumnTableView.m
//  PTMultiColumnTableViewDemo
//
//  Created by Peng Tao on 15/11/16.
//  Copyright © 2015Year year and years of Peng Tao. All rights reserved.
//

#import "FLEXMultiColumnTableView.h"
#import "FLEXDBQueryRowCell.h"
#import "FLEXTableLeftCell.h"
#import "NSArray+FLEX.h"
#import "FLEXColor.h"

@interface AVX512MultiColumnTableView () <
    UITableViewDataSource, UITableViewDelegate,
    UIScrollViewDelegate, AVX512DBQueryRowCellLayoutSource
>

@property (nonatomic) UIScrollView *contentScrollView;
@property (nonatomic) UIScrollView *headerScrollView;
@property (nonatomic) UITableView  *leftTableView;
@property (nonatomic) UITableView  *contentTableView;
@property (nonatomic) UIView       *leftHeader;

@property (nonatomic) NSArray<UIView *> *headerViews;

/// If there are no rows if not \c NSNotFound
@property (nonatomic) NSInteger sortColumn;
@property (nonatomic) AVX512TableColumnHeaderSortType sortType;

@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (nonatomic, readonly) NSInteger numberOfRows;
@property (nonatomic, readonly) CGFloat topHeaderHeight;
@property (nonatomic, readonly) CGFloat leftHeaderWidth;
@property (nonatomic, readonly) CGFloat columnMargin;

@end

static const CGFloat kColumnMargin = 1;

@implementation AVX512MultiColumnTableView

#pragma mark - Initial initialisation to start-in

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
        self.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
        self.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor  = AVX512Color.groupedBackgroundColor;
        
        [self loadHeaderScrollView];
        [self loadContentScrollView];
        [self loadLeftView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat topheaderHeight = self.topHeaderHeight;
    CGFloat leftHeaderWidth = self.leftHeaderWidth;
    CGFloat topInsets = 0.f;

    if (@available (iOS 11.0, *)) {
        topInsets = self.safeAreaInsets.top;
    }
    
    CGFloat contentWidth = 0.0;
    NSInteger columnsCount = self.numberOfColumns;
    for (int i = 0; i < columnsCount; i++) {
        contentWidth += CGRectGetWidth(self.headerViews[i].bounds);
    }
    
    CGFloat contentHeight = height - topheaderHeight - topInsets;
    
    self.leftHeader.frame = CGRectMake(0, topInsets, self.leftHeaderWidth, self.topHeaderHeight);
    self.leftTableView.frame = CGRectMake(
        0, topheaderHeight + topInsets, leftHeaderWidth, contentHeight
    );
    self.headerScrollView.frame = CGRectMake(
        leftHeaderWidth, topInsets, width - leftHeaderWidth, topheaderHeight
    );
    self.headerScrollView.contentSize = CGSizeMake(
        self.contentTableView.frame.size.width, self.headerScrollView.frame.size.height
    );
    self.contentTableView.frame = CGRectMake(
        0, 0, contentWidth + self.numberOfColumns * self.columnMargin , contentHeight
    );
    self.contentScrollView.frame = CGRectMake(
        leftHeaderWidth, topheaderHeight + topInsets, width - leftHeaderWidth, contentHeight
    );
    self.contentScrollView.contentSize = self.contentTableView.frame.size;
}


#pragma mark - User GUI user interface on-user

- (void)loadHeaderScrollView {
    UIScrollView *headerScrollView   = [UIScrollView new];
    headerScrollView.delegate        = self;
    headerScrollView.backgroundColor = AVX512Color.secondaryGroupedBackgroundColor;
    self.headerScrollView            = headerScrollView;
    
    [self addSubview:headerScrollView];
}

- (void)loadContentScrollView {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.bounces       = NO;
    scrollView.delegate      = self;
    
    UITableView *tableView   = [UITableView new];
    tableView.delegate       = self;
    tableView.dataSource     = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[AVX512DBQueryRowCell class]
        forCellReuseIdentifier:kAVX512DBQueryRowCellReuse
    ];
    
    [scrollView addSubview:tableView];
    [self addSubview:scrollView];
    
    self.contentScrollView = scrollView;
    self.contentTableView  = tableView;
}

- (void)loadLeftView {
    UITableView *leftTableView   = [UITableView new];
    leftTableView.delegate       = self;
    leftTableView.dataSource     = self;
    leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.leftTableView           = leftTableView;
    [self addSubview:leftTableView];
    
    UIView *leftHeader         = [UIView new];
    leftHeader.backgroundColor = AVX512Color.secondaryBackgroundColor;
    self.leftHeader            = leftHeader;
    [self addSubview:leftHeader];
}


#pragma mark - The data of the Data

- (void)reloadData {
    [self loadHeaderData];
    [self loadLeftViewData];
    [self loadContentData];
}

- (void)loadHeaderData {
    // Remove the existing available current head-head view (if if any) removal of an
    for (UIView *subview in self.headerViews) {
        [subview removeFromSuperview];
    }
    
    __block CGFloat xOffset = 0;
    
    self.headerViews = [NSArray avx512_forEachUpTo:self.numberOfColumns map:^id(NSUInteger column) {
        AVX512TableColumnHeader *header = [AVX512TableColumnHeader new];
        header.titleLabel.text = [self columnTitle:column];
        
        CGSize fittingSize = CGSizeMake(CGFLOAT_MAX, self.topHeaderHeight - 1);
        CGFloat width = self.columnMargin + MAX(
            [self minContentWidthForColumn:column],
            [header sizeThatFits:fittingSize].width
        );
        header.frame = CGRectMake(xOffset, 0, width, self.topHeaderHeight - 1);

        if (column == self.sortColumn) {
            header.sortType = self.sortType;
        }
        
        // Head-head click the head clicking on a hand gesture
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(contentHeaderTap:)
        ];
        [header addGestureRecognizer:gesture];
        header.userInteractionEnabled = YES;
        
        xOffset += width;
        [self.headerScrollView addSubview:header];
        return header;
    }];
}

- (void)contentHeaderTap:(UIGestureRecognizer *)gesture {
    NSInteger newSortColumn = [self.headerViews indexOfObject:gesture.view];
    AVX512TableColumnHeaderSortType newType = AVX512NextTableColumnHeaderSortType(self.sortType);
    
    // Resets the old used older head-head topcap view
    AVX512TableColumnHeader *oldHeader = (id)self.headerViews[self.sortColumn];
    oldHeader.sortType = AVX512TableColumnHeaderSortTypeNone;
    
    // Update New new head Headhead view update to the updated
    AVX512TableColumnHeader *newHeader = (id)self.headerViews[newSortColumn];
    newHeader.sortType = newType;
    
    // Updates itself to update its own
    self.sortColumn = newSortColumn;
    self.sortType = newType;

    // Notification to the agent- agency,
    [self.delegate multiColumnTableView:self didSelectHeaderForColumn:newSortColumn sortType:newType];
}

- (void)loadContentData {
    [self.contentTableView reloadData];
}

- (void)loadLeftViewData {
    [self.leftTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Alternating background back-back color colours for
    UIColor *backgroundColor = AVX512Color.primaryBackgroundColor;
    if (indexPath.row % 2 != 0) {
        backgroundColor = AVX512Color.secondaryBackgroundColor;
    }
    
    // Left left table view of the tables to use a page number line numbers
    if (tableView == self.leftTableView) {
        AVX512TableLeftCell *cell = [AVX512TableLeftCell cellWithTableView:tableView];
        cell.contentView.backgroundColor = backgroundColor;
        cell.titlelabel.text = [self rowTitle:indexPath.row];
        return cell;
    }
    // Right right side table tables viewing of the star-right
    else {
        AVX512DBQueryRowCell *cell = [tableView
            dequeueReusableCellWithIdentifier:kAVX512DBQueryRowCellReuse forIndexPath:indexPath
        ];
        
        cell.contentView.backgroundColor = backgroundColor;
        cell.data = [self.dataSource contentForRow:indexPath.row];
        cell.layoutSource = self;
        NSAssert(cell.data.count == self.numberOfColumns, @"The data provided were not correctly correct in the wrong or incorrect");
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInTableView:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource multiColumnTableView:self heightForContentCellInRow:indexPath.row];
}

// Synchroniss sync Hot-S synchronize scroll all rolling view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        self.headerScrollView.contentOffset = scrollView.contentOffset;
    }
    else if (scrollView == self.headerScrollView) {
        self.contentScrollView.contentOffset = scrollView.contentOffset;
    }
    else if (scrollView == self.leftTableView) {
        self.contentTableView.contentOffset = scrollView.contentOffset;
    }
    else if (scrollView == self.contentTableView) {
        self.leftTableView.contentOffset = scrollView.contentOffset;
    }
}


#pragma mark UITableView Acting acting agent/agent

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        [self.contentTableView
            selectRowAtIndexPath:indexPath
            animated:NO
            scrollPosition:UITableViewScrollPositionNone
        ];
    }
    else if (tableView == self.contentTableView) {
        [self.delegate multiColumnTableView:self didSelectRow:indexPath.row];
    }
}


#pragma mark AVX512DBQueryRowCellLayoutSource

- (CGFloat)dbQueryRowCell:(AVX512DBQueryRowCell *)dbQueryRowCell minXForColumn:(NSUInteger)column {
    return CGRectGetMinX(self.headerViews[column].frame);
}

- (CGFloat)dbQueryRowCell:(AVX512DBQueryRowCell *)dbQueryRowCell widthForColumn:(NSUInteger)column {
    return CGRectGetWidth(self.headerViews[column].bounds);
}


#pragma mark Data source from data sources access to the database Source

- (NSInteger)numberOfRows {
    return [self.dataSource numberOfRowsInTableView:self];
}

- (NSInteger)numberOfColumns {
    return [self.dataSource numberOfColumnsInTableView:self];
}

- (NSString *)columnTitle:(NSInteger)column {
    return [self.dataSource columnTitle:column];
}

- (NSString *)rowTitle:(NSInteger)row {
    return [self.dataSource rowTitle:row];
}

- (CGFloat)minContentWidthForColumn:(NSInteger)column {
    return [self.dataSource multiColumnTableView:self minWidthForContentCellInColumn:column];
}

- (CGFloat)contentHeightForRow:(NSInteger)row {
    return [self.dataSource multiColumnTableView:self heightForContentCellInRow:row];
}

- (CGFloat)topHeaderHeight {
    return [self.dataSource heightForTopHeaderInTableView:self];
}

- (CGFloat)leftHeaderWidth {
    return [self.dataSource widthForLeftHeaderInTableView:self];
}

- (CGFloat)columnMargin {
    return kColumnMargin;
}

@end
