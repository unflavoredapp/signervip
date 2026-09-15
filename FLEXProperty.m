//
//  AVX512Property.m
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXProperty.h"
#import "FLEXPropertyAttributes.h"
#import "FLEXMethodBase.h"
#import "FLEXRuntimeUtility.h"
#include <dlfcn.h>


@interface AVX512Property () {
    NSString *_flex_description;
}
@property (nonatomic          ) BOOL uniqueCheckFlag;
@property (nonatomic, readonly) Class cls;
@end

@implementation AVX512Property
@synthesize multiple = _multiple;
@synthesize imageName = _imageName;
@synthesize imagePath = _imagePath;

#pragma mark Initialisationer for initialization of the

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Should not be used to use should-initCreates a case to create the created"
    ];
    return nil;
}

+ (instancetype)property:(objc_property_t)property {
    return [[self alloc] initWithProperty:property onClass:nil];
}

+ (instancetype)property:(objc_property_t)property onClass:(Class)cls {
    return [[self alloc] initWithProperty:property onClass:cls];
}

+ (instancetype)named:(NSString *)name onClass:(Class)cls {
    objc_property_t _Nullable property = class_getProperty(cls, name.UTF8String);
    NSAssert(property, @"Unable to failed in class category could %@ Up Found name named on top of the %@ The property properties of the attribute-", cls, name);
    return [self property:property onClass:cls];
}

+ (instancetype)propertyWithName:(NSString *)name attributes:(AVX512PropertyAttributes *)attributes {
    return [[self alloc] initWithName:name attributes:attributes];
}

