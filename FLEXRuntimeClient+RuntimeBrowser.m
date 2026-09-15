#import "FLEXRuntimeClient+RuntimeBrowser.h"
#import "FLEXHookDetector.h"
#import <objc/runtime.h>
#import <mach/mach.h>
#import <malloc/malloc.h>

@implementation AVX512RuntimeClient (RuntimeBrowser)

- (NSMutableDictionary *)allClassStubsByName {
    static NSMutableDictionary *_allClassStubsByName = nil;
    if (!_allClassStubsByName) {
        _allClassStubsByName = [NSMutableDictionary dictionary];
        [self readAllRuntimeClasses];
    }
    return _allClassStubsByName;
}

- (NSMutableDictionary *)allClassStubsByImagePath {
    static NSMutableDictionary *_allClassStubsByImagePath = nil;
    if (!_allClassStubsByImagePath) {
        _allClassStubsByImagePath = [NSMutableDictionary dictionary];
        [self readAllRuntimeClasses];
    }
    return _allClassStubsByImagePath;
}

- (NSMutableArray *)rootClasses {
    static NSMutableArray *_rootClasses = nil;
    if (!_rootClasses) {
        _rootClasses = [NSMutableArray array];
        [self readAllRuntimeClasses];
    }
    return _rootClasses;
}

- (void)readAllRuntimeClasses {
    // Allows the group to read-read a class reading
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    NSMutableDictionary *classByName = [self allClassStubsByName];
    NSMutableDictionary *classByPath = [self allClassStubsByImagePath];
    NSMutableArray *roots = [self rootClasses];
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = classes[i];
        NSString *className = NSStringFromClass(cls);
        
        if (className) {
            classByName[className] = className;
            
            // To get the mirror image path of a lensed view-path to
            const char *imageName = class_getImageName(cls);
            if (imageName) {
                NSString *imagePath = @(imageName);
                NSMutableArray *classesInImage = classByPath[imagePath];
                if (!classesInImage) {
                    classesInImage = [NSMutableArray array];
                    classByPath[imagePath] = classesInImage;
                }
                [classesInImage addObject:className];
            }
            
            // Check whether to check if the root class is a Root
            if (!class_getSuperclass(cls)) {
                if (![roots containsObject:className]) {
                    [roots addObject:className];
                }
            }
        }
    }
    
    free(classes);
}

// Repair repair and restoration repairsmallocThe e-ims to name function calls for the
static void range_recorder(unsigned int task, void *context, unsigned int type, vm_range_t *ranges, unsigned int count) {
    NSMutableArray *instances = (__bridge NSMutableArray *)context;
    Class targetClass = objc_getAssociatedObject(instances, @selector(targetClass));
    
    for (unsigned int j = 0; j < count; j++) {
        vm_range_t range = ranges[j];
        void *ptr = (void *)range.address;
        
        @try {
            if (ptr && malloc_size(ptr) > 0) {
                id obj = (__bridge id)ptr;
                if ([obj isKindOfClass:targetClass]) {
                    [instances addObject:obj];
                }
            }
        } @catch (NSException *exception) {
            // Ignores ignoring to ignore the invalid
        }
    }
}

