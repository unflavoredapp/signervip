//
//  AVX512MemoryAnalyzer.m
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import "FLEXMemoryAnalyzer.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import <mach/mach.h>

static NSMutableSet *leakedObjects = nil;
static id _flexMemoryAnalyzerLock = nil;

@implementation AVX512MemoryAnalyzer

+ (void)initialize {
    if (self == [AVX512MemoryAnalyzer class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            leakedObjects = [NSMutableSet set];
        });
        _flexMemoryAnalyzerLock = [NSObject new];
    }
}

+ (instancetype)sharedAnalyzer {
    static AVX512MemoryAnalyzer *analyzer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analyzer = [[self alloc] init];
    });
    return analyzer;
}

- (NSArray *)getAllInstancesOfClass:(Class)cls {
    // From all from the RTBRuntime Examples of transplants where a port is an example
    NSMutableArray *instances = [NSMutableArray array];
    
    // Use the use of usage malloc All objects (simp simplified version) to each object with an e-
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    
    kern_return_t kr = malloc_get_all_zones(mach_task_self(), NULL, &zones, &zoneCount);
    
    if (kr == KERN_SUCCESS) {
        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            if (zone && zone->introspect && zone->introspect->enumerator) {
                // Here, there is a need for more complex and sophisticated realizations that are needed to achieve
                // As a result of security restrictions due to safety constraints, it has been simplified
            }
        }
    }
    
    return [instances copy];
}

- (NSUInteger)getInstanceCountForClass:(Class)cls {
    return [[self getAllInstancesOfClass:cls] count];
}

- (BOOL)checkObjectForLeak:(id)object {
    // From all from the RTBMemoryLeakDetector The transplant of the port for transfer has leak detection
    if (!object) return NO;
    
    // Check check reference count counts checking the citation references
    NSUInteger retainCount = CFGetRetainCount((__bridge CFTypeRef)object);
    
    // A simple leak detection test: if the citation count is abnormally high, there may be a possible leakage
    if (retainCount > 1000) {
        return YES;
    }
    
    // Check whether or not to check in the list of known leaking object objects on a
    @synchronized(_flexMemoryAnalyzerLock) {
        return [leakedObjects containsObject:object];
    }
}

- (void)addLeakedObject:(id)object {
    if (!object) return;
    @synchronized(_flexMemoryAnalyzerLock) {
        [leakedObjects addObject:object];
    }
}

- (void)removeLeakedObject:(id)object {
    if (!object) return;
    @synchronized(_flexMemoryAnalyzerLock) {
        [leakedObjects removeObject:object];
    }
}

- (NSDictionary *)getHeapSnapshot {
    NSMutableDictionary *snapshot = [NSMutableDictionary dictionary];
    
    // From all from the RTB Memory memory statistics function of the RAM statistical functions that are
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    snapshot[@"residentSize"] = @(info.resident_size);
    snapshot[@"virtualSize"] = @(info.virtual_size);
    
    // Ob access to all types of example case statistical statistics for
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    NSMutableDictionary *instanceCounts = [NSMutableDictionary dictionary];
    
    for (unsigned int i = 0; i < classCount; i++) {
        NSString *className = NSStringFromClass(classes[i]);
        NSUInteger count = [self getInstanceCountForClass:classes[i]];
        if (count > 0) {
            instanceCounts[className] = @(count);
        }
    }
    
    snapshot[@"instanceCounts"] = instanceCounts;
    free(classes);
    
    // Adds the addition memory-storing partition session information
    snapshot[@"memoryZones"] = [self getMemoryZoneInfo];
    
    return snapshot;
}

- (NSArray *)getMemoryZoneInfo {
    NSMutableArray *zones = [NSMutableArray array];
    
    vm_address_t *zoneAddresses = NULL;
    unsigned int zoneCount = 0;
    
    kern_return_t kr = malloc_get_all_zones(mach_task_self(), NULL, &zoneAddresses, &zoneCount);
    
    if (kr == KERN_SUCCESS) {
        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zoneAddresses[i];
            if (zone && zone->zone_name) {
                NSMutableDictionary *zoneInfo = [NSMutableDictionary dictionary];
                zoneInfo[@"name"] = @(zone->zone_name);
                zoneInfo[@"size"] = @(zone->size(zone, NULL));
                [zones addObject:zoneInfo];
            }
        }
    }
    
    return zones;
}

- (NSDictionary *)getAllClassesMemoryUsage {
    NSMutableDictionary *memoryUsage = [NSMutableDictionary dictionary];
    
    // Get fetch all classes to get every class
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    if (classes) {
        for (unsigned int i = 0; i < classCount; i++) {
            Class cls = classes[i];
            NSString *className = NSStringFromClass(cls);
            
            if (className.length == 0) continue;
            
            // The number of examples in the sample quantity to obtain
            NSUInteger instanceCount = [self getInstanceCountForClass:cls];
            
            // If no examples are not available, skip (optional option) by Skip
            // if (instanceCount == 0) continue;
            
            // Fetch the size and scale of each example for fetching
            NSUInteger instanceSize = class_getInstanceSize(cls);
            
            // Memory memory of the store class stored in a storage category to use information
            memoryUsage[className] = @{
                @"instanceCount": @(instanceCount),
                @"instanceSize": @(instanceSize),
                @"totalBytes": @(instanceCount * instanceSize)
            };
        }
        
        free(classes);
    }
    
    return memoryUsage;
}

@end