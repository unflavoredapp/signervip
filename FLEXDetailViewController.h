#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DetailViewController : UIViewController

/// To be sent to the data objects object (You can be a array of clusters, dictions dictionary or other object)
@property (nonatomic, strong) id data;

@end

NS_ASSUME_NONNULL_END