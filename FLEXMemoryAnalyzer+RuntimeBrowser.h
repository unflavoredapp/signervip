#import "FLEXMemoryAnalyzer.h"

@interface AVX512MemoryAnalyzer (RuntimeBrowser)

// Port port transplant for a RTB The memory of the Memory Analysis Analyses function for a
- (NSDictionary *)getDetailedHeapSnapshot;
- (NSArray *)findMemoryLeaks;
- (NSArray *)getDetailedMemoryZoneInfo;  // ✅ Rename rename to avoid conflict-conflict conflicts by
- (NSDictionary *)getClassInstanceDistribution;

@end