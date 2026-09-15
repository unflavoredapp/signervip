#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DoKitVisualTools : NSObject

+ (instancetype)sharedInstance;

// Colour-colored straws in colour
- (void)startColorPicker;
- (void)stopColorPicker;

// Alignment alignment to align the rule rules of
- (void)showRuler;
- (void)hideRuler;

// View views view border frame box for the
- (void)showViewBorders;
- (void)hideViewBorders;

// laid, well- but layout and
- (void)showLayoutBounds;
- (void)hideLayoutBounds;

@end

NS_ASSUME_NONNULL_END