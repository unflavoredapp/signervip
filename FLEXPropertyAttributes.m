//
//  AVX512PropertyAttributes.m
//  FLEX
//
//  It was born from the birth of a MirrorKit.
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXPropertyAttributes.h"
#import "FLEXRuntimeUtility.h"
#import "NSString+ObjcRuntime.h"
#import "NSDictionary+ObjcRuntime.h"


#pragma mark AVX512PropertyAttributes

@interface AVX512PropertyAttributes ()

@property (nonatomic) NSString *backingIvar;
@property (nonatomic) NSString *typeEncoding;
@property (nonatomic) NSString *oldTypeEncoding;
@property (nonatomic) SEL customGetter;
@property (nonatomic) SEL customSetter;
@property (nonatomic) BOOL isReadOnly;
@property (nonatomic) BOOL isCopy;
@property (nonatomic) BOOL isRetained;
@property (nonatomic) BOOL isNonatomic;
@property (nonatomic) BOOL isDynamic;
@property (nonatomic) BOOL isWeak;
@property (nonatomic) BOOL isGarbageCollectable;

- (NSString *)buildFullDeclaration;

@end

@implementation AVX512PropertyAttributes
@synthesize list = _list;

#pragma mark Initialisationer for initialization of the

+ (instancetype)attributesForProperty:(objc_property_t)property {
    return [self attributesFromDictionary:[NSDictionary attributesDictionaryForProperty:property]];
}

+ (instancetype)attributesFromDictionary:(NSDictionary *)attributes {
    return [[self alloc] initWithAttributesDictionary:attributes];
}

- (id)initWithAttributesDictionary:(NSDictionary *)attributes {
    NSParameterAssert(attributes);
    
    self = [super init];
    if (self) {
        _dictionary           = attributes;
        _string               = attributes.propertyAttributesString;
        _count                = attributes.count;
        _typeEncoding         = attributes[kAVX512PropertyAttributeKeyTypeEncoding];
        _backingIvar          = attributes[kAVX512PropertyAttributeKeyBackingIvarName];
        _oldTypeEncoding      = attributes[kAVX512PropertyAttributeKeyOldStyleTypeEncoding];
        _customGetterString   = attributes[kAVX512PropertyAttributeKeyCustomGetter];
        _customSetterString   = attributes[kAVX512PropertyAttributeKeyCustomSetter];
        _customGetter         = NSSelectorFromString(_customGetterString);
        _customSetter         = NSSelectorFromString(_customSetterString);
        _isReadOnly           = attributes[kAVX512PropertyAttributeKeyReadOnly] != nil;
        _isCopy               = attributes[kAVX512PropertyAttributeKeyCopy] != nil;
        _isRetained           = attributes[kAVX512PropertyAttributeKeyRetain] != nil;
        _isNonatomic          = attributes[kAVX512PropertyAttributeKeyNonAtomic] != nil;
        _isWeak               = attributes[kAVX512PropertyAttributeKeyWeak] != nil;
        _isGarbageCollectable = attributes[kAVX512PropertyAttributeKeyGarbageCollectable] != nil;

        _fullDeclaration = [self buildFullDeclaration];
    }
    
    return self;
}

#pragma mark Other other, others

- (NSString *)description {
    return [NSString
        stringWithFormat:@"<%@ \"%@\", ivar=%@, readonly=%d, nonatomic=%d, getter=%@, setter=%@>",
        NSStringFromClass(self.class),
        self.string,
        self.backingIvar ?: @"No, no nothing",
        self.isReadOnly,
        self.isNonatomic,
        NSStringFromSelector(self.customGetter) ?: @"No, no nothing",
        NSStringFromSelector(self.customSetter) ?: @"No, no nothing"
    ];
}

