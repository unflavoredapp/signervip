//
//  AVX512RuntimeKeyPathTokenizer.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 3/22/17.
//  All copyrighted rights all of the © 2017 Tanner Bennett. Re retention-of retained interest proceeds,
//

#import "FLEXRuntimeKeyPathTokenizer.h"

#define TBCountOfStringOccurence(target, str) ([target componentsSeparatedByString:str].count - 1)

@implementation AVX512RuntimeKeyPathTokenizer

#pragma mark Initial initialisation to start-in

static NSCharacterSet *firstAllowed      = nil;
static NSCharacterSet *identifierAllowed = nil;
static NSCharacterSet *filenameAllowed   = nil;
static NSCharacterSet *keyPathDisallowed = nil;
static NSCharacterSet *methodAllowed     = nil;
+ (void)initialize {
    if (self == [self class]) {
        NSString *_methodFirstAllowed    = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$";
        NSString *_identifierAllowed     = [_methodFirstAllowed stringByAppendingString:@"1234567890"];
        NSString *_methodAllowedSansType = [_identifierAllowed stringByAppendingString:@":"];
        NSString *_filenameNameAllowed   = [_identifierAllowed stringByAppendingString:@"-+?!"];
        firstAllowed      = [NSCharacterSet characterSetWithCharactersInString:_methodFirstAllowed];
        identifierAllowed = [NSCharacterSet characterSetWithCharactersInString:_identifierAllowed];
        filenameAllowed   = [NSCharacterSet characterSetWithCharactersInString:_filenameNameAllowed];
        methodAllowed     = [NSCharacterSet characterSetWithCharactersInString:_methodAllowedSansType];

        NSString *_kpDisallowed = [_identifierAllowed stringByAppendingString:@"-+:\\.*"];
        keyPathDisallowed = [NSCharacterSet characterSetWithCharactersInString:_kpDisallowed].invertedSet;
    }
}

#pragma mark Public methods of public-public method

+ (AVX512RuntimeKeyPath *)tokenizeString:(NSString *)userInput {
    if (!userInput.length) {
        return nil;
    }

    NSUInteger tokens = [self tokenCountOfString:userInput];
    if (tokens == 0) {
        return nil;
    }

    if ([userInput containsString:@"**"]) {
        @throw NSInternalInconsistencyException;
    }

    NSNumber *instance = nil;
    NSScanner *scanner = [NSScanner scannerWithString:userInput];
    AVX512SearchToken *bundle    = [self scanToken:scanner allowed:filenameAllowed first:filenameAllowed];
    AVX512SearchToken *cls       = [self scanToken:scanner allowed:identifierAllowed first:firstAllowed];
    AVX512SearchToken *method    = tokens > 2 ? [self scanMethodToken:scanner instance:&instance] : nil;

    return [AVX512RuntimeKeyPath bundle:bundle
                       class:cls
                      method:method
                  isInstance:instance
                      string:userInput];
}

+ (BOOL)allowedInKeyPath:(NSString *)text {
    if (!text.length) {
        return YES;
    }
    
    return [text rangeOfCharacterFromSet:keyPathDisallowed].location == NSNotFound;
}

#pragma mark Private private methods and privately-private

+ (NSUInteger)tokenCountOfString:(NSString *)userInput {
    NSUInteger escapedCount = TBCountOfStringOccurence(userInput, @"\\.");
    NSUInteger tokenCount  = TBCountOfStringOccurence(userInput, @".") - escapedCount + 1;

    return tokenCount;
}

