#import "FLEXSystemAnalyzerViewController+RuntimeBrowser.h"
#import "FLEXRuntimeClient+RuntimeBrowser.h"
#import "FLEXMemoryAnalyzer+RuntimeBrowser.h"
#import "FLEXHookDetector+RuntimeBrowser.h"

@implementation AVX512SystemAnalyzerViewController (RuntimeBrowser)

- (NSDictionary *)getAdvancedSystemAnalysis {
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    // Run-R running time runtime analysis
    AVX512RuntimeClient *runtime = [AVX512RuntimeClient runtime];
    analysis[@"runtime"] = @{
        @"totalClasses": @([[runtime sortedClassStubs] count]),
        @"rootClasses": @([[runtime rootClasses] count]),
        @"classHierarchy": [self getClassHierarchyTree]
    };
    
    // Memory pars memory analysis for RAM
    AVX512MemoryAnalyzer *memoryAnalyzer = [AVX512MemoryAnalyzer sharedAnalyzer];
    analysis[@"memory"] = [memoryAnalyzer getDetailedHeapSnapshot];
    
    // Hook Analysis analysis and analytical analyses
    AVX512HookDetector *hookDetector = [AVX512HookDetector sharedDetector];
    analysis[@"hooks"] = [hookDetector getDetailedHookAnalysis];
    
    // Bundle Analysis analysis and analytical analyses
    analysis[@"bundles"] = [self getBundleAnalysis];
    
    // Frame framework information for frame-frame
    analysis[@"frameworks"] = [self getLoadedFrameworksInfo];
    
    return analysis;
}

- (NSArray *)getLoadedFrameworksInfo {
    NSMutableArray *frameworks = [NSMutableArray array];
    
    unsigned int imageCount = 0;
    const char **imageNames = objc_copyImageNames(&imageCount);
    
    if (imageNames) {
        for (unsigned int i = 0; i < imageCount; i++) {
            NSString *imagePath = @(imageNames[i]);
            
            // Fetch framework information access to frame-frame
            NSDictionary *info = [self analyzeFrameworkAtPath:imagePath];
            if (info) {
                [frameworks addObject:info];
            }
        }
        
        free(imageNames);
    }
    
    return frameworks;
}

- (NSDictionary *)analyzeFrameworkAtPath:(NSString *)path {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    info[@"path"] = path;
    info[@"name"] = [path lastPathComponent];
    
    // Get a class of the kind in this mirror to get an
    unsigned int classCount = 0;
    const char **classNames = objc_copyClassNamesForImage(path.UTF8String, &classCount);
    
    if (classNames) {
        NSMutableArray *classes = [NSMutableArray array];
        for (unsigned int i = 0; i < classCount; i++) {
            [classes addObject:@(classNames[i])];
        }
        
        info[@"classes"] = classes;
        info[@"classCount"] = @(classCount);
        
        free(classNames);
    }
    
    // Fetch File Size size to fetch the file
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (attributes) {
        info[@"fileSize"] = attributes[NSFileSize];
    }
    
    return info;
}

- (NSDictionary *)getBundleAnalysis {
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    // For the Lord and Bundle Information InfoInfo information
    NSBundle *mainBundle = [NSBundle mainBundle];
    analysis[@"mainBundle"] = @{
        @"bundleIdentifier": mainBundle.bundleIdentifier ?: @"unknown",
        @"version": mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"unknown",
        @"build": mainBundle.infoDictionary[@"CFBundleVersion"] ?: @"unknown",
        @"path": mainBundle.bundlePath
    };
    
    // Loaded and loaded load-load Bundle
    NSMutableArray *loadedBundles = [NSMutableArray array];
    for (NSBundle *bundle in [NSBundle allBundles]) {
        [loadedBundles addObject:@{
            @"identifier": bundle.bundleIdentifier ?: @"unknown",
            @"path": bundle.bundlePath,
            @"loaded": @([bundle isLoaded])
        }];
    }
    
    analysis[@"loadedBundles"] = loadedBundles;
    analysis[@"bundleCount"] = @(loadedBundles.count);
    
    return analysis;
}

- (NSArray *)getClassHierarchyTree {
    NSMutableArray *tree = [NSMutableArray array];
    
    AVX512RuntimeClient *runtime = [AVX512RuntimeClient runtime];
    NSArray *rootClasses = [runtime rootClasses];
    
    for (NSString *rootClassName in rootClasses) {
        Class rootClass = NSClassFromString(rootClassName);
        if (rootClass) {
            NSDictionary *node = [self buildClassTreeForClass:rootClass];
            [tree addObject:node];
        }
    }
    
    return tree;
}

- (NSDictionary *)buildClassTreeForClass:(Class)cls {
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    
    node[@"className"] = NSStringFromClass(cls);
    node[@"instanceSize"] = @(class_getInstanceSize(cls));
    
    // Get to fetch the sub-sub class
    NSMutableArray *subclasses = [NSMutableArray array];
    
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class currentClass = classes[i];
        if (class_getSuperclass(currentClass) == cls) {
            NSDictionary *subnode = [self buildClassTreeForClass:currentClass];
            [subclasses addObject:subnode];
        }
    }
    
    free(classes);
    
    if (subclasses.count > 0) {
        node[@"subclasses"] = subclasses;
    }
    
    return node;
}

@end