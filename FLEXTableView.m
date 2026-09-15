//
//  AVX512TableView.m
//  FLEX
//
//  Created by Tanner on 4/17/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXTableView.h"
#import "FLEXUtility.h"
#import "FLEXSubtitleTableViewCell.h"
#import "FLEXMultilineTableViewCell.h"
#import "FLEXKeyValueTableViewCell.h"
#import "FLEXCodeFontCell.h"

AVX512TableViewCellReuseIdentifier const kAVX512DefaultCell = @"kAVX512DefaultCell";
AVX512TableViewCellReuseIdentifier const kAVX512DetailCell = @"kAVX512DetailCell";
AVX512TableViewCellReuseIdentifier const kAVX512MultilineCell = @"kAVX512MultilineCell";
AVX512TableViewCellReuseIdentifier const kAVX512MultilineDetailCell = @"kAVX512MultilineDetailCell";
AVX512TableViewCellReuseIdentifier const kAVX512KeyValueCell = @"kAVX512KeyValueCell";
AVX512TableViewCellReuseIdentifier const kAVX512CodeFontCell = @"kAVX512CodeFontCell";

#pragma mark Private

@interface UITableView (Private)
- (CGFloat)_heightForHeaderInSection:(NSInteger)section;
- (NSString *)_titleForHeaderInSection:(NSInteger)section;
@end

@implementation AVX512TableView

+ (instancetype)flexDefaultTableView {
    if (@available(iOS 13.0, *)) {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
}

#pragma mark - Initialization

+ (id)groupedTableView {
    if (@available(iOS 13.0, *)) {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
}

+ (id)plainTableView {
    return [[self alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

+ (id)style:(UITableViewStyle)style {
    return [[self alloc] initWithFrame:CGRectZero style:style];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerCells:@{
            kAVX512DefaultCell : [AVX512TableViewCell class],
            kAVX512DetailCell : [AVX512SubtitleTableViewCell class],
            kAVX512MultilineCell : [AVX512MultilineTableViewCell class],
            kAVX512MultilineDetailCell : [AVX512MultilineDetailTableViewCell class],
            kAVX512KeyValueCell : [AVX512KeyValueTableViewCell class],
            kAVX512CodeFontCell : [AVX512CodeFontCell class],
        }];
    }

    return self;
}


#pragma mark - Public

- (void)registerCells:(NSDictionary<NSString*, Class> *)registrationMapping {
    [registrationMapping enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, Class cellClass, BOOL *stop) {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }];
}

@end
