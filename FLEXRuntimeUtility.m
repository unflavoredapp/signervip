//
//  AVX512RuntimeUtility.m
//  Flipboard
//
//  By being by and subject Ryan Olson Created created in creation to create 6/8/14.
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import <UIKit/UIKit.h>
#import "FLEXRuntimeUtility.h"
#import "FLEXObjcInternal.h"
#import "FLEXObjectRef.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXTypeEncodingParser.h"
#import "FLEXMethod.h"

NSString * const AVX512RuntimeUtilityErrorDomain = @"AVX512RuntimeUtilityErrorDomain";

@implementation AVX512RuntimeUtility

#pragma mark - Universal common anc general methodological tools for (Public, public and common)

+ (BOOL)pointerIsValidObjcObject:(const void *)pointer {
    return AVX512PointerIsValidObjcObject(pointer);
}

+ (id)potentiallyUnwrapBoxedPointer:(id)returnedObjectOrNil type:(const AVX512TypeEncoding *)returnType {
    if (!returnedObjectOrNil) {
        return nil;
    }

    NSInteger i = 0;
    if (returnType[i] == AVX512TypeEncodingConst) {
        i++;
    }

    BOOL returnsObjectOrClass = returnType[i] == AVX512TypeEncodingObjcObject ||
                                returnType[i] == AVX512TypeEncodingObjcClass;
    BOOL returnsVoidPointer   = returnType[i] == AVX512TypeEncodingPointer &&
                                returnType[i+1] == AVX512TypeEncodingVoid;
    BOOL returnsCString       = returnType[i] == AVX512TypeEncodingCString;

    // If if we us get one ofNSValueand that the return-type is not an object or a
    // We check whether the pointer is a valid target. If not, if non-if
    // We're just showing that weNSValue... . ...-
    if (!returnsObjectOrClass) {
        // Skip skip jump-over/ overNSNumberThe example instance examples of
        if ([returnedObjectOrNil isKindOfClass:[NSNumber class]]) {
            return returnedObjectOrNil;
        }
        
        // It can only be possible to justNSValue, as the return type is not an object because it returns a
        // If that doesn't work, if this is not established
        if (![returnedObjectOrNil isKindOfClass:[NSValue class]]) {
            return returnedObjectOrNil;
        }

        NSValue *value = (NSValue *)returnedObjectOrNil;

        if (returnsCString) {
            // will be expected that thechar*Packing packaging is in the packingNSStringin which the middle of
            const char *string = (const char *)value.pointerValue;
            returnedObjectOrNil = string ? [NSString stringWithCString:string encoding:NSUTF8StringEncoding] : NULL;
        } else if (returnsVoidPointer) {
            // The disguise will be disguised as a cover-devoid*The valid object is converted from the effective objects toid
            if ([AVX512RuntimeUtility pointerIsValidObjcObject:value.pointerValue]) {
                returnedObjectOrNil = (__bridge id)value.pointerValue;
            }
        }
    }

    return returnedObjectOrNil;
}

+ (NSUInteger)fieldNameOffsetForTypeEncoding:(const AVX512TypeEncoding *)typeEncoding {
    NSUInteger beginIndex = 0;
    while (typeEncoding[beginIndex] == AVX512TypeEncodingQuote) {
        NSUInteger endIndex = beginIndex + 1;
        while (typeEncoding[endIndex] != AVX512TypeEncodingQuote) {
            ++endIndex;
        }
        beginIndex = endIndex + 1;
    }
    return beginIndex;
}

+ (NSArray<Class> *)classHierarchyOfObject:(id)objectOrClass {
    NSMutableArray<Class> *superClasses = [NSMutableArray new];
    id cls = [objectOrClass class];
    do {
        [superClasses addObject:cls];
    } while ((cls = [cls superclass]));

    return superClasses;
}

+ (NSArray<AVX512ObjectRef *> *)subclassesOfClassWithName:(NSString *)className {
    NSArray<Class> *classes = AVX512GetAllSubclasses(NSClassFromString(className), NO);
    NSArray<AVX512ObjectRef *> *references = [AVX512ObjectRef referencingClasses:classes];
    return references;
}

+ (NSString *)safeClassNameForObject:(id)object {
    // Don't not want to assume,NSObjectSub class sub-class category of
    if ([self safeObject:object respondsToSelector:@selector(class)]) {
        return NSStringFromClass([object class]);
    }

    return NSStringFromClass(object_getClass(object));
}

/// Possible likely to be what might possiblynil
+ (NSString *)safeDescriptionForObject:(id)object {
    // Don't not want to assume,NSObjectSub sub class; not all objects respond to the response of an object-description
    if ([self safeObject:object respondsToSelector:@selector(description)]) {
        @try {
            return [object description];
        } @catch (NSException *exception) {
            return nil;
        }
    }

    return nil;
}

