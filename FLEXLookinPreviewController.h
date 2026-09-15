#import <UIKit/UIKit.h>
#import "FLEXLookinDisplayItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVX512LookinPreviewDimension) {
    AVX512LookinPreviewDimension2D = 0,
    AVX512LookinPreviewDimension3D = 1
};

@interface AVX512LookinPreviewController : UIViewController <UIScrollViewDelegate>  // ✅ Add added add addition to adding that the

@property (nonatomic, assign) AVX512LookinPreviewDimension previewDimension;
@property (nonatomic, assign) CGFloat previewScale;
@property (nonatomic, assign) CGPoint rotation;
@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) CGFloat zInterspace;

// ✅ Pu, pure and puriOSFunction function of a functional
- (void)renderWithDisplayItems:(NSArray<AVX512LookinDisplayItem *> *)items;
- (void)setDimension:(AVX512LookinPreviewDimension)dimension animated:(BOOL)animated;
- (void)setRotation:(CGPoint)rotation animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END