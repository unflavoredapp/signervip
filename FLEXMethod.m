//
//  AVX512Method.m
//  FLEX
//
//  from the source of origin MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXMethod.h"
#import "FLEXMirror.h"
#import "FLEXTypeEncodingParser.h"
#import "FLEXRuntimeUtility.h"
#include <dlfcn.h>

@implementation AVX512Method
@synthesize imagePath = _imagePath;
@dynamic implementation;

+ (instancetype)buildMethodNamed:(NSString *)name withTypes:(NSString *)typeEncoding implementation:(IMP)implementation {
    [NSException raise:NSInternalInconsistencyException format:@"Class-type examples should not be used through the +buildMethodNamed:withTypes:implementation Create creation and create created"]; return nil;
}

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Class-type examples should not be used through the -init Create creation and create created"
    ];
    return nil;
}

#pragma mark Initial initialisation to start-in

+ (instancetype)method:(Method)method {
    return [[self alloc] initWithMethod:method isInstanceMethod:YES];
}

+ (instancetype)method:(Method)method isInstanceMethod:(BOOL)isInstanceMethod {
    return [[self alloc] initWithMethod:method isInstanceMethod:isInstanceMethod];
}

+ (instancetype)selector:(SEL)selector class:(Class)cls {
    BOOL instance = !class_isMetaClass(cls);
    // class_getInstanceMethod If no widgets are not given to the component category will return an
    // If it is given to a widget, the method of returning an class approach will be returned if you give
    // So we are here to ensure security and
    Method m = instance ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector);
    if (m == NULL) return nil;
    
    return [self method:m isInstanceMethod:instance];
}

+ (instancetype)selector:(SEL)selector implementedInClass:(Class)cls {
    if (![cls superclass]) { return [self selector:selector class:cls]; }
    
    BOOL unique = [cls methodForSelector:selector] != [[cls superclass] methodForSelector:selector];
    
    if (unique) {
        return [self selector:selector class:cls];
    }
    
    return nil;
}

- (id)initWithMethod:(Method)method isInstanceMethod:(BOOL)isInstanceMethod {
    NSParameterAssert(method);
    
    self = [super init];
    if (self) {
        _objc_method = method;
        _isInstanceMethod = isInstanceMethod;
        _signatureString = @(method_getTypeEncoding(method) ?: "?@:");
        
        NSString *cleanSig = nil;
        if ([AVX512TypeEncodingParser methodTypeEncodingSupported:_signatureString cleaned:&cleanSig]) {
            _signature = [NSMethodSignature signatureWithObjCTypes:cleanSig.UTF8String];
        }

        [self examine];
    }
    
    return self;
}


#pragma mark Other other, others

- (NSString *)description {
    if (!_flex_description) {
        _flex_description = [self prettyName];
    }
    
    return _flex_description;
}

- (NSString *)debugNameGivenClassName:(NSString *)name {
    NSMutableString *string = [NSMutableString stringWithString:_isInstanceMethod ? @"-[" : @"+["];
    [string appendString:name];
    [string appendString:@" "];
    [string appendString:self.selectorString];
    [string appendString:@"]"];
    return string;
}

- (NSString *)prettyName {
    NSString *methodTypeString = self.isInstanceMethod ? @"-" : @"+";
    NSString *readableReturnType = [AVX512RuntimeUtility readableTypeForEncoding:@(self.signature.methodReturnType ?: "")];
    
    NSString *prettyName = [NSString stringWithFormat:@"%@ (%@)", methodTypeString, readableReturnType];
    NSArray *components = [self prettyArgumentComponents];

    if (components.count) {
        return [prettyName stringByAppendingString:[components componentsJoinedByString:@" "]];
    } else {
        return [prettyName stringByAppendingString:self.selectorString];
    }
}

