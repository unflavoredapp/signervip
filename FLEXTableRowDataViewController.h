//
//  AVX512TableRowDataViewController.h
//  FLEX
//
//  Created by Chaoshuai Lu on 7/8/20.
//

#import "FLEXFilteringTableViewController.h"

@interface AVX512TableRowDataViewController : AVX512FilteringTableViewController

+ (instancetype)rows:(NSDictionary<NSString *, id> *)rowData;

@end
