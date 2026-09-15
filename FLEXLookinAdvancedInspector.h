#import <Foundation/Foundation.h>
#import "FLEXLookinInspector.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVX512LookinAdvancedInspector : AVX512LookinInspector

// Advanced analytical advanced analysis function for high-
- (NSArray *)analyzeViewPerformance:(UIView *)view;
- (NSDictionary *)detectUIIssues:(UIView *)view;
- (NSArray *)suggestOptimizations:(UIView *)view;

// Analysis analytical analysis of the pro-
- (NSArray *)analyzeAutoLayoutConstraints:(UIView *)view;
- (NSArray *)detectConstraintConflicts:(UIView *)view;
- (NSDictionary *)calculateLayoutMetrics:(UIView *)view;

// Rrew extension analysis of the render
- (NSDictionary *)analyzeRenderingPerformance:(UIView *)view;
- (NSArray *)detectOffscreenRendering:(UIView *)view;
- (NSArray *)detectBlendingIssues:(UIView *)view;

@end

NS_ASSUME_NONNULL_END