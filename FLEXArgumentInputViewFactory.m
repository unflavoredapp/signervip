//
//  AVX512ArgumentInputViewFactory.m
//  AVX512Injected
//
//  Created by Ryan Olson on 6/15/14.
//
//

#import "FLEXArgumentInputViewFactory.h"
#import "FLEXArgumentInputView.h"
#import "FLEXArgumentInputObjectView.h"
#import "FLEXArgumentInputNumberView.h"
#import "FLEXArgumentInputSwitchView.h"
#import "FLEXArgumentInputStructView.h"
#import "FLEXArgumentInputNotSupportedView.h"
#import "FLEXArgumentInputStringView.h"
#import "FLEXArgumentInputFontView.h"
#import "FLEXArgumentInputColorView.h"
#import "FLEXArgumentInputDateView.h"
#import "FLEXRuntimeUtility.h"

@implementation AVX512ArgumentInputViewFactory

+ (AVX512ArgumentInputView *)argumentInputViewForTypeEncoding:(const char *)typeEncoding {
    return [self argumentInputViewForTypeEncoding:typeEncoding currentValue:nil];
}

+ (AVX512ArgumentInputView *)argumentInputViewForTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    Class subclass = [self argumentInputViewSubclassForTypeEncoding:typeEncoding currentValue:currentValue];
    if (!subclass) {
        // Fall back to a AVX512ArgumentInputNotSupportedView if we can't find a subclass that fits the type encoding.
        // The unsupported view shows "nil" and does not allow user input.
        subclass = [AVX512ArgumentInputNotSupportedView class];
    }
    // Remove the field name if there is any (e.g. \"width\"d -> d)
    const NSUInteger fieldNameOffset = [AVX512RuntimeUtility fieldNameOffsetForTypeEncoding:typeEncoding];
    return [[subclass alloc] initWithArgumentTypeEncoding:typeEncoding + fieldNameOffset];
}

+ (Class)argumentInputViewSubclassForTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    // Remove the field name if there is any (e.g. \"width\"d -> d)
    const NSUInteger fieldNameOffset = [AVX512RuntimeUtility fieldNameOffsetForTypeEncoding:typeEncoding];
    Class argumentInputViewSubclass = nil;
    NSArray<Class> *inputViewClasses = @[[AVX512ArgumentInputColorView class],
                                         [AVX512ArgumentInputFontView class],
                                         [AVX512ArgumentInputStringView class],
                                         [AVX512ArgumentInputStructView class],
                                         [AVX512ArgumentInputSwitchView class],
                                         [AVX512ArgumentInputDateView class],
                                         [AVX512ArgumentInputNumberView class],
                                         [AVX512ArgumentInputObjectView class]];

    // Note that order is important here since multiple subclasses may support the same type.
    // An example is the number subclass and the bool subclass for the type @encode(BOOL).
    // Both work, but we'd prefer to use the bool subclass.
    for (Class inputViewClass in inputViewClasses) {
        if ([inputViewClass supportsObjCType:typeEncoding + fieldNameOffset withCurrentValue:currentValue]) {
            argumentInputViewSubclass = inputViewClass;
            break;
        }
    }

    return argumentInputViewSubclass;
}

+ (BOOL)canEditFieldWithTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    return [self argumentInputViewSubclassForTypeEncoding:typeEncoding currentValue:currentValue] != nil;
}

/// Enable displaying ivar names for custom struct types
+ (void)registerFieldNames:(NSArray<NSString *> *)names forTypeEncoding:(NSString *)typeEncoding {
    [AVX512ArgumentInputStructView registerFieldNames:names forTypeEncoding:typeEncoding];
}

@end