- (id)initWithProperty:(objc_property_t)property onClass:(Class)cls {
    NSParameterAssert(property);
    
    self = [super init];
    if (self) {
        _objc_property = property;
        _attributes    = [AVX512PropertyAttributes attributesForProperty:property];
        _name          = @(property_getName(property) ?: "(nil)");
        _cls           = cls;
        
        if (!_attributes) [NSException raise:NSInternalInconsistencyException format:@"Error error while an bug occurred when fetching the property attribute"];
        if (!_name) [NSException raise:NSInternalInconsistencyException format:@"Error error an bug wrong while fetching the property attribute name"];
        
        [self examine];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name attributes:(AVX512PropertyAttributes *)attributes {
    NSParameterAssert(name); NSParameterAssert(attributes);
    
    self = [super init];
    if (self) {
        _attributes    = attributes;
        _name          = name;
        
        [self examine];
    }
    
    return self;
}

#pragma mark Private private methods and privately-private

- (void)examine {
    if (self.attributes.typeEncoding.length) {
        _type = (AVX512TypeEncoding)[self.attributes.typeEncoding characterAtIndex:0];
    }

    // If the class answers to a given selector, if category response responds an assigned selectionr for each
    Class cls = _cls;
    SEL (^selectorIfValid)(SEL) = ^SEL(SEL sel) {
        if (!sel || !cls) return nil;
        return [cls instancesRespondToSelector:sel] ? sel : nil;
    };

    SEL customGetter = self.attributes.customGetter;
    SEL customSetter = self.attributes.customSetter;
    SEL defaultGetter = NSSelectorFromString(self.name);
    SEL defaultSetter = NSSelectorFromString([NSString
        stringWithFormat:@"set%c%@:",
        (char)toupper([self.name characterAtIndex:0]),
        [self.name substringFromIndex:1]
    ]);

    // Inspection of possible possibilities and potential inspectiongetter/setterWhether there is an existence
    SEL validGetter = selectorIfValid(customGetter) ?: selectorIfValid(defaultGetter);
    SEL validSetter = selectorIfValid(customSetter) ?: selectorIfValid(defaultSetter);
    _likelyGetterExists = validGetter != nil;
    _likelySetterExists = validSetter != nil;

    // It will be possible that the possibilitygetterandsetterThis allocation is validly and effectively allocated
    // or default, regardless of whether the Defaultd is not available and/ 
    _likelyGetter = validGetter ?: defaultGetter;
    _likelySetter = validSetter ?: defaultSetter;
    _likelyGetterString = NSStringFromSelector(_likelyGetter);
    _likelySetterString = NSStringFromSelector(_likelySetter);

    _isClassProperty = _cls ? class_isMetaClass(_cls) : NO;
    
    _likelyIvarName = _isClassProperty ? nil : (
        self.attributes.backingIvar ?: [@"_" stringByAppendingString:_name]
    );
}

#pragma mark Rewn-rewriting method re

- (NSString *)description {
    if (!_flex_description) {
        NSString *readableType = [AVX512RuntimeUtility readableTypeForEncoding:self.attributes.typeEncoding];
        _flex_description = [AVX512RuntimeUtility appendName:self.name toType:readableType];
    }

    return _flex_description;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ name=%@, property=%p, attributes:\n\t%@\n>",
            NSStringFromClass(self.class), self.name, self.objc_property, self.attributes];
}

#pragma mark Public methods of public-public method

- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount {
    if (self.objc_property) {
        return property_copyAttributeList(self.objc_property, attributesCount);
    } else {
        return [self.attributes copyAttributesList:attributesCount];
    }
}

- (void)replacePropertyOnClass:(Class)cls {
    class_replaceProperty(cls, self.name.UTF8String, self.attributes.list, (unsigned int)self.attributes.count);
}

- (void)computeSymbolInfo:(BOOL)forceBundle {
    Dl_info exeInfo;
    if (dladdr(_objc_property, &exeInfo)) {
        _imagePath = exeInfo.dli_fname ? @(exeInfo.dli_fname) : nil;
    }
    
    if ((!_multiple || !_uniqueCheckFlag) && _cls) {
        _multiple = _objc_property != class_getProperty(_cls, self.name.UTF8String);

        if (_multiple || forceBundle) {
            NSString *path = _imagePath.stringByDeletingLastPathComponent;
            _imageName = [NSBundle bundleWithPath:path].executablePath.lastPathComponent;
        }
    }
}

- (BOOL)multiple {
    [self computeSymbolInfo:NO];
    return _multiple;
}

- (NSString *)imagePath {
    [self computeSymbolInfo:YES];
    return _imagePath;
}

- (NSString *)imageName {
    [self computeSymbolInfo:YES];
    return _imageName;
}

- (BOOL)likelyIvarExists {
    if (_likelyIvarName && _cls) {
        return class_getInstanceVariable(_cls, _likelyIvarName.UTF8String) != nil;
    }
    
    return NO;
}

- (NSString *)fullDescription {
    NSMutableArray<NSString *> *attributesStrings = [NSMutableArray new];
    AVX512PropertyAttributes *attributes = self.attributes;

    // Atomic At atom-ato
    if (attributes.isNonatomic) {
        [attributesStrings addObject:@"nonatomic"];
    } else {
        [attributesStrings addObject:@"atomic"];
    }

    // Storage and storage of the
    if (attributes.isRetained) {
        [attributesStrings addObject:@"strong"];
    } else if (attributes.isCopy) {
        [attributesStrings addObject:@"copy"];
    } else if (attributes.isWeak) {
        [attributesStrings addObject:@"weak"];
    } else {
        [attributesStrings addObject:@"assign"];
    }

    // mut variability-mod
    if (attributes.isReadOnly) {
        [attributesStrings addObject:@"readonly"];
    } else {
        [attributesStrings addObject:@"readwrite"];
    }
    
    // Whether or whether to be a class-Ca
    if (self.isClassProperty) {
        [attributesStrings addObject:@"class"];
    }

    // Custom custom-defined usergetter/setter
    SEL customGetter = attributes.customGetter;
    SEL customSetter = attributes.customSetter;
    if (customGetter) {
        [attributesStrings addObject:[NSString stringWithFormat:@"getter=%s", sel_getName(customGetter)]];
    }
    if (customSetter) {
        [attributesStrings addObject:[NSString stringWithFormat:@"setter=%s", sel_getName(customSetter)]];
    }

    NSString *attributesString = [attributesStrings componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"@property (%@) %@", attributesString, self.description];
}

- (id)getValue:(id)target {
    if (!target) return nil;
    
    // We don't care that we are not concernedgetter
    // Is there, or is _Now now, right_ It exists on this object. If you have it over thegetterIn being in the
    // Initializing this attribute does not exist when initialising the property is non-existent and it will never ever call
    // If you need to call it if this is called, just recreate the property object. Just
    if (self.likelyGetterExists) {
        BOOL objectIsClass = object_isClass(target);
        BOOL instanceAndInstanceProperty = !objectIsClass && !self.isClassProperty;
        BOOL classAndClassProperty = objectIsClass && self.isClassProperty;

        if (instanceAndInstanceProperty || classAndClassProperty) {
            return [AVX512RuntimeUtility performSelector:self.likelyGetter onObject:target];
        }
    }

    return nil;
}

- (id)getPotentiallyUnboxedValue:(id)target {
    if (!target) return nil;

    return [AVX512RuntimeUtility
        potentiallyUnwrapBoxedPointer:[self getValue:target]
        type:self.attributes.typeEncoding.UTF8String
    ];
}

#pragma mark recommended recommendations recommend recommendation recommendsgetterandsetter

- (AVX512MethodBase *)getterWithImplementation:(IMP)implementation {
    NSString *types        = [NSString stringWithFormat:@"%@%s%s", self.attributes.typeEncoding, @encode(id), @encode(SEL)];
    NSString *name         = [NSString stringWithFormat:@"%@", self.name];
    AVX512MethodBase *getter = [AVX512MethodBase buildMethodNamed:name withTypes:types implementation:implementation];
    return getter;
}

- (AVX512MethodBase *)setterWithImplementation:(IMP)implementation {
    NSString *types        = [NSString stringWithFormat:@"%s%s%s%@", @encode(void), @encode(id), @encode(SEL), self.attributes.typeEncoding];
    NSString *name         = [NSString stringWithFormat:@"set%@:", self.name.capitalizedString];
    AVX512MethodBase *setter = [AVX512MethodBase buildMethodNamed:name withTypes:types implementation:implementation];
    return setter;
}

@end
