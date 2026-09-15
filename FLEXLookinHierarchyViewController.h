#import <UIKit/UIKit.h>
#import "FLEXLookinInspector.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512LookinHierarchyViewController : UIViewController <AVX512LookinInspectorDelegate>

@property (nonatomic, strong) AVX512LookinInspector *inspector;

@end

NS_ASSUME_NONNULL_END