- (NSArray *)getAllInstancesOfClass:(Class)cls {
    NSMutableArray *instances = [NSMutableArray array];
    
    // Links the target class to an object category associated with a result array of outcomes in order that you associate your goal group
    objc_setAssociatedObject(instances, @selector(targetClass), cls, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Use the use of usage malloc In each object to all objects in the e-
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    
    kern_return_t kr = malloc_get_all_zones(mach_task_self(), NULL, &zones, &zoneCount);
    
    if (kr == KERN_SUCCESS) {
        for (unsigned int i = 0; i < zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            if (zone && zone->introspect && zone->introspect->enumerator) {
                @try {
                    // Use the function functions's pointer to use ablock
                    zone->introspect->enumerator(mach_task_self(), (__bridge void *)instances, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, NULL, range_recorder);
                } @catch (NSException *exception) {
                    // Ignores the e-inaction error to ignore
                }
            }
        }
    }
    
    // Clears the clean-up of associated
    objc_setAssociatedObject(instances, @selector(targetClass), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return instances;
}

- (BOOL)isValidObjcObject:(void *)ptr {
    if (!ptr) return NO;
    
    @try {
        id obj = (__bridge id)ptr;
        return [obj class] != nil;
    } @catch (NSException *exception) {
        return NO;
    }
}

- (NSUInteger)getInstanceCountForClass:(Class)cls {
    return [[self getAllInstancesOfClass:cls] count];
}

- (NSArray *)sortedClassStubs {
    NSArray *allClassNames = [[self allClassStubsByName] allKeys];
    return [allClassNames sortedArrayUsingSelector:@selector(compare:)];
}

- (void)emptyCachesAndReadAllRuntimeClasses {
    // Clear empt empty cache of the buffer Cache
    objc_setAssociatedObject(self, @selector(allClassStubsByName), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(allClassStubsByImagePath), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(rootClasses), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Reread Read read re-reRe
    [self readAllRuntimeClasses];
}

#pragma mark - Add the missing means to add a gap and enable

- (NSDictionary *)getDetailedClassInfo:(Class)cls {
    if (!cls) return @{};
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    // Basic basic information on the basis essential
    info[@"className"] = NSStringFromClass(cls);
    info[@"superclass"] = class_getSuperclass(cls) ? NSStringFromClass(class_getSuperclass(cls)) : @"(none)";
    info[@"instanceSize"] = @(class_getInstanceSize(cls));
    info[@"isMetaClass"] = @(class_isMetaClass(cls));
    
    // Mirror-inforfo mirrored information
    const char *imageName = class_getImageName(cls);
    if (imageName) {
        info[@"imageName"] = @(imageName);
        info[@"shortImageName"] = [self shortNameForImageName:@(imageName)];
    }
    
    // Methodological methodological statistical methodology statistics and methodologies
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    info[@"instanceMethodCount"] = @(methodCount);
    free(methods);
    
    Method *classMethods = class_copyMethodList(object_getClass(cls), &methodCount);
    info[@"classMethodCount"] = @(methodCount);
    free(classMethods);
    
    // Attribute statistical property statistics attribute to the
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    info[@"propertyCount"] = @(propertyCount);
    free(properties);
    
    // Example example examples of instance in the case
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    info[@"ivarCount"] = @(ivarCount);
    free(ivars);
    
    // Agreement of agreement between the statistical statistics
    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained *protocols = class_copyProtocolList(cls, &protocolCount);
    info[@"protocolCount"] = @(protocolCount);
    free(protocols);
    
    // The number of examples in the sample
    info[@"instanceCount"] = @([self getInstanceCountForClass:cls]);
    
    return info;
}

- (NSString *)generateHeaderForClass:(Class)cls {
    if (!cls) return @"";
    
    NSMutableString *header = [NSMutableString string];
    
    // type of declarations, declaration-type
    Class superclass = class_getSuperclass(cls);
    NSString *superclassName = superclass ? NSStringFromClass(superclass) : @"NSObject";
    
    [header appendFormat:@"@interface %@ : %@\n\n", NSStringFromClass(cls), superclassName];
    
    // The example instance case for the examples
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    
    if (ivarCount > 0) {
        [header appendString:@"// Instance Variables\n{\n"];
        for (unsigned int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            const char *ivarType = ivar_getTypeEncoding(ivar);
            
            [header appendFormat:@"    %s %s;\n", ivarType, ivarName];
        }
        [header appendString:@"}\n\n"];
    }
    free(ivars);
    
    // The property of the attribute
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    
    if (propertyCount > 0) {
        [header appendString:@"// Properties\n"];
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            const char *propertyAttributes = property_getAttributes(property);
            
            [header appendFormat:@"@property %s %s;\n", propertyAttributes, propertyName];
        }
        [header appendString:@"\n"];
    }
    free(properties);
    
    // Example example examples of methodological case-
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    if (methodCount > 0) {
        [header appendString:@"// Instance Methods\n"];
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            const char *typeEncoding = method_getTypeEncoding(method);
            
            [header appendFormat:@"- (%s)%s;\n", typeEncoding, sel_getName(selector)];
        }
        [header appendString:@"\n"];
    }
    free(methods);
    
    // Category group of methodological methodologies for categories
    methods = class_copyMethodList(object_getClass(cls), &methodCount);
    
    if (methodCount > 0) {
        [header appendString:@"// Class Methods\n"];
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            const char *typeEncoding = method_getTypeEncoding(method);
            
            [header appendFormat:@"+ (%s)%s;\n", typeEncoding, sel_getName(selector)];
        }
        [header appendString:@"\n"];
    }
    free(methods);
    
    [header appendString:@"@end"];
    
    return header;
}

