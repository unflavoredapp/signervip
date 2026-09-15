#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVX512LookinMeasureState) {
    AVX512LookinMeasureState_no,        // No in range spacing mode pattern modes model distance-
    AVX512LookinMeasureState_unlocked,  // Distance range mode in distance spacing pattern, but not locked without locking
    AVX512LookinMeasureState_locked     // In range spacing mode at ranging distance, and lock-locking in
};

@interface AVX512LookinMeasureController : NSObject

@property (nonatomic, assign) AVX512LookinMeasureState measureState;
@property (nonatomic, weak) UIView *mainView;
@property (nonatomic, weak) UIView *referenceView;

+ (instancetype)sharedInstance;

// Measurement control controls to measure the measurement
- (void)startMeasuring;
- (void)stopMeasuring;
- (void)lockMeasuring:(BOOL)locked;

@end

NS_ASSUME_NONNULL_END