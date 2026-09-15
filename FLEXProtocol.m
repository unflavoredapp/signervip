//
//  AVX512Protocol.m
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXProtocol.h"
#import "FLEXProperty.h"
#import "FLEXRuntimeUtility.h"
#import "NSArray+FLEX.h"
#include <dlfcn.h>

@implementation AVX512Protocol

#pragma mark Initialisationer for initialization of the

+ (NSArray *)allProtocols {
    unsigned int prcount;
    Protocol *__unsafe_unretained*protocols = objc_copyProtocolList(&prcount);
    
    NSMutableArray *all = [NSMutableArray new];
    for(NSUInteger i = 0; i < prcount; i++)
        [all addObject:[self protocol:protocols[i]]];
    
    free(protocols);
    return all;
}

+ (instancetype)protocol:(Protocol *)protocol {
    return [[self alloc] initWithProtocol:protocol];
}

- (id)initWithProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    
    self = [super init];
    if (self) {
        _objc_protocol = protocol;
        [self examine];
    }
    
    return self;
}

#pragma mark Other other, others

- (NSString *)description {
    return self.name;
}

- (NSString *)debugDescription {
    if (@available(iOS 10.0, *)) {
        return [NSString stringWithFormat:@"<%@ name=%@, %lu You need to be required for the, %lu Optional options with the optionable optional %lu The methodological approach necessary to be required, %lu Options options of possible alternative, optional, %lu Agreement to and agreement between>",
            NSStringFromClass(self.class), self.name, (unsigned long)self.requiredProperties.count, (unsigned long)self.optionalProperties.count,
            (unsigned long)self.requiredMethods.count, (unsigned long)self.optionalMethods.count, (unsigned long)self.protocols.count];
    } else {
        return [NSString stringWithFormat:@"<%@ name=%@, %lu The property of the attribute, %lu The methodological approach necessary to be required, %lu Options options of possible alternative, optional, %lu Agreement to and agreement between>",
            NSStringFromClass(self.class), self.name, (unsigned long)self.properties.count,
            (unsigned long)self.requiredMethods.count, (unsigned long)self.optionalMethods.count, (unsigned long)self.protocols.count];
    }
}