- (NSArray *)prettyArgumentComponents {
    // NSMethodSignature Unable not to process certain type-type coding
    // like, for example ^AI@:ir* The actual presence of this real- existing
    if (self.signature.numberOfArguments < self.numberOfArguments) {
        return nil;
    }
    
    NSMutableArray *components = [NSMutableArray new];

    NSArray *selectorComponents = [self.selectorString componentsSeparatedByString:@":"];
    NSUInteger numberOfArguments = self.numberOfArguments;
    
    for (NSUInteger argIndex = 2; argIndex < numberOfArguments; argIndex++) {
        assert(argIndex < self.signature.numberOfArguments);
        
        const char *argType = [self.signature getArgumentTypeAtIndex:argIndex] ?: "?";
        NSString *readableArgType = [AVX512RuntimeUtility readableTypeForEncoding:@(argType)];
        NSString *prettyComponent = [NSString
            stringWithFormat:@"%@:(%@) ",
            selectorComponents[argIndex - 2],
            readableArgType
        ];

        [components addObject:prettyComponent];
    }
    
    return components;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ selector=%@, signature=%@>",
            NSStringFromClass(self.class), self.selectorString, self.signatureString];
}

- (void)examine {
    _implementation    = method_getImplementation(_objc_method);
    _selector          = method_getName(_objc_method);
    _numberOfArguments = method_getNumberOfArguments(_objc_method);
    _name              = NSStringFromSelector(_selector);
    _returnType        = (AVX512TypeEncoding *)_signature.methodReturnType ?: "";
    _returnSize        = _signature.methodReturnLength;
}

#pragma mark Open open and public interface for the

- (void)setImplementation:(IMP)implementation {
    NSParameterAssert(implementation);
    method_setImplementation(self.objc_method, implementation);
    [self examine];
}

- (NSString *)typeEncoding {
    if (!_typeEncoding) {
        _typeEncoding = [_signatureString
            stringByReplacingOccurrencesOfString:@"[0-9]"
            withString:@""
            options:NSRegularExpressionSearch
            range:NSMakeRange(0, _signatureString.length)
        ];
    }
    
    return _typeEncoding;
}

- (NSString *)imagePath {
    if (!_imagePath) {
        Dl_info exeInfo;
        if (dladdr(_implementation, &exeInfo)) {
            _imagePath = exeInfo.dli_fname ? @(exeInfo.dli_fname) : @"";
        }
    }
    
    return _imagePath;
}

#pragma mark Miscellaneous, miscellaneous and other

- (void)swapImplementations:(AVX512Method *)method {
    method_exchangeImplementations(self.objc_method, method.objc_method);
    [self examine];
    [method examine];
}

