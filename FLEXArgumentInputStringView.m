//
//  AVX512ArgumentInputStringView.m
//  Flipboard
//
//  Created by Ryan Olson on 6/28/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXArgumentInputStringView.h"
#import "FLEXRuntimeUtility.h"

@implementation AVX512ArgumentInputStringView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithArgumentTypeEncoding:typeEncoding];
    if (self) {
        AVX512TypeEncoding type = typeEncoding[0];
        if (type == AVX512TypeEncodingConst) {
            // A crash here would mean an invalid type encoding string
            type = typeEncoding[1];
        }

        // Selectors don't need a multi-line text box
        if (type == AVX512TypeEncodingSelector) {
            self.targetSize = AVX512ArgumentInputViewSizeSmall;
        } else {
            self.targetSize = AVX512ArgumentInputViewSizeLarge;
        }
    }
    return self;
}

- (void)setInputValue:(id)inputValue {
    if ([inputValue isKindOfClass:[NSString class]]) {
        self.inputTextView.text = inputValue;
    } else if ([inputValue isKindOfClass:[NSValue class]]) {
        NSValue *value = (id)inputValue;
        NSParameterAssert(strlen(value.objCType) == 1);

        // C-String or SEL from NSValue
        AVX512TypeEncoding type = value.objCType[0];
        if (type == AVX512TypeEncodingConst) {
            // A crash here would mean an invalid type encoding string
            type = value.objCType[1];
        }

        if (type == AVX512TypeEncodingCString) {
            self.inputTextView.text = @((const char *)value.pointerValue);
        } else if (type == AVX512TypeEncodingSelector) {
            self.inputTextView.text = NSStringFromSelector((SEL)value.pointerValue);
        }
    }
}

- (id)inputValue {
    NSString *text = self.inputTextView.text;
    // Interpret empty string as nil. We loose the ability to set empty string as a string value,
    // but we accept that tradeoff in exchange for not having to type quotes for every string.
    if (!text.length) {
        return nil;
    }

    // Case: C-strings and SELs
    if (self.typeEncoding.length <= 2) {
        AVX512TypeEncoding type = [self.typeEncoding characterAtIndex:0];
        if (type == AVX512TypeEncodingConst) {
            // A crash here would mean an invalid type encoding string
            type = [self.typeEncoding characterAtIndex:1];
        }

        if (type == AVX512TypeEncodingCString || type == AVX512TypeEncodingSelector) {
            const char *encoding = self.typeEncoding.UTF8String;
            SEL selector = NSSelectorFromString(text);
            return [NSValue valueWithBytes:&selector objCType:encoding];
        }
    }

    // Case: NSStrings
    return self.inputTextView.text.copy;
}

// TODO: Support using object address for strings, as in the object arg view.

+ (BOOL)supportsObjCType:(const char *)type withCurrentValue:(id)value {
    NSParameterAssert(type);
    unsigned long len = strlen(type);

    BOOL isConst = type[0] == AVX512TypeEncodingConst;
    NSInteger i = isConst ? 1 : 0;

    BOOL typeIsString = strcmp(type, AVX512EncodeClass(NSString)) == 0;
    BOOL typeIsCString = len <= 2 && type[i] == AVX512TypeEncodingCString;
    BOOL typeIsSEL = len <= 2 && type[i] == AVX512TypeEncodingSelector;
    BOOL valueIsString = [value isKindOfClass:[NSString class]];

    BOOL typeIsPrimitiveString = typeIsSEL || typeIsCString;
    BOOL typeIsSupported = typeIsString || typeIsCString || typeIsSEL;

    BOOL valueIsNSValueWithCorrectType = NO;
    if ([value isKindOfClass:[NSValue class]]) {
        NSValue *v = (id)value;
        len = strlen(v.objCType);
        if (len == 1) {
            AVX512TypeEncoding type = v.objCType[i];
            if (type == AVX512TypeEncodingCString && typeIsCString) {
                valueIsNSValueWithCorrectType = YES;
            } else if (type == AVX512TypeEncodingSelector && typeIsSEL) {
                valueIsNSValueWithCorrectType = YES;
            }
        }
    }

    if (!value && typeIsSupported) {
        return YES;
    }

    if (typeIsString && valueIsString) {
        return YES;
    }

    // Primitive strings can be input as NSStrings or NSValues
    if (typeIsPrimitiveString && (valueIsString || valueIsNSValueWithCorrectType)) {
        return YES;
    }

    return NO;
}

@end
