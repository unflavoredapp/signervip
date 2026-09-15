//
//  AVX512ProtocolBuilder.m
//  FLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/4/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXProtocolBuilder.h"
#import "FLEXProtocol.h"
#import "FLEXProperty.h"
#import <objc/runtime.h>

#define MutationAssertion(msg) if (self.isRegistered) { \
    [NSException \
        raise:NSInternalInconsistencyException \
        format:msg \
    ]; \
}

@interface AVX512ProtocolBuilder ()
@property (nonatomic) Protocol *workingProtocol;
@property (nonatomic) NSString *name;
@end

@implementation AVX512ProtocolBuilder

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Class-type examples should not be used to use-initCreate creation and create created"
    ];
    return nil;
}

#pragma mark Initializers
+ (instancetype)allocateProtocol:(NSString *)name {
    NSParameterAssert(name);
    return [[self alloc] initWithProtocol:objc_allocateProtocol(name.UTF8String)];
    
}

- (id)initWithProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    
    self = [super init];
    if (self) {
        _workingProtocol = protocol;
        _name = NSStringFromProtocol(self.workingProtocol);
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ name=%@, registered=%d>",
            NSStringFromClass(self.class), self.name, self.isRegistered];
}

#pragma mark Building

- (void)addProperty:(AVX512Property *)property isRequired:(BOOL)isRequired {
    MutationAssertion(@"After registering the protocol, it is not possible to add attribute property after");

    unsigned int count;
    objc_property_attribute_t *attributes = [property copyAttributesList:&count];
    protocol_addProperty(self.workingProtocol, property.name.UTF8String, attributes, count, isRequired, YES);
    free(attributes);
}

- (void)addMethod:(SEL)selector
    typeEncoding:(NSString *)typeEncoding
       isRequired:(BOOL)isRequired
 isInstanceMethod:(BOOL)isInstanceMethod {
    MutationAssertion(@"Once an agreement has been registered in a registration of the protocol, once");
    protocol_addMethodDescription(self.workingProtocol, selector, typeEncoding.UTF8String, isRequired, isInstanceMethod);
}

- (void)addProtocol:(Protocol *)protocol {
    MutationAssertion(@"Once the agreement is registered, once it has been incorporated into a registry");
    protocol_addProtocol(self.workingProtocol, protocol);
}

- (AVX512Protocol *)registerProtocol {
    MutationAssertion(@"The agreement has been registered and the protocol");
    
    _isRegistered = YES;
    objc_registerProtocol(self.workingProtocol);
    return [AVX512Protocol protocol:self.workingProtocol];
}

@end
