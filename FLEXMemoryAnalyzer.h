//
//  AVX512MemoryAnalyzer.h
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512MemoryAnalyzer : NSObject

+ (instancetype)sharedAnalyzer;

// Get all examples of each instance in the capture class
- (NSArray *)getAllInstancesOfClass:(Class)cls;

// The number of examples in the sample quantity to obtain
- (NSUInteger)getInstanceCountForClass:(Class)cls;

// RAM memory snapshotshot of a cache-in
- (NSDictionary *)getHeapSnapshot;

// Get all classes of RAM use usage to capture memory uses for any
- (NSDictionary *)getAllClassesMemoryUsage;

@end

NS_ASSUME_NONNULL_END