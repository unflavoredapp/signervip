//
//  NSObject+AVX512_Reflection.m
//  FLEX
//
//  It's derived from derivative- MirrorKit... . ...-
//  By being by and subject Tanner Created created in creation to create 6/30/15... . ...-
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "NSObject+FLEX_Reflection.h"
#import "FLEXClassBuilder.h"
#import "FLEXMirror.h"
#import "FLEXProperty.h"
#import "FLEXMethod.h"
#import "FLEXIvar.h"
#import "FLEXProtocol.h"
#import "FLEXPropertyAttributes.h"
#import "NSArray+FLEX.h"
#import "FLEXUtility.h"


NSString * AVX512TypeEncodingString(const char *returnType, NSUInteger count, ...) {
    if (!returnType) return nil;
    
    NSMutableString *encoding = [NSMutableString new];
    [encoding appendFormat:@"%s%s%s", returnType, @encode(id), @encode(SEL)];
    
    va_list args;
    va_start(args, count);
    char *type = va_arg(args, char *);
    for (NSUInteger i = 0; i < count; i++, type = va_arg(args, char *)) {
        [encoding appendFormat:@"%s", type];
    }
    va_end(args);
    
    return encoding.copy;
}

NSArray<Class> *AVX512GetAllSubclasses(Class cls, BOOL includeSelf) {
    if (!cls) return nil;
    
    Class *buffer = NULL;
    
    int count, size;
    do {
        count  = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size   = objc_getClassList(buffer, count);
    } while (size != count);
    
    NSMutableArray *classes = [NSMutableArray new];
    if (includeSelf) {
        [classes addObject:cls];
    }
    
    for (int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while ((superclass = class_getSuperclass(superclass))) {
            if (superclass == cls) {
                [classes addObject:candidate];
                break;
            }
        }
    }
    
    free(buffer);
    return classes.copy;
}

NSArray<Class> *AVX512GetClassHierarchy(Class cls, BOOL includeSelf) {
    if (!cls) return nil;
    
    NSMutableArray *classes = [NSMutableArray new];
    if (includeSelf) {
        [classes addObject:cls];
    }
    
    while ((cls = [cls superclass])) {
        [classes addObject:cls];
    };

    return classes.copy;
}

NSArray<AVX512Protocol *> *AVX512GetConformedProtocols(Class cls) {
    if (!cls) return nil;
    
    unsigned int count = 0;
    Protocol *__unsafe_unretained *list = class_copyProtocolList(cls, &count);
    NSArray<Protocol *> *protocols = [NSArray arrayWithObjects:list count:count];
    free(list);
    
    return [protocols avx512_mapped:^id(Protocol *pro, NSUInteger idx) {
        return [AVX512Protocol protocol:pro];
    }];
}

NSArray<AVX512Ivar *> *AVX512GetAllIvars(_Nullable Class cls) {
    if (!cls) return nil;
    
    unsigned int ivcount;
    Ivar *objcivars = class_copyIvarList(cls, &ivcount);
    NSArray *ivars = [NSArray avx512_forEachUpTo:ivcount map:^id(NSUInteger i) {
        return [AVX512Ivar ivar:objcivars[i]];
    }];

    free(objcivars);
    return ivars;
}

NSArray<AVX512Property *> *AVX512GetAllProperties(_Nullable Class cls) {
    if (!cls) return nil;
    
    unsigned int pcount;
    objc_property_t *objcproperties = class_copyPropertyList(cls, &pcount);
    NSArray *properties = [NSArray avx512_forEachUpTo:pcount map:^id(NSUInteger i) {
        return [AVX512Property property:objcproperties[i] onClass:cls];
    }];

    free(objcproperties);
    return properties;
}

NSArray<AVX512Method *> *AVX512GetAllMethods(_Nullable Class cls, BOOL instance) {
    if (!cls) return nil;

    unsigned int mcount;
    Method *objcmethods = class_copyMethodList(cls, &mcount);
    NSArray *methods = [NSArray avx512_forEachUpTo:mcount map:^id(NSUInteger i) {
        return [AVX512Method method:objcmethods[i] isInstanceMethod:instance];
    }];
    
    free(objcmethods);
    return methods;
}


#pragma mark NSProxy

