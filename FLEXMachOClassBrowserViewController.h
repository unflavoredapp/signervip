#import <UIKit/UIKit.h>
#import "FLEXTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512MachOClassBrowserViewController : AVX512TableViewController

@property (nonatomic, strong) NSArray<NSString *> *classNames;
@property (nonatomic, copy) NSString *imagePath;

@end

NS_ASSUME_NONNULL_END