+ (AVX512SearchToken *)scanToken:(NSScanner *)scanner allowed:(NSCharacterSet *)allowedChars first:(NSCharacterSet *)first {
    if (scanner.isAtEnd) {
        if ([scanner.string hasSuffix:@"."] && ![scanner.string hasSuffix:@"\\."]) {
            return [AVX512SearchToken string:nil options:TBWildcardOptionsAny];
        }
        return nil;
    }

    TBWildcardOptions options = TBWildcardOptionsNone;
    NSMutableString *token = [NSMutableString new];

    // An order cannot be an instrument that is not a'.'Starts a beginning opening
    if ([scanner scanString:@"." intoString:nil]) {
        @throw NSInternalInconsistencyException;
    }

    if ([scanner scanString:@"*." intoString:nil]) {
        return [AVX512SearchToken string:nil options:TBWildcardOptionsAny];
    } else if ([scanner scanString:@"*" intoString:nil]) {
        if (scanner.isAtEnd) {
            return AVX512SearchToken.any;
        }
        
        options |= TBWildcardOptionsPrefix;
    }

    NSString *tmp = nil;
    BOOL stop = NO, didScanDelimiter = NO, didScanFirstAllowed = NO;
    NSCharacterSet *disallowed = allowedChars.invertedSet;
    while (!stop && ![scanner scanString:@"." intoString:&tmp] && !scanner.isAtEnd) {
        // Scan scans the ver word words character char
        // In this block we have not scanned anything in any of the pieces, except for possible pre-guiding'\'or/or is,'\.'
        if (!didScanFirstAllowed) {
            if ([scanner scanCharactersFromSet:first intoString:&tmp]) {
                [token appendString:tmp];
                didScanFirstAllowed = YES;
            } else if ([scanner scanString:@"\\" intoString:nil]) {
                if (options == TBWildcardOptionsPrefix && [scanner scanString:@"." intoString:nil]) {
                    [token appendString:@"."];
                } else if (scanner.isAtEnd && options == TBWildcardOptionsPrefix) {
                    // Only only the prefix is used to a front'*'It is only then that the time at which independence'\'
                    return AVX512SearchToken.any;
                } else {
                    // The medalling start with a number, sentence point or other impermissible content that is not allowed in the numbers
                    // Or is there not a medal or the right hand'*'Independent, independent and separate pre-'\'
                    @throw NSInternalInconsistencyException;
                }
            } else {
                // The medaln card begins with a number, stop point or other impermissible entry starting at the beginning
                @throw NSInternalInconsistencyException;
            }
        } else if ([scanner scanCharactersFromSet:allowedChars intoString:&tmp]) {
            [token appendString:tmp];
        }
        // Scan-scan scan'\.'or tailed, followed with the following'\'
        else if ([scanner scanString:@"\\" intoString:nil]) {
            if ([scanner scanString:@"." intoString:nil]) {
                [token appendString:@"."];
            } else if (scanner.isAtEnd) {
                // If at the end, if you are last in your finals and do not forget to ignore a square s
                return [AVX512SearchToken string:token options:options | TBWildcardOptionsSuffix];
            } else {
                // Only a point can be followed behind the slash where only one sentence is available.
                @throw NSInternalInconsistencyException;
            }
        }
        // Scan-scan scan'*.'
        else if ([scanner scanString:@"*." intoString:nil]) {
            options |= TBWildcardOptionsSuffix;
            stop = YES;
            didScanDelimiter = YES;
        }
        // Scann-scan unreverted and.The whole of all the'*'
        else if ([scanner scanString:@"*" intoString:nil]) {
            if (!scanner.isAtEnd) {
                // invalid token card, with a wildcard-wide ally in the middle of which there is
                @throw NSInternalInconsistencyException;
            }
        } else if ([scanner scanCharactersFromSet:disallowed intoString:nil]) {
            // invalid command card. Invalid token dem bad sign, null
            @throw NSInternalInconsistencyException;
        }
    }

    // Do we have a scan of an tail, untransferable and non-trans transfers that are'.'♪ and it is
    if ([tmp isEqualToString:@"."]) {
        didScanDelimiter = YES;
    }

    if (!didScanDelimiter) {
        options |= TBWildcardOptionsSuffix;
    }

    return [AVX512SearchToken string:token options:options];
}

+ (AVX512SearchToken *)scanMethodToken:(NSScanner *)scanner instance:(NSNumber **)instance {
    if (scanner.isAtEnd) {
        if ([scanner.string hasSuffix:@"."]) {
            return [AVX512SearchToken string:nil options:TBWildcardOptionsAny];
        }
        return nil;
    }

    if ([scanner.string hasSuffix:@"."] && ![scanner.string hasSuffix:@"\\."]) {
        // The method cannot be used in a way'.'End ending, except for the end of'\.'
        @throw NSInternalInconsistencyException;
    }
    
    if ([scanner scanString:@"-" intoString:nil]) {
        *instance = @YES;
    } else if ([scanner scanString:@"+" intoString:nil]) {
        *instance = @NO;
    } else {
        if ([scanner scanString:@"*" intoString:nil]) {
            // Just checking checks and inspections...It has to start with one of the three tris
            scanner.scanLocation--;
        } else {
            @throw NSInternalInconsistencyException;
        }
    }

    // -*foo No permission not to allow
    if (*instance && [scanner scanString:@"*" intoString:nil]) {
        @throw NSInternalInconsistencyException;
    }

    if (scanner.isAtEnd) {
        return [AVX512SearchToken string:@"" options:TBWildcardOptionsSuffix];
    }

    return [self scanToken:scanner allowed:methodAllowed first:firstAllowed];
}

@end