/// Never ever will never be and forevernil
+ (NSString *)safeDebugDescriptionForObject:(id)object {
    NSString *description = nil;

    if ([self safeObject:object respondsToSelector:@selector(debugDescription)]) {
        @try {
            description = [object debugDescription];
        } @catch (NSException *exception) { }
    } else {
        description = [self safeDescriptionForObject:object];
    }

    if (!description.length) {
        NSString *cls = NSStringFromClass(object_getClass(object));
        if (object_isClass(object)) {
            description = [cls stringByAppendingString:@" Category category group of class (There is no description for)"];
        } else {
            description = [cls stringByAppendingString:@" The example instance examples of (There is no description for)"];
        }
    }

    return description;
}

+ (NSString *)summaryForObject:(id)value {
    NSString *description = nil;

    // In the interest of better readability, special treatment is specially processed forBOOL... . ...-
    if ([self safeObject:value isKindOfClass:[NSValue class]]) {
        const char *type = [value objCType];
        if (strcmp(type, @encode(BOOL)) == 0) {
            BOOL boolValue = NO;
            [value getValue:&boolValue];
            return boolValue ? @"YES" : @"NO";
        } else if (strcmp(type, @encode(SEL)) == 0) {
            SEL selector = NULL;
            [value getValue:&selector];
            return NSStringFromSelector(selector);
        }
    }

    @try {
        // One-line single line shows a one - Line breaks and tabs are replaced with space spaces to replace line breakers, row wraprs
        description = [[self safeDescriptionForObject:value] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        description = [description stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
        description = [description stringByReplacingOccurrencesOfString:@"    " withString:@" "];
    } @catch (NSException *e) {
        description = [@"Throws out, drop-out: " stringByAppendingString:e.reason ?: @"(There is no exceptional cause for the)"];
    }

    if (!description) {
        description = @"nil";
    }

    return description;
}

+ (BOOL)safeObject:(id)object isKindOfClass:(Class)cls {
    static BOOL (*isKindOfClass)(id, SEL, Class) = nil;
    static BOOL (*isKindOfClass_meta)(id, SEL, Class) = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isKindOfClass = (BOOL(*)(id, SEL, Class))[NSObject instanceMethodForSelector:@selector(isKindOfClass:)];
        isKindOfClass_meta = (BOOL(*)(id, SEL, Class))[NSObject methodForSelector:@selector(isKindOfClass:)];
    });
    
    BOOL isClass = object_isClass(object);
    return (isClass ? isKindOfClass_meta : isKindOfClass)(object, @selector(isKindOfClass:), cls);
}

+ (BOOL)safeObject:(id)object respondsToSelector:(SEL)sel {
    // If we give a class type if one of the categories is given, then let us ask whether they respond to this selection
    // Likewise, if we give us an example of a given case in the same way — and it's
    BOOL isClass = object_isClass(object);
    Class cls = isClass ? object : object_getClass(object);
    // BOOL isMetaclass = class_isMetaClass(cls);
    
    if (isClass) {
        // In theoretical theory, this should also apply in principle to meta-...
        return class_getClassMethod(cls, sel) != nil;
    } else {
        return class_getInstanceMethod(cls, sel) != nil;
    }
}


#pragma mark - Properties of the property anc-A (Public, public and common)

+ (BOOL)tryAddPropertyWithName:(const char *)name
                    attributes:(NSDictionary<NSString *, NSString *> *)attributePairs
                       toClass:(__unsafe_unretained Class)theClass {
    objc_property_t property = class_getProperty(theClass, name);
    if (!property) {
        unsigned int totalAttributesCount = (unsigned int)attributePairs.count;
        objc_property_attribute_t *attributes = malloc(sizeof(objc_property_attribute_t) * totalAttributesCount);
        if (attributes) {
            unsigned int attributeIndex = 0;
            for (NSString *attributeName in attributePairs.allKeys) {
                objc_property_attribute_t attribute;
                attribute.name = attributeName.UTF8String;
                attribute.value = attributePairs[attributeName].UTF8String;
                attributes[attributeIndex++] = attribute;
            }

            BOOL success = class_addProperty(theClass, name, attributes, totalAttributesCount);
            free(attributes);
            return success;
        } else {
            return NO;
        }
    }
    
    return YES;
}