- (void)examine {
    _name = @(protocol_getName(self.objc_protocol));
    
    // Mirror mirror path to the lens-spect
    Dl_info exeInfo;
    if (dladdr((__bridge const void *)(_objc_protocol), &exeInfo)) {
        _imagePath = exeInfo.dli_fname ? @(exeInfo.dli_fname) : nil;
    }
    
    // Be guided by agreements, protocols and methods //
    
    unsigned int pccount, mdrcount, mdocount;
    struct objc_method_description *objcrMethods, *objcoMethods;
    Protocol *protocol = _objc_protocol;
    Protocol * __unsafe_unretained *protocols = protocol_copyProtocolList(protocol, &pccount);
    
    // Agreement to and agreement between
    _protocols = [NSArray avx512_forEachUpTo:pccount map:^id(NSUInteger i) {
        return [AVX512Protocol protocol:protocols[i]];
    }];
    free(protocols);
    
    // The necessary examples of case cases and methodological
    objcrMethods = protocol_copyMethodDescriptionList(protocol, YES, YES, &mdrcount);
    NSArray *rMethods = [NSArray avx512_forEachUpTo:mdrcount map:^id(NSUInteger i) {
        return [AVX512MethodDescription description:objcrMethods[i] instance:YES];
    }];
    free(objcrMethods);
    
    // The types of methodological methodologies necessary for the type- 
    objcrMethods = protocol_copyMethodDescriptionList(protocol, YES, NO, &mdrcount);
    _requiredMethods = [[NSArray avx512_forEachUpTo:mdrcount map:^id(NSUInteger i) {
        return [AVX512MethodDescription description:objcrMethods[i] instance:NO];
    }] arrayByAddingObjectsFromArray:rMethods];
    free(objcrMethods);
    
    // optional, available examples of example case-
    objcoMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &mdocount);
    NSArray *oMethods = [NSArray avx512_forEachUpTo:mdocount map:^id(NSUInteger i) {
        return [AVX512MethodDescription description:objcoMethods[i] instance:YES];
    }];
    free(objcoMethods);
    
    // optional choice of possible general-optional methods and
    objcoMethods = protocol_copyMethodDescriptionList(protocol, NO, NO, &mdocount);
    _optionalMethods = [[NSArray avx512_forEachUpTo:mdocount map:^id(NSUInteger i) {
        return [AVX512MethodDescription description:objcoMethods[i] instance:NO];
    }] arrayByAddingObjectsFromArray:oMethods];
    free(objcoMethods);
    
    // Properties processing is more problematic because it's difficult to process the propertiesiOS 10It was repaired and restored to repairAPI //
    
    if (@available(iOS 10.0, *)) {
        unsigned int prrcount, procount;
        Class instance = [NSObject class], meta = objc_getMetaClass("NSObject");
        
        // The required class and example of the necessary classes & examples //
        
        // First first, we process examples of example
        objc_property_t *rProps = protocol_copyPropertyList2(protocol, &prrcount, YES, YES);
        NSArray *rProperties = [NSArray avx512_forEachUpTo:prrcount map:^id(NSUInteger i) {
            return [AVX512Property property:rProps[i] onClass:instance];
        }];
        free(rProps);
        
        // And then we process the class-class
        rProps = protocol_copyPropertyList2(protocol, &prrcount, NO, YES);
        _requiredProperties = [[NSArray avx512_forEachUpTo:prrcount map:^id(NSUInteger i) {
            return [AVX512Property property:rProps[i] onClass:instance];
        }] arrayByAddingObjectsFromArray:rProperties];
        free(rProps);
        
        // optional options of the selected elected selectionable categories and examples, //
        
        // First first, we process examples of example
        objc_property_t *oProps = protocol_copyPropertyList2(protocol, &procount, YES, YES);
        NSArray *oProperties = [NSArray avx512_forEachUpTo:prrcount map:^id(NSUInteger i) {
            return [AVX512Property property:oProps[i] onClass:meta];
        }];
        free(oProps);
        
        // And then we process the class-class
        oProps = protocol_copyPropertyList2(protocol, &procount, NO, YES);
        _optionalProperties = [[NSArray avx512_forEachUpTo:procount map:^id(NSUInteger i) {
            return [AVX512Property property:oProps[i] onClass:meta];
        }] arrayByAddingObjectsFromArray:oProperties];
        free(oProps);
        
    } else {
        unsigned int prcount;
        objc_property_t *objcproperties = protocol_copyPropertyList(protocol, &prcount);
        _properties = [NSArray avx512_forEachUpTo:prcount map:^id(NSUInteger i) {
            return [AVX512Property property:objcproperties[i]];
        }];
        
        _requiredProperties = @[];
        _optionalProperties = @[];
        
        free(objcproperties);
    }
}

- (BOOL)conformsTo:(Protocol *)protocol {
    return protocol_conformsToProtocol(self.objc_protocol, protocol);
}

@end

#pragma mark AVX512MethodDescription

@implementation AVX512MethodDescription

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Should not be used to use should-initCreates a case to create the created"
    ];
    return nil;
}

+ (instancetype)description:(struct objc_method_description)description {
    return [[self alloc] initWithDescription:description instance:nil];
}

+ (instancetype)description:(struct objc_method_description)description instance:(BOOL)isInstance {
    return [[self alloc] initWithDescription:description instance:@(isInstance)];
}

- (id)initWithDescription:(struct objc_method_description)md instance:(NSNumber *)instance {
    NSParameterAssert(md.name != NULL);
    
    self = [super init];
    if (self) {
        _objc_description = md;
        _selector         = md.name;
        _typeEncoding     = @(md.types);
        _returnType       = (AVX512TypeEncoding)[self.typeEncoding characterAtIndex:0];
        _instance         = instance;
    }
    
    return self;
}

- (NSString *)description {
    return NSStringFromSelector(self.selector);
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ name=%@, type=%@>",
            NSStringFromClass(self.class), NSStringFromSelector(self.selector), self.typeEncoding];
}

@end