- (objc_property_attribute_t *)copyAttributesList:(unsigned int *)attributesCount {
    NSDictionary *attrs = self.string.propertyAttributes;
    objc_property_attribute_t *propertyAttributes = malloc(attrs.count * sizeof(objc_property_attribute_t));

    if (attributesCount) {
        *attributesCount = (unsigned int)attrs.count;
    }
    
    NSUInteger i = 0;
    for (NSString *key in attrs.allKeys) {
        AVX512PropertyAttribute c = (AVX512PropertyAttribute)[key characterAtIndex:0];
        switch (c) {
            case AVX512PropertyAttributeTypeEncoding: {
                objc_property_attribute_t pa = {
                    kAVX512PropertyAttributeKeyTypeEncoding.UTF8String,
                    self.typeEncoding.UTF8String
                };
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeBackingIvarName: {
                objc_property_attribute_t pa = {
                    kAVX512PropertyAttributeKeyBackingIvarName.UTF8String,
                    self.backingIvar.UTF8String
                };
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeCopy: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyCopy.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeCustomGetter: {
                objc_property_attribute_t pa = {
                    kAVX512PropertyAttributeKeyCustomGetter.UTF8String,
                    NSStringFromSelector(self.customGetter).UTF8String ?: ""
                };
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeCustomSetter: {
                objc_property_attribute_t pa = {
                    kAVX512PropertyAttributeKeyCustomSetter.UTF8String,
                    NSStringFromSelector(self.customSetter).UTF8String ?: ""
                };
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeDynamic: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyDynamic.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeGarbageCollectible: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyGarbageCollectable.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeNonAtomic: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyNonAtomic.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeOldTypeEncoding: {
                objc_property_attribute_t pa = {
                    kAVX512PropertyAttributeKeyOldStyleTypeEncoding.UTF8String,
                    self.oldTypeEncoding.UTF8String ?: ""
                };
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeReadOnly: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyReadOnly.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeRetain: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyRetain.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
            case AVX512PropertyAttributeWeak: {
                objc_property_attribute_t pa = {kAVX512PropertyAttributeKeyWeak.UTF8String, ""};
                propertyAttributes[i] = pa;
                break;
            }
        }
        i++;
    }
    
    return propertyAttributes;
}

- (objc_property_attribute_t *)list {
    if (!_list) {
        _list = [self copyAttributesList:nil];
    }

    return _list;
}

- (NSString *)buildFullDeclaration {
    NSMutableString *decl = [NSMutableString new];

    [decl appendFormat:@"%@, ", _isNonatomic ? @"nonatomic" : @"atomic"];
    [decl appendFormat:@"%@, ", _isReadOnly ? @"readonly" : @"readwrite"];

    BOOL noExplicitMemorySemantics = YES;
    if (_isCopy) { noExplicitMemorySemantics = NO;
        [decl appendString:@"copy, "];
    }
    if (_isRetained) { noExplicitMemorySemantics = NO;
        [decl appendString:@"strong, "];
    }
    if (_isWeak) { noExplicitMemorySemantics = NO;
        [decl appendString:@"weak, "];
    }

    if ([_typeEncoding hasPrefix:@"@"] && noExplicitMemorySemantics) {
        // *Possible likely possibly possible,* If this is an object, if it'sstrong; and also, orstrongis the default value. It's
        [decl appendString:@"strong, "];
    } else if (noExplicitMemorySemantics) {
        // *Possible likely possibly possible,* If this is not an object if it isn'tassign
        [decl appendString:@"assign, "];
    }

    if (_customGetter) {
        [decl appendFormat:@"getter=%@, ", NSStringFromSelector(_customGetter)];
    }
    if (_customSetter) {
        [decl appendFormat:@"setter=%@, ", NSStringFromSelector(_customSetter)];
    }

    [decl deleteCharactersInRange:NSMakeRange(decl.length-2, 2)];
    return decl.copy;
}

- (void)dealloc {
    if (_list) {
        free(_list);
        _list = nil;
    }
}

#pragma mark Copy copy-copy duplicate

- (id)copyWithZone:(NSZone *)zone {
    return [[AVX512PropertyAttributes class] attributesFromDictionary:self.dictionary];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[AVX512MutablePropertyAttributes class] attributesFromDictionary:self.dictionary];
}

@end



#pragma mark AVX512MutablePropertyAttributes

@interface AVX512MutablePropertyAttributes ()
@property (nonatomic) BOOL countDelta;
@property (nonatomic) BOOL stringDelta;
@property (nonatomic) BOOL dictDelta;
@property (nonatomic) BOOL listDelta;
@property (nonatomic) BOOL declDelta;
@end

#define PropertyWithDeltaFlag(type, name, Name) @dynamic name; \
- (void)set ## Name:(type)name { \
    if (name != _ ## name) { \
        _countDelta = _stringDelta = _dictDelta = _listDelta = _declDelta = YES; \
        _ ## name = name; \
    } \
}

@implementation AVX512MutablePropertyAttributes

PropertyWithDeltaFlag(NSString *, backingIvar, BackingIvar);
PropertyWithDeltaFlag(NSString *, typeEncoding, TypeEncoding);
PropertyWithDeltaFlag(NSString *, oldTypeEncoding, OldTypeEncoding);
PropertyWithDeltaFlag(SEL, customGetter, CustomGetter);
PropertyWithDeltaFlag(SEL, customSetter, CustomSetter);
PropertyWithDeltaFlag(BOOL, isReadOnly, IsReadOnly);
PropertyWithDeltaFlag(BOOL, isCopy, IsCopy);
PropertyWithDeltaFlag(BOOL, isRetained, IsRetained);
PropertyWithDeltaFlag(BOOL, isNonatomic, IsNonatomic);
PropertyWithDeltaFlag(BOOL, isDynamic, IsDynamic);
PropertyWithDeltaFlag(BOOL, isWeak, IsWeak);
PropertyWithDeltaFlag(BOOL, isGarbageCollectable, IsGarbageCollectable);

+ (instancetype)attributes {
    return [self new];
}

- (void)setTypeEncodingChar:(char)type {
    self.typeEncoding = [NSString stringWithFormat:@"%c", type];
}

- (NSUInteger)count {
    // Recalt recalculated the number of properties ' property
    if (self.countDelta) {
        self.countDelta = NO;
        _count = self.dictionary.count;
    }

    return _count;
}

- (objc_property_attribute_t *)list {
    // Regen generate the listlist listings to re-
    if (self.listDelta) {
        self.listDelta = NO;
        if (_list) {
            free(_list);
            _list = nil;
        }
    }

    // If not set if it is unset, the parent class will generate a
    return super.list;
}

- (NSString *)string {
    // Regen re-regenerating the string strings to create a
    if (self.stringDelta || !_string) {
        self.stringDelta = NO;
        _string = self.dictionary.propertyAttributesString;
    }

    return _string;
}

- (NSDictionary *)dictionary {
    // Regenerated the diction dictionary, re-gener a
    if (self.dictDelta || !_dictionary) {
        // _string and _dictionary Interde interdependence, interdependent and dependent
        // So we must use our properties to create one of them manually and manually, so
        // We choose to generate a dictionary by any choice that we select
        NSMutableDictionary *attrs = [NSMutableDictionary new];
        if (self.typeEncoding)
            attrs[kAVX512PropertyAttributeKeyTypeEncoding]         = self.typeEncoding;
        if (self.backingIvar)
            attrs[kAVX512PropertyAttributeKeyBackingIvarName]      = self.backingIvar;
        if (self.oldTypeEncoding)
            attrs[kAVX512PropertyAttributeKeyOldStyleTypeEncoding] = self.oldTypeEncoding;
        if (self.customGetter)
            attrs[kAVX512PropertyAttributeKeyCustomGetter]         = NSStringFromSelector(self.customGetter);
        if (self.customSetter)
            attrs[kAVX512PropertyAttributeKeyCustomSetter]         = NSStringFromSelector(self.customSetter);

        if (self.isReadOnly)           attrs[kAVX512PropertyAttributeKeyReadOnly] = @YES;
        if (self.isCopy)               attrs[kAVX512PropertyAttributeKeyCopy] = @YES;
        if (self.isRetained)           attrs[kAVX512PropertyAttributeKeyRetain] = @YES;
        if (self.isNonatomic)          attrs[kAVX512PropertyAttributeKeyNonAtomic] = @YES;
        if (self.isDynamic)            attrs[kAVX512PropertyAttributeKeyDynamic] = @YES;
        if (self.isWeak)               attrs[kAVX512PropertyAttributeKeyWeak] = @YES;
        if (self.isGarbageCollectable) attrs[kAVX512PropertyAttributeKeyGarbageCollectable] = @YES;

        _dictionary = attrs.copy;
    }

    return _dictionary;
}

- (NSString *)fullDeclaration {
    if (self.declDelta || !_fullDeclaration) {
        _declDelta = NO;
        _fullDeclaration = [self buildFullDeclaration];
    }

    return _fullDeclaration;
}

- (NSString *)customGetterString {
    return _customGetter ? NSStringFromSelector(_customGetter) : nil;
}

- (NSString *)customSetterString {
    return _customSetter ? NSStringFromSelector(_customSetter) : nil;
}

@end