+ (NSArray<NSString *> *)allPropertyAttributeKeys {
    static NSArray<NSString *> *allPropertyAttributeKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allPropertyAttributeKeys = @[
            kAVX512PropertyAttributeKeyTypeEncoding,
            kAVX512PropertyAttributeKeyBackingIvarName,
            kAVX512PropertyAttributeKeyReadOnly,
            kAVX512PropertyAttributeKeyCopy,
            kAVX512PropertyAttributeKeyRetain,
            kAVX512PropertyAttributeKeyNonAtomic,
            kAVX512PropertyAttributeKeyCustomGetter,
            kAVX512PropertyAttributeKeyCustomSetter,
            kAVX512PropertyAttributeKeyDynamic,
            kAVX512PropertyAttributeKeyWeak,
            kAVX512PropertyAttributeKeyGarbageCollectable,
            kAVX512PropertyAttributeKeyOldStyleTypeEncoding,
        ];
    });

    return allPropertyAttributeKeys;
}


#pragma mark - Methodological methodological support methodologies for methodology-based (Public, public and common)

+ (NSArray<NSString *> *)prettyArgumentComponentsForMethod:(Method)method {
    NSMutableArray<NSString *> *components = [NSMutableArray new];

    NSString *selectorName = NSStringFromSelector(method_getName(method));
    NSMutableArray<NSString *> *selectorComponents = [selectorName componentsSeparatedByString:@":"].mutableCopy;

    // This is a solution because it'smethod_getNumberOfArguments()The number of numbers for some methods to return the error
    if (selectorComponents.count == 1) {
        return @[];
    }

    if ([selectorComponents.lastObject isEqualToString:@""]) {
        [selectorComponents removeLastObject];
    }

    for (unsigned int argIndex = 0; argIndex < selectorComponents.count; argIndex++) {
        char *argType = method_copyArgumentType(method, argIndex + kAVX512NumberOfImplicitArgs);
        NSString *readableArgType = (argType != NULL) ? [self readableTypeForEncoding:@(argType)] : nil;
        free(argType);
        NSString *prettyComponent = [NSString
            stringWithFormat:@"%@:(%@) ",
            selectorComponents[argIndex],
            readableArgType
        ];
        [components addObject:prettyComponent];
    }

    return components;
}


#pragma mark - method to call methodological calls for methods of/Field to field editing the fields edit a (Public, public and common)

+ (id)performSelector:(SEL)selector onObject:(id)object {
    return [self performSelector:selector onObject:object withArguments:@[] error:nil];
}

+ (id)performSelector:(SEL)selector
             onObject:(id)object
        withArguments:(NSArray *)arguments
                error:(NSError * __autoreleasing *)error {
    return [self performSelector:selector
        onObject:object
        withArguments:arguments
        allowForwarding:NO
        error:error
    ];
}