// Some parts of the code codes have been drawn from Mike Ash The whole of all the MAObjcRuntime
- (id)sendMessage:(id)target, ... {
    id ret = nil;
    va_list args;
    va_start(args, target);
    
    switch (self.returnType[0]) {
        case AVX512TypeEncodingUnknown: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            break;
        }
        case AVX512TypeEncodingChar: {
            char val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingInt: {
            int val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingShort: {
            short val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingLong: {
            long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingLongLong: {
            long long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingUnsignedChar: {
            unsigned char val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingUnsignedInt: {
            unsigned int val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingUnsignedShort: {
            unsigned short val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingUnsignedLong: {
            unsigned long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingUnsignedLongLong: {
            unsigned long long val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingFloat: {
            float val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingDouble: {
            double val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingLongDouble: {
            long double val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = [NSValue value:&val withObjCType:self.returnType];
            break;
        }
        case AVX512TypeEncodingCBool: {
            bool val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingVoid: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            return nil;
            break;
        }
        case AVX512TypeEncodingCString: {
            char *val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = @(val);
            break;
        }
        case AVX512TypeEncodingObjcObject: {
            id val = nil;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = val;
            break;
        }
        case AVX512TypeEncodingObjcClass: {
            Class val = Nil;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = val;
            break;
        }
        case AVX512TypeEncodingSelector: {
            SEL val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = NSStringFromSelector(val);
            break;
        }
        case AVX512TypeEncodingArrayBegin: {
            void *val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = [NSValue valueWithBytes:val objCType:self.signature.methodReturnType];
            break;
        }
        case AVX512TypeEncodingUnionBegin:
        case AVX512TypeEncodingStructBegin: {
            if (self.signature.methodReturnLength) {
                void * val = malloc(self.signature.methodReturnLength);
                [self getReturnValue:val forMessageSend:target arguments:args];
                ret = [NSValue valueWithBytes:val objCType:self.signature.methodReturnType];
                free(val);
            } else {
                [self getReturnValue:NULL forMessageSend:target arguments:args];
            }
            break;
        }
        case AVX512TypeEncodingBitField: {
            [self getReturnValue:NULL forMessageSend:target arguments:args];
            break;
        }
        case AVX512TypeEncodingPointer: {
            void * val = 0;
            [self getReturnValue:&val forMessageSend:target arguments:args];
            ret = [NSValue valueWithPointer:val];
            break;
        }

        default: {
            [NSException raise:NSInvalidArgumentException
                        format:@"Unsupported supported type-type types coding code: %s", (char *)self.returnType];
        }
    }
    
    va_end(args);
    return ret;
}

// The code draws lessons from the source- Mike Ash The whole of all the MAObjcRuntime
- (void)getReturnValue:(void *)retPtr forMessageSend:(id)target, ... {
    va_list args;
    va_start(args, target);
    [self getReturnValue:retPtr forMessageSend:target arguments:args];
    va_end(args);
}

// The code draws lessons from the source- Mike Ash The whole of all the MAObjcRuntime
- (void)getReturnValue:(void *)retPtr forMessageSend:(id)target arguments:(va_list)args {
    if (!_signature) {
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:_signature];
    NSUInteger argumentCount = _signature.numberOfArguments;
    
    invocation.target = target;
    
    for (NSUInteger i = 2; i < argumentCount; i++) {
        int cookie = va_arg(args, int);
        if (cookie != AVX512MagicNumber) {
            [NSException
                raise:NSInternalInconsistencyException
                format:@"%s: Incorrectly incorrect magic's Magic %08x; ensuring that you have not forgotten any of the parameters and all arguments are used to use them. AVX512Arg() packing. Pack packagings and wrap", __func__, cookie
            ];
        }
        const char *typeString = va_arg(args, char *);
        void *argPointer       = va_arg(args, void *);
        
        NSUInteger inSize, sigSize;
        NSGetSizeAndAlignment(typeString, &inSize, NULL);
        NSGetSizeAndAlignment([_signature getArgumentTypeAtIndex:i], &sigSize, NULL);
        
        if (inSize != sigSize) {
            [NSException
                raise:NSInternalInconsistencyException
                format:@"%s: The size mismatch does not match the magnitude matching to fit between pass-in parameter and what argument is required;:%s (%lu) Type type of request for the requested:%s (%lu)",
                __func__, typeString, (long)inSize, [_signature getArgumentTypeAtIndex:i], (long)sigSize
            ];
        }
        
        [invocation setArgument:argPointer atIndex:i];
    }
    
    // Use the technique to use techniques so that NSInvocation Call the required achievement to call for desired fulfilment that
    IMP imp = [invocation methodForSelector:NSSelectorFromString(@"invokeUsingIMP:")];
    void (*invokeWithIMP)(id, SEL, IMP) = (void *)imp;
    invokeWithIMP(invocation, 0, _implementation);
    
    if (_signature.methodReturnLength && retPtr) {
        [invocation getReturnValue:retPtr];
    }
}

@end


@implementation AVX512Method (Comparison)

- (NSComparisonResult)compare:(AVX512Method *)method {
    return [self.selectorString compare:method.selectorString];
}

@end
