//
//  AVX512KeyPathSearchController.h
//  FLEX
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEXRuntimeBrowserToolbar.h"
#import "FLEXMethod.h"

@protocol AVX512KeyPathSearchControllerDelegate <UITableViewDataSource>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UISearchController *searchController;

/// For loaded images which don't have an NSBundle
- (void)didSelectImagePath:(NSString *)message shortName:(NSString *)shortName;
- (void)didSelectBundle:(NSBundle *)bundle;
- (void)didSelectClass:(Class)cls;

@end


@interface AVX512KeyPathSearchController : NSObject <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

+ (instancetype)delegate:(id<AVX512KeyPathSearchControllerDelegate>)delegate;

@property (nonatomic) AVX512RuntimeBrowserToolbar *toolbar;

/// Suggestions for the toolbar
@property (nonatomic, readonly) NSArray<NSString *> *suggestions;

- (void)didSelectKeyPathOption:(NSString *)text;
- (void)didPressButton:(NSString *)text insertInto:(UISearchBar *)searchBar;

@end