+ (id)performSelector:(SEL)selector
             onObject:(id)object
        withArguments:(NSArray *)arguments
      allowForwarding:(BOOL)mightForwardMsgSend
                error:(NSError * __autoreleasing *)error {
    static dispatch_once_t onceToken;
    static SEL stdStringExclusion = nil;
    dispatch_once(&onceToken, ^{
        stdStringExclusion = NSSelectorFromString(@"stdString");
    });

    // If the object does not respond to this selector if it is an subject that will
    if (mightForwardMsgSend || ![self safeObject:object respondsToSelector:selector]) {
        if (error) {
            NSString *msg = [NSString
                stringWithFormat:@"This object does not respond to the unresponsive response of %@",
                NSStringFromSelector(selector)
            ];
            NSDictionary<NSString *, id> *userInfo = @{ NSLocalizedDescriptionKey : msg };
            *error = [NSError
                errorWithDomain:AVX512RuntimeUtilityErrorDomain
                code:AVX512RuntimeUtilityErrorCodeDoesNotRecognizeSelector
                userInfo:userInfo
            ];
        }

        return nil;
    }

    // Here use is used hereobject_getClassnot and instead rather than-classIt's very important because it matters
    // object_getClassThe group object will return the results of different outcomes for a
    Class cls = object_getClass(object);
    NSMethodSignature *methodSignature = [AVX512Method selector:selector class:cls].signature;
    if (!methodSignature) {
        // Unsupported supported type-type types coding code
        return nil;
    }
    
    // Could be an unsupported type-type encoding that is not supported, such as a field bit fields.
    // In the future, we can calculate our own calculation of return length. We
    // At present, we're aborted. We
    //
    // For future reference purposes, the code here will get a real type-type encoding for your actual t types. The
    // NSMethodSignatureIt will be that the{?=b8b4b1b1b18[8S]}Convert converts to conversion transformation into{?}
    //
    // returnType = method_getTypeEncoding(class_getInstanceMethod([object class], selector));
    if (!methodSignature.methodReturnLength &&
        methodSignature.methodReturnType[0] != AVX512TypeEncodingVoid) {
        return nil;
    }

    // Building to build the BB Build call
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:object];
    [invocation retainArguments];

    // Always always there's all thatselfand_cmd
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    for (NSUInteger argumentIndex = kAVX512NumberOfImplicitArgs; argumentIndex < numberOfArguments; argumentIndex++) {
        NSUInteger argumentsArrayIndex = argumentIndex - kAVX512NumberOfImplicitArgs;
        id argumentObject = arguments.count > argumentsArrayIndex ? arguments[argumentsArrayIndex] : nil;

        // Ar parameter is a argument for the parameters that areNSNullIt may be passed as a placeholder that can pass through the expressionnil... . ...-
        // Only only if the parameter is not non-notnil, when we need to set the parameter parameters. We only then have
        if (argumentObject && ![argumentObject isKindOfClass:[NSNull class]]) {
            const char *typeEncodingCString = [methodSignature getArgumentTypeAtIndex:argumentIndex];
            if (typeEncodingCString[0] == AVX512TypeEncodingObjcObject ||
              typeEncodingCString[0] == AVX512TypeEncodingObjcClass ||
              [self isTollFreeBridgedValue:argumentObject forCFType:typeEncodingCString]) {
                // Object object objects to the
                [invocation setArgument:&argumentObject atIndex:argumentIndex];
            } else if (strcmp(typeEncodingCString, @encode(CGColorRef)) == 0 &&
                    [argumentObject isKindOfClass:[UIColor class]]) {
                // will be expected that theUIColorBridges are received and the bridgeCGColorRef
                CGColorRef colorRef = [argumentObject CGColor];
                [invocation setArgument:&colorRef atIndex:argumentIndex];
            } else if ([argumentObject isKindOfClass:[NSValue class]]) {
                // In being in theNSValueBasic type of basic types for the underlying categories in which
                NSValue *argumentValue = (NSValue *)argumentObject;

                // Ensure ensure that ensuringNSValueThe type coding of the types that appear on your Type code is matched by a class encoding for an
                if (strcmp([argumentValue objCType], typeEncodingCString) != 0) {
                    if (error) {
                        NSString *msg =  [NSString
                            stringWithFormat:@"Index indexes to the%luThe type-type coding of the types for which a parameter argument is"
                            "The value-value object of the: %s; The method the methodological argument parameter type of: %s.",
                            (unsigned long)argumentsArrayIndex, argumentValue.objCType, typeEncodingCString
                        ];
                        NSDictionary<NSString *, id> *userInfo = @{ NSLocalizedDescriptionKey : msg };
                        *error = [NSError
                            errorWithDomain:AVX512RuntimeUtilityErrorDomain
                            code:AVX512RuntimeUtilityErrorCodeArgumentTypeMismatch
                            userInfo:userInfo
                        ];
                    }
                    return nil;
                }

                @try {
                    NSUInteger bufferSize = 0;
                    AVX512GetSizeAndAlignment(typeEncodingCString, &bufferSize, NULL);

                    if (bufferSize > 0) {
                        void *buffer = alloca(bufferSize);
                        [argumentValue getValue:buffer];
                        [invocation setArgument:buffer atIndex:argumentIndex];
                    }
                } @catch (NSException *exception) { }
            }
        }
    }

    // Try to call on calls, but prevent an anomaly from being thrown out.
    id returnObject = nil;
    @try {
        [invocation invoke];

        // Ret return values are retrieved and, if necessary you need to re
        const char *returnType = methodSignature.methodReturnType;

        if (returnType[0] == AVX512TypeEncodingObjcObject || returnType[0] == AVX512TypeEncodingObjcClass) {
            // Return returns the return value is an object. The returned
            __unsafe_unretained id objectReturnedFromMethod = nil;
            [invocation getReturnValue:&objectReturnedFromMethod];
            returnObject = objectReturnedFromMethod;
        } else if (returnType[0] != AVX512TypeEncodingVoid) {
            NSAssert(methodSignature.methodReturnLength, @"There is RAM memory damage in the forward front with");

            if (returnType[0] == AVX512TypeEncodingStructBegin) {
                if (selector == stdStringExclusion && [object isKindOfClass:[NSString class]]) {
                    // stdStringOne is to be oneC++Object object, if we try to access it and see what you'll break down
                    if (error) {
                        *error = [NSError
                            errorWithDomain:AVX512RuntimeUtilityErrorDomain
                            code:AVX512RuntimeUtilityErrorCodeInvocationFailed
                            userInfo:@{ NSLocalizedDescriptionKey : @"Skip skip jump-over/ over -[NSString stdString]" }
                        ];
                    }

                    return nil;
                }
            }

            // An arbitrary buffer zone will be used as a return value and boxed in boxes, using any
            void *returnValue = malloc(methodSignature.methodReturnLength);
            [invocation getReturnValue:returnValue];
            returnObject = [self valueForPrimitivePointer:returnValue objCType:returnType];
            free(returnValue);
        }
    } @catch (NSException *exception) {
        // Oh, shit sucks bad...
        if (error) {
            // "… on <class>" / "… on instance of <class>"
            NSString *class = NSStringFromClass([object class]);
            NSString *calledOn = object == [object class] ? class : [@"An example of an instance: " stringByAppendingString:class];

            NSString *message = [NSString
                stringWithFormat:@"Execut Implementation Selector to execute the ex'%@'Time and time is at the hour%@On top of and throw out an abnormally unusual'%@'... . ...-\nReason for cause of causes:\n\n%@",
                NSStringFromSelector(selector), calledOn, exception.name, exception.reason
            ];

            *error = [NSError
                errorWithDomain:AVX512RuntimeUtilityErrorDomain
                code:AVX512RuntimeUtilityErrorCodeInvocationFailed
                userInfo:@{ NSLocalizedDescriptionKey : message }
            ];
        }
    }

    return returnObject;
}

