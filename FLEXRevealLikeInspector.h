#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVX512RevealInspectorDelegate <NSObject>
@optional
- (void)revealInspector:(id)inspector didSelectView:(UIView *)view;
- (void)revealInspector:(id)inspector didDeselectView:(UIView *)view;
@end

@interface AVX512RevealLikeInspector : NSObject

@property (nonatomic, weak) id<AVX512RevealInspectorDelegate> delegate;
@property (nonatomic, assign) BOOL isInspecting;
@property (nonatomic, strong, readonly) UIView *selectedView;

+ (instancetype)sharedInstance;

// 3DView view level-level structure of the
- (void)show3DViewHierarchy;
- (void)hide3DViewHierarchy;

// View bound view check on views review of
- (void)showViewConstraints:(UIView *)view;
- (void)hideViewConstraints;

// View view survey measure of the views
- (void)showViewMeasurements:(UIView *)view;
- (void)hideViewMeasurements;

// Real-time real time editing edit
- (void)enableLiveEditing;
- (void)disableLiveEditing;
- (void)modifyView:(UIView *)view properties:(NSDictionary *)properties;
- (void)showLiveEditingPanelForView:(UIView *)view;

// View capture and cross-catch catch & cutshot
- (UIImage *)captureViewHierarchy3D;
- (void)exportViewHierarchyDescription;

@end

NS_ASSUME_NONNULL_END