@interface NSProxy (AnyObjectAdditions) @end
@implementation NSProxy (AnyObjectAdditions)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    // We need all the ways we have to access this document and add any methods of obtaining NSProxy... . ...-
    // To that end, we need the categories themselves and their components; for this
    // Edit: Adds them to the edit that they are added Swift._SwiftObject
    Class NSProxyClass = [NSProxy class];
    Class NSProxy_meta = object_getClass(NSProxyClass);
    Class SwiftObjectClass = (
        NSClassFromString(@"SwiftObject") ?: NSClassFromString(@"Swift._SwiftObject")
    );
    
    // From all from the NSObject Copy All copy all copies to duplicate "avx512_" The method of starting at the beginning
    id filterFunc = ^BOOL(AVX512Method *method, NSUInteger idx) {
        return [method.name hasPrefix:@"avx512_"];
    };
    NSArray *instanceMethods = [NSObject.avx512_allInstanceMethods avx512_filtered:filterFunc];
    NSArray *classMethods = [NSObject.avx512_allClassMethods avx512_filtered:filterFunc];
    
    AVX512ClassBuilder *proxy     = [AVX512ClassBuilder builderForClass:NSProxyClass];
    AVX512ClassBuilder *proxyMeta = [AVX512ClassBuilder builderForClass:NSProxy_meta];
    [proxy addMethods:instanceMethods];
    [proxyMeta addMethods:classMethods];
    
    if (SwiftObjectClass) {
        Class SwiftObject_meta = object_getClass(SwiftObjectClass);
        AVX512ClassBuilder *swiftObject = [AVX512ClassBuilder builderForClass:SwiftObjectClass];
        AVX512ClassBuilder *swiftObjectMeta = [AVX512ClassBuilder builderForClass:SwiftObject_meta];
        [swiftObject addMethods:instanceMethods];
        [swiftObjectMeta addMethods:classMethods];
        
        // So that we can then and will be Swift Object to the object placed into a dictionary in your diction...
        [swiftObjectMeta addMethods:@[
            [NSObject avx512_classMethodNamed:@"copyWithZone:"]]
        ];
    }
}

@end

#pragma mark Reflected reflection reflecte-re

@implementation NSObject (Reflection)

+ (AVX512Mirror *)avx512_reflection {
    return [AVX512Mirror reflect:self];
}

- (AVX512Mirror *)avx512_reflection {
    return [AVX512Mirror reflect:self];
}

/// The code draws lessons from the source- Mike Ash The whole of all the MAObjCRuntime
+ (NSArray *)avx512_allSubclasses {
    return AVX512GetAllSubclasses(self, YES);
}

- (Class)avx512_setClass:(Class)cls {
    return object_setClass(self, cls);
}

+ (Class)avx512_metaclass {
    return objc_getMetaClass(NSStringFromClass(self.class).UTF8String);
}

+ (size_t)avx512_instanceSize {
    return class_getInstanceSize(self.class);
}

+ (Class)avx512_setSuperclass:(Class)superclass {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return class_setSuperclass(self, superclass);
    #pragma clang diagnostic pop
}

+ (NSArray<Class> *)avx512_classHierarchy {
    return AVX512GetClassHierarchy(self, YES);
}

+ (NSArray<AVX512Protocol *> *)avx512_protocols {
    return AVX512GetConformedProtocols(self);
}

@end


#pragma mark methodological approach methodology and methodologies

@implementation NSObject (Methods)

+ (NSArray<AVX512Method *> *)avx512_allMethods {
    NSMutableArray *instanceMethods = self.avx512_allInstanceMethods.mutableCopy;
    [instanceMethods addObjectsFromArray:self.avx512_allClassMethods];
    return instanceMethods;
}

+ (NSArray<AVX512Method *> *)avx512_allInstanceMethods {
    return AVX512GetAllMethods(self, YES);
}

+ (NSArray<AVX512Method *> *)avx512_allClassMethods {
    return AVX512GetAllMethods(self.avx512_metaclass, NO) ?: @[];
}

+ (AVX512Method *)avx512_methodNamed:(NSString *)name {
    Method m = class_getInstanceMethod([self class], NSSelectorFromString(name));
    if (m == NULL) {
        return nil;
    }

    return [AVX512Method method:m isInstanceMethod:YES];
}

+ (AVX512Method *)avx512_classMethodNamed:(NSString *)name {
    Method m = class_getClassMethod([self class], NSSelectorFromString(name));
    if (m == NULL) {
        return nil;
    }

    return [AVX512Method method:m isInstanceMethod:NO];
}

+ (BOOL)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
   implementation:(IMP)implementaiton
      toInstances:(BOOL)instance {
    return class_addMethod(instance ? self.class : self.avx512_metaclass, selector, implementaiton, typeEncoding.UTF8String);
}

+ (IMP)replaceImplementationOfMethod:(AVX512MethodBase *)method with:(IMP)implementation useInstance:(BOOL)instance {
    return class_replaceMethod(instance ? self.class : self.avx512_metaclass, method.selector, implementation, method.typeEncoding.UTF8String);
}