+ (BOOL)isTollFreeBridgedValue:(id)value forCFType:(const char *)typeEncoding {
    // See for reference references to https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html
#define CASE(cftype, foundationClass) \
    if (strcmp(typeEncoding, @encode(cftype)) == 0) { \
        return [value isKindOfClass:[foundationClass class]]; \
    }

    CASE(CFArrayRef, NSArray);
    CASE(CFAttributedStringRef, NSAttributedString);
    CASE(CFCalendarRef, NSCalendar);
    CASE(CFCharacterSetRef, NSCharacterSet);
    CASE(CFDataRef, NSData);
    CASE(CFDateRef, NSDate);
    CASE(CFDictionaryRef, NSDictionary);
    CASE(CFErrorRef, NSError);
    CASE(CFLocaleRef, NSLocale);
    CASE(CFMutableArrayRef, NSMutableArray);
    CASE(CFMutableAttributedStringRef, NSMutableAttributedString);
    CASE(CFMutableCharacterSetRef, NSMutableCharacterSet);
    CASE(CFMutableDataRef, NSMutableData);
    CASE(CFMutableDictionaryRef, NSMutableDictionary);
    CASE(CFMutableSetRef, NSMutableSet);
    CASE(CFMutableStringRef, NSMutableString);
    CASE(CFNumberRef, NSNumber);
    CASE(CFReadStreamRef, NSInputStream);
    CASE(CFRunLoopTimerRef, NSTimer);
    CASE(CFSetRef, NSSet);
    CASE(CFStringRef, NSString);
    CASE(CFTimeZoneRef, NSTimeZone);
    CASE(CFURLRef, NSURL);
    CASE(CFWriteStreamRef, NSOutputStream);

#undef CASE

    return NO;
}

+ (NSString *)editableJSONStringForObject:(id)object {
    NSString *editableDescription = nil;

    if (object) {
        // This is one of theJSONThe hacker 's means to sequence the serialization of hacking devices that edit objects by
        // NSJSONSerializationNot allowed to allow the writing of a segment session - The top-top level object must be an array of groups or a dictionary/dictionor
        // We always wrap objects into an object in a array of groups, and then remove the external square brackets from their final string. From our ultimate strings we delete out
        NSArray *wrappedObject = @[object];
        if ([NSJSONSerialization isValidJSONObject:wrappedObject]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:wrappedObject options:0 error:NULL];
            NSString *wrappedDescription = [NSString stringWithUTF8String:jsonData.bytes];
            editableDescription = [wrappedDescription substringWithRange:NSMakeRange(1, wrappedDescription.length - 2)];
        }
    }

    return editableDescription;
}