#pragma mark - Other other practical, applied methodological and

- (NSArray *)dokit_getAllClassesWithPrefix:(NSString *)prefix {
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = classes[i];
        NSString *className = NSStringFromClass(cls);
        
        if (!prefix || [className hasPrefix:prefix]) {
            [result addObject:className];
        }
    }
    
    free(classes);
    return [result sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)dokit_getMethodsForClass:(Class)cls includeHooked:(BOOL)includeHooked {
    if (!cls) return @[];
    
    NSMutableArray *methods = [NSMutableArray array];
    
    // Example example examples of methodological case-
    unsigned int methodCount = 0;
    Method *instanceMethods = class_copyMethodList(cls, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = instanceMethods[i];
        SEL selector = method_getName(method);
        const char *typeEncoding = method_getTypeEncoding(method);
        IMP implementation = method_getImplementation(method);
        
        NSMutableDictionary *methodInfo = [NSMutableDictionary dictionary];
        methodInfo[@"selector"] = NSStringFromSelector(selector);
        methodInfo[@"encoding"] = @(typeEncoding);
        methodInfo[@"isInstanceMethod"] = @YES;
        methodInfo[@"implementation"] = [NSString stringWithFormat:@"%p", implementation];
        
        if (includeHooked) {
            // Use the use of usage AVX512HookDetector To detect to be detected and testedHook
            AVX512HookDetector *detector = [AVX512HookDetector sharedDetector];
            BOOL isHooked = [detector isMethodHooked:method ofClass:cls];
            methodInfo[@"isHooked"] = @(isHooked);
        }
        
        [methods addObject:methodInfo];
    }
    free(instanceMethods);
    
    // Category group of methodological methodologies for categories
    Class metaClass = object_getClass(cls);
    Method *classMethods = class_copyMethodList(metaClass, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = classMethods[i];
        SEL selector = method_getName(method);
        const char *typeEncoding = method_getTypeEncoding(method);
        IMP implementation = method_getImplementation(method);
        
        NSMutableDictionary *methodInfo = [NSMutableDictionary dictionary];
        methodInfo[@"selector"] = NSStringFromSelector(selector);
        methodInfo[@"encoding"] = @(typeEncoding);
        methodInfo[@"isInstanceMethod"] = @NO;
        methodInfo[@"implementation"] = [NSString stringWithFormat:@"%p", implementation];
        
        if (includeHooked) {
            // Use the use of usage AVX512HookDetector To detect to be detected and testedHook
            AVX512HookDetector *detector = [AVX512HookDetector sharedDetector];
            BOOL isHooked = [detector isMethodHooked:method ofClass:metaClass];
            methodInfo[@"isHooked"] = @(isHooked);
        }
        
        [methods addObject:methodInfo];
    }
    free(classMethods);
    
    return methods;
}

