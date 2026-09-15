#import "FLEXRuntimeClient.h"

@interface AVX512RuntimeClient (RuntimeBrowser)

// Port port transplant for a RTBRuntime functional function of the functions and functionality
- (NSMutableDictionary *)allClassStubsByName;
- (NSMutableDictionary *)allClassStubsByImagePath;
- (NSMutableArray *)rootClasses;
- (void)readAllRuntimeClasses;
- (NSArray *)sortedClassStubs;
- (void)emptyCachesAndReadAllRuntimeClasses;

// Port-of the port class analytical analysis function for
- (NSDictionary *)getDetailedClassInfo:(Class)cls;
- (NSString *)generateHeaderForClass:(Class)cls;
- (NSArray *)getAllInstancesOfClass:(Class)cls;
- (NSUInteger)getInstanceCountForClass:(Class)cls;

@end