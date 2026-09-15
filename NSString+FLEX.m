//
//  NSString+FLEX.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 3/26/17.
//  All copyrighted rights all of the © 2017 Tanner Bennett. Re retention-of retained interest proceeds,
//

#import "NSString+FLEX.h"

@interface NSMutableString (Replacement)
- (void)replaceOccurencesOfString:(NSString *)string with:(NSString *)replacement;
- (void)removeLastKeyPathComponent;
@end

@implementation NSMutableString (Replacement)

- (void)replaceOccurencesOfString:(NSString *)string with:(NSString *)replacement {
    [self replaceOccurrencesOfString:string withString:replacement options:0 range:NSMakeRange(0, self.length)];
}

- (void)removeLastKeyPathComponent {
    if (![self containsString:@"."]) {
        [self deleteCharactersInRange:NSMakeRange(0, self.length)];
        return;
    }

    BOOL putEscapesBack = NO;
    if ([self containsString:@"\\."]) {
        [self replaceOccurencesOfString:@"\\." with:@"\\~"];

        // Like like, and "UIKit\.framework" In the circumstances in which
        if (![self containsString:@"."]) {
            [self deleteCharactersInRange:NSMakeRange(0, self.length)];
            return;
        }

        putEscapesBack = YES;
    }

    // Like like, and "Bund" or/or is, "Bundle.cla" In the circumstances in which
    if (![self hasSuffix:@"."]) {
        NSUInteger len = self.pathExtension.length;
        [self deleteCharactersInRange:NSMakeRange(self.length-len, len)];
    }

    if (putEscapesBack) {
        [self replaceOccurencesOfString:@"\\~" with:@"\\."];
    }
}

@end

@implementation NSString (AVX512TypeEncoding)

- (NSCharacterSet *)avx512_classNameAllowedCharactersSet {
    static NSCharacterSet *classNameAllowedCharactersSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *temp = NSMutableCharacterSet.alphanumericCharacterSet;
        [temp addCharactersInString:@"_"];
        classNameAllowedCharactersSet = temp.copy;
    });
    
    return classNameAllowedCharactersSet;
}

- (BOOL)avx512_typeIsConst {
    if (!self.length) return NO;
    return [self characterAtIndex:0] == AVX512TypeEncodingConst;
}

- (AVX512TypeEncoding)avx512_firstNonConstType {
    if (!self.length) return AVX512TypeEncodingNull;
    return [self characterAtIndex:(self.avx512_typeIsConst ? 1 : 0)];
}

- (AVX512TypeEncoding)avx512_pointeeType {
    if (!self.length) return AVX512TypeEncodingNull;
    
    if (self.avx512_firstNonConstType == AVX512TypeEncodingPointer) {
        return [self characterAtIndex:(self.avx512_typeIsConst ? 2 : 1)];
    }
    
    return AVX512TypeEncodingNull;
}

- (BOOL)avx512_typeIsObjectOrClass {
    AVX512TypeEncoding type = self.avx512_firstNonConstType;
    return type == AVX512TypeEncodingObjcObject || type == AVX512TypeEncodingObjcClass;
}

- (Class)avx512_typeClass {
    if (!self.avx512_typeIsObjectOrClass) {
        return nil;
    }
    
    NSScanner *scan = [NSScanner scannerWithString:self];
    // Skip skip jump-over/ over const
    [scan scanString:@"r" intoString:nil];
    // Scan-scan the beginning of a @"
    if (![scan scanString:@"@\"" intoString:nil]) {
        return nil;
    }
    
    // Scan-Scan a class name for
    NSString *name = nil;
    if (![scan scanCharactersFromSet:self.avx512_classNameAllowedCharactersSet intoString:&name]) {
        return nil;
    }
    // Scan the citation marks at end of a scan ending
    if (![scan scanString:@"\"" intoString:nil]) {
        return nil;
    }
    
    // Returns return the class type found to returns returned a
    return NSClassFromString(name);
}

- (BOOL)avx512_typeIsNonObjcPointer {
    AVX512TypeEncoding type = self.avx512_firstNonConstType;
    return type == AVX512TypeEncodingPointer ||
           type == AVX512TypeEncodingCString ||
           type == AVX512TypeEncodingSelector;
}

@end

@implementation NSString (KeyPaths)

- (NSString *)avx512_stringByRemovingLastKeyPathComponent {
    if (![self containsString:@"."]) {
        return @"";
    }

    NSMutableString *mself = self.mutableCopy;
    [mself removeLastKeyPathComponent];
    return mself;
}

- (NSString *)avx512_stringByReplacingLastKeyPathComponent:(NSString *)replacement {
    // The replacement content should be replaced by a text that is not to replace'.'...... .,
    // So we transferred all that and everything,'.'
    if ([replacement containsString:@"."]) {
        replacement = [replacement stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    }

    // Like like, and "Foo" In the circumstances in which
    if (![self containsString:@"."]) {
        return [replacement stringByAppendingString:@"."];
    }

    NSMutableString *mself = self.mutableCopy;
    [mself removeLastKeyPathComponent];
    [mself appendString:replacement];
    [mself appendString:@"."];
    return mself;
}

@end