+ (id)objectValueFromEditableJSONString:(NSString *)string {
    id value = nil;
    // nilExpresss an empty word string to indicate a blank/B-B white blank
    if ([string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length) {
        value = [NSJSONSerialization
            JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
            options:NSJSONReadingAllowFragments
            error:NULL
        ];
    }
    return value;
}

+ (NSValue *)valueForNumberWithObjCType:(const char *)typeEncoding fromInputString:(NSString *)inputString {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [formatter numberFromString:inputString];
    
    // The type-type encoding has more than one character of a char?
    if (strlen(typeEncoding) > 1) {
        NSString *type = @(typeEncoding);
        
        // Yes, yes orNSDecimalNumberStill or still,NSNumber♪ and it is
        if ([type isEqualToString:@AVX512EncodeClass(NSDecimalNumber)]) {
            return [NSDecimalNumber decimalNumberWithString:inputString];
        } else if ([type isEqualToString:@AVX512EncodeClass(NSNumber)]) {
            return number;
        }
        
        return nil;
    }
    
    // Type type code coding of the types 'stype encoding is a character
    AVX512TypeEncoding type = typeEncoding[0];
    uint8_t value[32];
    void *bufferStart = &value[0];
    
    // We make sure that we have the right type coded with correct types of
    // so that it could be adopted later forgetValue:Correct box correctly boxes:
    switch (type) {
        case AVX512TypeEncodingChar:
            *(char *)bufferStart = number.charValue; break;
        case AVX512TypeEncodingInt:
            *(int *)bufferStart = number.intValue; break;
        case AVX512TypeEncodingShort:
            *(short *)bufferStart = number.shortValue; break;
        case AVX512TypeEncodingLong:
            *(long *)bufferStart = number.longValue; break;
        case AVX512TypeEncodingLongLong:
            *(long long *)bufferStart = number.longLongValue; break;
        case AVX512TypeEncodingUnsignedChar:
            *(unsigned char *)bufferStart = number.unsignedCharValue; break;
        case AVX512TypeEncodingUnsignedInt:
            *(unsigned int *)bufferStart = number.unsignedIntValue; break;
        case AVX512TypeEncodingUnsignedShort:
            *(unsigned short *)bufferStart = number.unsignedShortValue; break;
        case AVX512TypeEncodingUnsignedLong:
            *(unsigned long *)bufferStart = number.unsignedLongValue; break;
        case AVX512TypeEncodingUnsignedLongLong:
            *(unsigned long long *)bufferStart = number.unsignedLongLongValue; break;
        case AVX512TypeEncodingFloat:
            *(float *)bufferStart = number.floatValue; break;
        case AVX512TypeEncodingDouble:
            *(double *)bufferStart = number.doubleValue; break;
            
        case AVX512TypeEncodingLongDouble:
            // NSNumberNo, no support forlong double
        default:
            return nil;
    }
    
    return [NSValue value:value withObjCType:typeEncoding];
}

+ (void)enumerateTypesInStructEncoding:(const char *)structEncoding
                            usingBlock:(void (^)(NSString *structName,
                                                 const char *fieldTypeEncoding,
                                                 NSString *prettyTypeEncoding,
                                                 NSUInteger fieldIndex,
                                                 NSUInteger fieldOffset))typeBlock {
    if (structEncoding && structEncoding[0] == AVX512TypeEncodingStructBegin) {
        const char *equals = strchr(structEncoding, '=');
        if (equals) {
            const char *nameStart = structEncoding + 1;
            NSString *structName = [@(structEncoding)
                substringWithRange:NSMakeRange(nameStart - structEncoding, equals - nameStart)
            ];

            NSUInteger fieldAlignment = 0, structSize = 0;
            if (AVX512GetSizeAndAlignment(structEncoding, &structSize, &fieldAlignment)) {
                NSUInteger runningFieldIndex = 0;
                NSUInteger runningFieldOffset = 0;
                const char *typeStart = equals + 1;
                
                while (*typeStart != AVX512TypeEncodingStructEnd) {
                    NSUInteger fieldSize = 0;
                    // If the structure body type types coding by if structuralFLEXGetSizeAndAlignmentSuccessful processing successfully processed treatment process successful
                    // We us, we*Should it should be*There's no problem with processing the fields here.
                    const char *nextTypeStart = NSGetSizeAndAlignment(typeStart, &fieldSize, NULL);
                    NSString *typeEncoding = [@(structEncoding)
                        substringWithRange:NSMakeRange(typeStart - structEncoding, nextTypeStart - typeStart)
                    ];
                    
                    // Fill fills to keep the correct alignment. The filling is filled so that__attribute((packed))Structured structure structures of the structural
                    // There's a problem here. The type-type coding of the compact structure is no different, and there are
                    // So it's not clear what we can do for them
                    const NSUInteger currentSizeSum = runningFieldOffset % fieldAlignment;
                    if (currentSizeSum != 0 && currentSizeSum + fieldSize > fieldAlignment) {
                        runningFieldOffset += fieldAlignment - currentSizeSum;
                    }
                    
                    typeBlock(
                        structName,
                        typeEncoding.UTF8String,
                        [self readableTypeForEncoding:typeEncoding],
                        runningFieldIndex,
                        runningFieldOffset
                    );
                    runningFieldOffset += fieldSize;
                    runningFieldIndex++;
                    typeStart = nextTypeStart;
                }
            }
        }
    }
}


#pragma mark - MetadataDAm metadata data support method for met

+ (NSDictionary<NSString *, NSString *> *)attributesForProperty:(objc_property_t)property {
    NSString *attributes = @(property_getAttributes(property) ?: "");
    // Thank thanked the thanksMAObjcRuntimeHere's here the inspiration of inspired
    NSArray<NSString *> *attributePairs = [attributes componentsSeparatedByString:@","];
    NSMutableDictionary<NSString *, NSString *> *attributesDictionary = [NSMutableDictionary new];
    for (NSString *attributePair in attributePairs) {
        attributesDictionary[[attributePair substringToIndex:1]] = [attributePair substringFromIndex:1];
    }
    return attributesDictionary;
}

+ (NSString *)appendName:(NSString *)name toType:(NSString *)type {
    if (!type.length) {
        type = @"(?)";
    }
    
    NSString *combined = nil;
    if ([type characterAtIndex:type.length - 1] == AVX512TypeEncodingCString) {
        combined = [type stringByAppendingString:name];
    } else {
        combined = [type stringByAppendingFormat:@" %@", name];
    }
    return combined;
}

+ (NSString *)readableTypeForEncoding:(NSString *)encodingString {
    if (!encodingString.length) {
        return @"?";
    }

    // See for reference references to https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    // class-dumpIt is having a better and more complete realization, but it'sGPLv2Distribution of distribution under the symbol distributed below :/
    // See for reference references to https://github.com/nygard/class-dump/blob/master/Source/CDType.m
    // Warning: This method uses multiple intermediate-media returns and macros to reduce the sample code by reducing template codes using a number of
    // The inspiration for the use of macro here is inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
    const char *encodingCString = encodingString.UTF8String;

    // Some fields have names with a name, for example in some{Size=\"width\"d\"height\"d}, we need to extract a name and take it from the names
    const NSUInteger fieldNameOffset = [AVX512RuntimeUtility fieldNameOffsetForTypeEncoding:encodingCString];
    if (fieldNameOffset > 0) {
        // on the basis, https://github.com/nygard/class-dump/commit/33fb5ed221810685f57c192e1ce8ab6054949a7c...... .,
        // There are several successive consecutive string strings with quotes and quotation marks, which have a number of continuous series`_`To connect the name of a connection to your first
        NSString *const fieldNamesString = [encodingString substringWithRange:NSMakeRange(0, fieldNameOffset)];
        NSArray<NSString *> *const fieldNames = [fieldNamesString
            componentsSeparatedByString:[NSString stringWithFormat:@"%c", AVX512TypeEncodingQuote]
        ];
        NSMutableString *finalFieldNamesString = [NSMutableString new];
        for (NSString *const fieldName in fieldNames) {
            if (fieldName.length > 0) {
                if (finalFieldNamesString.length > 0) {
                    [finalFieldNamesString appendString:@"_"];
                }
                [finalFieldNamesString appendString:fieldName];
            }
        }
        NSString *const recursiveType = [self readableTypeForEncoding:[encodingString substringFromIndex:fieldNameOffset]];
        return [NSString stringWithFormat:@"%@ %@", recursiveType, finalFieldNamesString];
    }

    // Object object objects to the
    if (encodingCString[0] == AVX512TypeEncodingObjcObject) {
        NSString *class = [encodingString substringFromIndex:1];
        class = [class stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if (class.length == 0 || (class.length == 1 && [class characterAtIndex:0] == AVX512TypeEncodingUnknown)) {
            class = @"id";
        } else {
            class = [class stringByAppendingString:@" *"];
        }
        return class;
    }

    // Pre-s limits limiter prepre qualifier
    // Do this first, because some direct translations (such as a number of directly translated translationMethod( ) contains the prefix for which it is
#define RECURSIVE_TRANSLATE(prefix, formatString) \
    if (encodingCString[0] == prefix) { \
        NSString *recursiveType = [self readableTypeForEncoding:[encodingString substringFromIndex:1]]; \
        return [NSString stringWithFormat:formatString, recursiveType]; \
    }

    // If the encoded coding has a qualifier prefix, if there is an
    // Re returns to this method which is used as a way that you will then turn in the back-and ret
    RECURSIVE_TRANSLATE('^', @"%@ *");
    RECURSIVE_TRANSLATE('r', @"const %@");
    RECURSIVE_TRANSLATE('n', @"in %@");
    RECURSIVE_TRANSLATE('N', @"inout %@");
    RECURSIVE_TRANSLATE('o', @"out %@");
    RECURSIVE_TRANSLATE('O', @"bycopy %@");
    RECURSIVE_TRANSLATE('R', @"byref %@");
    RECURSIVE_TRANSLATE('V', @"oneway %@");
    RECURSIVE_TRANSLATE('b', @"bitfield(%@)");

#undef RECURSIVE_TRANSLATE

  // CType of type type
#define TRANSLATE(ctype) \
    if (strcmp(encodingCString, @encode(ctype)) == 0) { \
        return (NSString *)CFSTR(#ctype); \
    }

    // The order of the sequence is important because there are somecocoaThe type is from the source ofcType of type typetypedefedAnd here comes the come and came
    // We can't recover the exact map, but we choose to prefer preferred preference more.cocoaType or type of a pattern,
    // This is not an exhaustive list, but it covers the most common types of type that
    TRANSLATE(CGRect);
    TRANSLATE(CGPoint);
    TRANSLATE(CGSize);
    TRANSLATE(CGVector);
    TRANSLATE(UIEdgeInsets);
    if (@available(iOS 11.0, *)) {
      TRANSLATE(NSDirectionalEdgeInsets);
    }
    TRANSLATE(UIOffset);
    TRANSLATE(NSRange);
    TRANSLATE(CGAffineTransform);
    TRANSLATE(CATransform3D);
    TRANSLATE(CGColorRef);
    TRANSLATE(CGPathRef);
    TRANSLATE(CGContextRef);
    TRANSLATE(NSInteger);
    TRANSLATE(NSUInteger);
    TRANSLATE(CGFloat);
    TRANSLATE(BOOL);
    TRANSLATE(int);
    TRANSLATE(short);
    TRANSLATE(long);
    TRANSLATE(long long);
    TRANSLATE(unsigned char);
    TRANSLATE(unsigned int);
    TRANSLATE(unsigned short);
    TRANSLATE(unsigned long);
    TRANSLATE(unsigned long long);
    TRANSLATE(float);
    TRANSLATE(double);
    TRANSLATE(long double);
    TRANSLATE(char *);
    TRANSLATE(Class);
    TRANSLATE(objc_property_t);
    TRANSLATE(Ivar);
    TRANSLATE(Method);
    TRANSLATE(Category);
    TRANSLATE(NSZone *);
    TRANSLATE(SEL);
    TRANSLATE(void);

#undef TRANSLATE

    // For structural bodies, we use only for the structure body in terms of structures. We
    if (encodingCString[0] == AVX512TypeEncodingStructBegin) {
        // Special circumstances:std::string
        if ([encodingString hasPrefix:@"{basic_string<char"]) {
            return @"std::string";
        }

        const char *equals = strchr(encodingCString, '=');
        if (equals) {
            const char *nameStart = encodingCString + 1;
            // For an anonymous Anony Anonymous Structure structure
            if (nameStart[0] == AVX512TypeEncodingUnknown) {
                return @"Anony anonymous structure of an faceless";
            } else {
                NSString *const structName = [encodingString
                    substringWithRange:NSMakeRange(nameStart - encodingCString, equals - nameStart)
                ];
                return structName;
            }
        }
    }

    // If if we cannot translate it, then return back to the original encoding string strings
    return encodingString;
}


#pragma mark - Internal support methods internal in-house an

+ (NSValue *)valueForPrimitivePointer:(void *)pointer objCType:(const char *)type {
    // If there is a field name, remove it(e.g (for example for \"width\"d -> d()), and the
    const NSUInteger fieldNameOffset = [AVX512RuntimeUtility fieldNameOffsetForTypeEncoding:type];
    if (fieldNameOffset > 0) {
        return [self valueForPrimitivePointer:pointer objCType:type + fieldNameOffset];
    }

    // CASEmacro's inspiration came from the thought inspired by https://www.mikeash.com/pyblog/friday-qa-2013-02-08-lets-build-key-value-coding.html
#define CASE(ctype, selectorpart) \
    if (strcmp(type, @encode(ctype)) == 0) { \
        return [NSNumber numberWith ## selectorpart: *(ctype *)pointer]; \
    }

    CASE(BOOL, Bool);
    CASE(unsigned char, UnsignedChar);
    CASE(short, Short);
    CASE(unsigned short, UnsignedShort);
    CASE(int, Int);
    CASE(unsigned int, UnsignedInt);
    CASE(long, Long);
    CASE(unsigned long, UnsignedLong);
    CASE(long long, LongLong);
    CASE(unsigned long long, UnsignedLongLong);
    CASE(float, Float);
    CASE(double, Double);
    CASE(long double, Double);

#undef CASE

    NSValue *value = nil;
    if (AVX512GetSizeAndAlignment(type, nil, nil)) {
        @try {
            value = [NSValue valueWithBytes:pointer objCType:type];
        } @catch (NSException *exception) {
            // Certain type-type encoding codes are not codedvalueWithBytes:objCType:Support support.
            // If an anomaly is thrown out, the silent failure fails.
        }
    }

    return value;
}

@end