+ (void)swizzle:(AVX512MethodBase *)original with:(AVX512MethodBase *)other onInstance:(BOOL)instance {
    [self swizzleBySelector:original.selector with:other.selector onInstance:instance];
}

+ (BOOL)swizzleByName:(NSString *)original with:(NSString *)other onInstance:(BOOL)instance {
    SEL originalMethod = NSSelectorFromString(original);
    SEL newMethod      = NSSelectorFromString(other);
    if (originalMethod == 0 || newMethod == 0) {
        return NO;
    }

    [self swizzleBySelector:originalMethod with:newMethod onInstance:instance];
    return YES;
}

+ (void)swizzleBySelector:(SEL)original with:(SEL)other onInstance:(BOOL)instance {
    Class cls = instance ? self.class : self.avx512_metaclass;
    Method originalMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, other);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, other, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end


#pragma mark The example instance case for the examples

@implementation NSObject (Ivars)

+ (NSArray<AVX512Ivar *> *)avx512_allIvars {
    return AVX512GetAllIvars(self);
}

+ (AVX512Ivar *)avx512_ivarNamed:(NSString *)name {
    Ivar i = class_getInstanceVariable([self class], name.UTF8String);
    if (i == NULL) {
        return nil;
    }

    return [AVX512Ivar ivar:i];
}

#pragma mark Get fetch address to get the location
- (void *)avx512_getIvarAddress:(AVX512Ivar *)ivar {
    return (uint8_t *)(__bridge void *)self + ivar.offset;
}

- (void *)avx512_getObjcIvarAddress:(Ivar)ivar {
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

- (void *)avx512_getIvarAddressByName:(NSString *)name {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return 0;
    
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

#pragma mark Sets set settings for setting up an instance-
- (void)avx512_setIvar:(AVX512Ivar *)ivar object:(id)value {
    object_setIvar(self, ivar.objc_ivar, value);
}

- (BOOL)avx512_setIvarByName:(NSString *)name object:(id)value {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    object_setIvar(self, ivar, value);
    return YES;
}

- (void)avx512_setObjcIvar:(Ivar)ivar object:(id)value {
    object_setIvar(self, ivar, value);
}

#pragma mark Sets to set setting settings for the you-
- (void)avx512_setIvar:(AVX512Ivar *)ivar value:(void *)value size:(size_t)size {
    void *address = [self avx512_getIvarAddress:ivar];
    memcpy(address, value, size);
}

- (BOOL)avx512_setIvarByName:(NSString *)name value:(void *)value size:(size_t)size {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    [self avx512_setObjcIvar:ivar value:value size:size];
    return YES;
}

- (void)avx512_setObjcIvar:(Ivar)ivar value:(void *)value size:(size_t)size {
    void *address = [self avx512_getObjcIvarAddress:ivar];
    memcpy(address, value, size);
}

@end


#pragma mark The property of the attribute

@implementation NSObject (Properties)

+ (NSArray<AVX512Property *> *)avx512_allProperties {
    NSMutableArray *instanceProperties = self.avx512_allInstanceProperties.mutableCopy;
    [instanceProperties addObjectsFromArray:self.avx512_allClassProperties];
    return instanceProperties;
}

+ (NSArray<AVX512Property *> *)avx512_allInstanceProperties {
    return AVX512GetAllProperties(self);
}

+ (NSArray<AVX512Property *> *)avx512_allClassProperties {
    return AVX512GetAllProperties(self.avx512_metaclass) ?: @[];
}

+ (AVX512Property *)avx512_propertyNamed:(NSString *)name {
    objc_property_t p = class_getProperty([self class], name.UTF8String);
    if (p == NULL) {
        return nil;
    }

    return [AVX512Property property:p onClass:self];
}

+ (AVX512Property *)avx512_classPropertyNamed:(NSString *)name {
    objc_property_t p = class_getProperty(object_getClass(self), name.UTF8String);
    if (p == NULL) {
        return nil;
    }

    return [AVX512Property property:p onClass:object_getClass(self)];
}

+ (void)avx512_replaceProperty:(AVX512Property *)property {
    [self avx512_replaceProperty:property.name attributes:property.attributes];
}

+ (void)avx512_replaceProperty:(NSString *)name attributes:(AVX512PropertyAttributes *)attributes {
    unsigned int count;
    objc_property_attribute_t *objc_attributes = [attributes copyAttributesList:&count];
    class_replaceProperty([self class], name.UTF8String, objc_attributes, count);
    free(objc_attributes);
}

@end


