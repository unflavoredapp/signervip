#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVX512LookinViewMode) {
    AVX512LookinViewModeHierarchy = 0,    // Level-level mode of the hierarchical
    AVX512LookinViewMode3D,               // 3DMode mode modes the format
    AVX512LookinViewModeSnapshot,         // Model model-s pattern, snapshot
    AVX512LookinViewModeComparison        // Contra comparison mode-comp compares
};

@protocol AVX512LookinInspectorDelegate <NSObject>
@optional
- (void)lookinInspector:(id)inspector didSelectView:(UIView *)view;
- (void)lookinInspector:(id)inspector didUpdateHierarchy:(NSArray *)hierarchy;
@end

@interface AVX512LookinViewNode : NSObject
@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSArray<AVX512LookinViewNode *> *children;
@property (nonatomic, weak) AVX512LookinViewNode *parent;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CATransform3D transform;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, assign) NSInteger depth;
@end

@interface AVX512LookinInspector : NSObject

@property (nonatomic, weak) id<AVX512LookinInspectorDelegate> delegate;
@property (nonatomic, assign) AVX512LookinViewMode viewMode;
@property (nonatomic, strong, readonly) NSArray<AVX512LookinViewNode *> *viewHierarchy;
@property (nonatomic, weak, readonly) UIView *selectedView;
@property (nonatomic, assign, readonly) BOOL isInspecting;

+ (instancetype)sharedInstance;

// Check check-check controls and control
- (void)startInspecting;
- (void)stopInspecting;

// View view selection option for the views
- (void)selectView:(UIView *)view;
- (void)clearSelection;

// Level-level analytical level analysis of
- (void)refreshViewHierarchy;
- (AVX512LookinViewNode *)nodeForView:(UIView *)view;
- (NSArray<AVX512LookinViewNode *> *)flattenedHierarchy;

// 3DViews view level-level of the View
- (void)show3DViewHierarchy;
- (void)hide3DViewHierarchy;

// A quick-shot, snapshots
- (UIImage *)captureViewSnapshot:(UIView *)view;
- (void)saveHierarchySnapshot:(NSString *)name;
- (NSArray *)loadSavedSnapshots;

// Contras the function to compare functions
- (void)compareWithSnapshot:(NSString *)snapshotName;
- (NSArray *)findChangedViewsBetweenSnapshot:(NSString *)snapshotName;

@end

NS_ASSUME_NONNULL_END