- (NSDictionary *)dokit_getClassHierarchyTree {
    NSMutableDictionary *tree = [NSMutableDictionary dictionary];
    
    // Fetch all root classes for fetching every Root class
    NSArray *rootClasses = [self rootClasses];
    
    for (NSString *rootClassName in rootClasses) {
        Class rootClass = NSClassFromString(rootClassName);
        if (rootClass) {
            tree[rootClassName] = [self buildClassTreeForClass:rootClass];
        }
    }
    
    return tree;
}

- (NSDictionary *)buildClassTreeForClass:(Class)cls {
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    
    node[@"className"] = NSStringFromClass(cls);
    node[@"instanceSize"] = @(class_getInstanceSize(cls));
    node[@"methodCount"] = @([[self dokit_getMethodsForClass:cls includeHooked:NO] count]);
    
    // Gets direct Direct sub-sub category to get
    NSMutableArray *subclasses = [NSMutableArray array];
    
    unsigned int classCount = 0;
    Class *allClasses = objc_copyClassList(&classCount);
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class currentClass = allClasses[i];
        if (class_getSuperclass(currentClass) == cls) {
            [subclasses addObject:[self buildClassTreeForClass:currentClass]];
        }
    }
    
    free(allClasses);
    
    if (subclasses.count > 0) {
        node[@"subclasses"] = subclasses;
    }
    
    return node;
}

- (NSUInteger)dokit_getInstanceCountForClass:(Class)cls {
    return [[self dokit_getAllInstancesOfClass:cls] count];
}

- (NSArray *)dokit_getAllInstancesOfClass:(Class)cls {
    return [self getAllInstancesOfClass:cls];
}

// Fix to restore the second Second E-action function call calls for a
static void range_recorder_heap(unsigned int task, void *context, unsigned int type, vm_range_t *ranges, unsigned int count) {
    NSMutableArray *results = (__bridge NSMutableArray *)context;
    Class targetClass = objc_getAssociatedObject(results, @selector(targetClass));
    
    for (unsigned int j = 0; j < count; j++) {
        vm_range_t range = ranges[j];
        void *ptr = (void *)range.address;
        
        @try {
            if (ptr && malloc_size(ptr) > 0) {
                id obj = (__bridge id)ptr;
                if ([obj isKindOfClass:targetClass]) {
                    [results addObject:obj];
                }
            }
        } @catch (NSException *exception) {
            // Ignores ignoring to ignore the invalid
        }
    }
}

- (void)enumerateObjectsInZone:(malloc_zone_t *)zone forClass:(Class)targetClass results:(NSMutableArray *)results {
    objc_setAssociatedObject(results, @selector(targetClass), targetClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    @try {
        // Use the function functions's pointer to use ablock
        zone->introspect->enumerator(mach_task_self(), (__bridge void *)results, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, NULL, range_recorder_heap);
    } @catch (NSException *exception) {
        // Ignores the e-inaction error to ignore
    }
    
    objc_setAssociatedObject(results, @selector(targetClass), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)avx512_getHeapSnapshot {
    NSMutableDictionary *snapshot = [NSMutableDictionary dictionary];
    
    // Basic base-based memory information for basic RAM
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    snapshot[@"residentSize"] = @(info.resident_size);
    snapshot[@"virtualSize"] = @(info.virtual_size);
    snapshot[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    
    // Examples of case-specific examples for statistical
    NSMutableDictionary *classStats = [NSMutableDictionary dictionary];
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    
    for (unsigned int i = 0; i < classCount; i++) {
        Class cls = classes[i];
        NSString *className = NSStringFromClass(cls);
        NSUInteger instanceCount = [self getInstanceCountForClass:cls];
        
        if (instanceCount > 0) {
            classStats[className] = @{
                @"count": @(instanceCount),
                @"size": @(class_getInstanceSize(cls))
            };
        }
    }
    
    free(classes);
    snapshot[@"classStatistics"] = classStats;
    
    return snapshot;
}

@end