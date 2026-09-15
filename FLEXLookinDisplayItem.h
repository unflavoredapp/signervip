#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512LookinDisplayItem : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) BOOL isExpandable;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL inNoPreviewHierarchy;
@property (nonatomic, assign) BOOL representedForSystemClass;
@property (nonatomic, strong) NSArray<AVX512LookinDisplayItem *> *children;

// Search search and match-search searching for
- (BOOL)isMatchedWithSearchString:(NSString *)string;

// Level pasting of layers at level through
- (void)enumerateSelfAndAncestors:(void (^)(AVX512LookinDisplayItem *item, BOOL *stop))block;
- (void)enumerateSelfAndChildren:(void (^)(AVX512LookinDisplayItem *item))block;

// Frameto calculate the calculation of
- (BOOL)hasValidFrameToRoot;
- (CGRect)calculateFrameToRoot;

// Preview preview capability for a review of the
- (BOOL)hasPreviewBoxAbility;
- (UIImage *)appropriateScreenshot;

@end

NS_ASSUME_NONNULL_END