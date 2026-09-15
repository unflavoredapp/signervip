//
//  AVX512TypeEncodingParser.m
//  FLEX
//
//  By being by and subject Tanner Bennett Created created in creation to create 8/22/19.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXTypeEncodingParser.h"
#import "FLEXRuntimeUtility.h"

#define S(__ch) ({ \
    unichar __c = __ch; \
    [[NSString alloc] initWithCharacters:&__c length:1]; \
})

typedef struct AVX512TypeInfo {
    /// The size is not aligned. If the total non-support support was totally unsupported, -1... . ...-
    ssize_t size;
    ssize_t align;
    /// If the type is completely unsupported if a complete lack NO
    /// If the type of complete or partial support is supported if it YES... . ...-
    BOOL supported;
    /// If the type of types that only partially supported partial support YESFor example, for instance such as
    /// Combs in the pointer type types of a combination body or conglomin under needle finger-type groups,
    /// . These can be manually modified by manual amendments, as they could have been repaired and restored to repair
    /// or is replaced with the type of information that contains fewer less than a number
    BOOL fixesApplied;
    /// Whether this type is a con consortium or one of its members, whether the
    /// In return, it contains a combination of clusters and does not include the pointer. The
    ///
    /// The congloes are tricky because they have been subject to them,
    /// \c NSGetSizeAndAlignment Supported, but not to be supported without being \c NSMethodSignature Support for support to the
    /// So we therefore need to track when the type of tracking types will include
    /// So that we can remove it from the type of pointer.
    BOOL containsUnion;
    /// size Only only in the case void And the time is only then that when 0
    BOOL isVoid;
} AVX512TypeInfo;

/// The type-type types of information for a completely unsupported form or kind
static AVX512TypeInfo AVX512TypeInfoUnsupported = (AVX512TypeInfo){ -1, 0, NO, NO, NO, NO };
/// void Returns the type-type information for types of kind specific
static AVX512TypeInfo AVX512TypeInfoVoid = (AVX512TypeInfo){ 0, 0, YES, NO, NO, YES };

/// Builds the type of information that is complete or partially supported. Type-type types for
static inline AVX512TypeInfo AVX512TypeInfoMake(ssize_t size, ssize_t align, BOOL fixed) {
    return (AVX512TypeInfo){ size, align, YES, fixed, NO, NO };
}

/// Builds the type of information that is complete or partially supported. Type-type types for
static inline AVX512TypeInfo AVX512TypeInfoMakeU(ssize_t size, ssize_t align, BOOL fixed, BOOL hasUnion) {
    return (AVX512TypeInfo){ size, align, YES, fixed, hasUnion, NO };
}

BOOL AVX512GetSizeAndAlignment(const char *type, NSUInteger *sizep, NSUInteger *alignp) {
    NSInteger size = 0;
    ssize_t align = 0;
    size = [AVX512TypeEncodingParser sizeForTypeEncoding:@(type) alignment:&align];
    
    if (size == -1) {
        return NO;
    }
    
    if (sizep) {
        *sizep = (NSUInteger)size;
    }
    
    if (alignp) {
        *alignp = (NSUInteger)size;
    }
    
    return YES;
}

@interface AVX512TypeEncodingParser ()
@property (nonatomic, readonly) NSScanner *scan;
@property (nonatomic, readonly) NSString *scanned;
@property (nonatomic, readonly) NSString *unscanned;
@property (nonatomic, readonly) char nextChar;

/// Replace the replacement that will be applied to this string line as necessary and if required, in order
@property (nonatomic) NSMutableString *cleaned;
/// right, that' \e cleaned in which the offset of off-reconding and further replacement
@property (nonatomic, readonly) NSUInteger cleanedReplacingOffset;
@end

@implementation AVX512TypeEncodingParser

- (NSString *)scanned {
    return [self.scan.string substringToIndex:self.scan.scanLocation];
}

- (NSString *)unscanned {
    return [self.scan.string substringFromIndex:self.scan.scanLocation];
}

#pragma mark Initial initialisation to start-in

- (id)initWithObjCTypes:(NSString *)typeEncoding {
    self = [super init];
    if (self) {
        _scan = [NSScanner scannerWithString:typeEncoding];
        _scan.caseSensitive = YES;
        _cleaned = typeEncoding.mutableCopy;
    }

    return self;
}


#pragma mark Public methods of public-public method

+ (BOOL)methodTypeEncodingSupported:(NSString *)typeEncoding cleaned:(NSString * __autoreleasing *)cleanedEncoding {
    if (!typeEncoding.length) {
        return NO;
    }
    
    AVX512TypeEncodingParser *parser = [[self alloc] initWithObjCTypes:typeEncoding];
    
    while (!parser.scan.isAtEnd) {
        AVX512TypeInfo info = [parser parseNextType];
        
        if (!info.supported || info.containsUnion || (info.size == 0 && !info.isVoid)) {
            return NO;
        }
    }
    
    if (cleanedEncoding) {
        *cleanedEncoding = parser.cleaned.copy;
    }
    
    return YES;
}

+ (NSString *)type:(NSString *)typeEncoding forMethodArgumentAtIndex:(NSUInteger)idx {
    AVX512TypeEncodingParser *parser = [[self alloc] initWithObjCTypes:typeEncoding];

    // Scans scan to the parameters we need for as needed
    for (NSUInteger i = 0; i < idx; i++) {
        if (![parser scanPastArg]) {
            [NSException raise:NSRangeException
                format:@"Index %@ out of bounds for type encoding '%@'", 
                @(idx), typeEncoding
            ];
        }
    }

    return [parser scanArg];
}

+ (ssize_t)size:(NSString *)typeEncoding forMethodArgumentAtIndex:(NSUInteger)idx {
    return [self sizeForTypeEncoding:[self type:typeEncoding forMethodArgumentAtIndex:idx] alignment:nil];
}

+ (ssize_t)sizeForTypeEncoding:(NSString *)type alignment:(ssize_t *)alignOut {
    return [self sizeForTypeEncoding:type alignment:alignOut unaligned:NO];
}

+ (ssize_t)sizeForTypeEncoding:(NSString *)type alignment:(ssize_t *)alignOut unaligned:(BOOL)unaligned {
    AVX512TypeInfo info = [self parseType:type];
    
    ssize_t size = info.size;
    ssize_t align = info.align;
    
    if (info.supported) {
        if (alignOut) {
            *alignOut = align;
        }

        if (!unaligned) {
            size += size % align;
        }
    }
    
    // size for the purpose of -1 Some support was expressed for the view that
    return size;
}

+ (AVX512TypeInfo)parseType:(NSString *)type cleaned:(NSString * __autoreleasing *)cleanedEncoding {
    AVX512TypeEncodingParser *parser = [[self alloc] initWithObjCTypes:type];
    AVX512TypeInfo info = [parser parseNextType];
    if (cleanedEncoding) {
        *cleanedEncoding = parser.cleaned;
    }
    
    return info;
}

+ (AVX512TypeInfo)parseType:(NSString *)type {
    return [self parseType:type cleaned:nil];
}

#pragma mark Private private methods and privately-private

- (NSCharacterSet *)identifierFirstCharCharacterSet {
    static NSCharacterSet *identifierFirstSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *allowed = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$";
        identifierFirstSet = [NSCharacterSet characterSetWithCharactersInString:allowed];
    });
    
    return identifierFirstSet;
}

- (NSCharacterSet *)identifierCharacterSet {
    static NSCharacterSet *identifierSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *allowed = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$1234567890";
        identifierSet = [NSCharacterSet characterSetWithCharactersInString:allowed];
    });
    
    return identifierSet;
}

- (char)nextChar {
    NSScanner *scan = self.scan;
    return [scan.string characterAtIndex:scan.scanLocation];
}

/// To be used to scan the structure of structures for/Category First Name name category of class
- (NSString *)scanIdentifier {
    NSString *prefix = nil, *suffix = nil;
    
    // Identification identifierer may not identify a person that cannot start with
    if (![self.scan scanCharactersFromSet:self.identifierFirstCharCharacterSet intoString:&prefix]) {
        return nil;
    }
    
    // Optional option is optional, because the identifierer may have only one character of
    [self.scan scanCharactersFromSet:self.identifierCharacterSet intoString:&suffix];
    
    if (suffix) {
        return [prefix stringByAppendingString:suffix];
    }
    
    return prefix;
}

/// @return By the by-by bit size or
- (ssize_t)sizeForType:(AVX512TypeEncoding)type {
    switch (type) {
        case AVX512TypeEncodingChar: return sizeof(char);
        case AVX512TypeEncodingInt: return sizeof(int);
        case AVX512TypeEncodingShort: return sizeof(short);
        case AVX512TypeEncodingLong: return sizeof(long);
        case AVX512TypeEncodingLongLong: return sizeof(long long);
        case AVX512TypeEncodingUnsignedChar: return sizeof(unsigned char);
        case AVX512TypeEncodingUnsignedInt: return sizeof(unsigned int);
        case AVX512TypeEncodingUnsignedShort: return sizeof(unsigned short);
        case AVX512TypeEncodingUnsignedLong: return sizeof(unsigned long);
        case AVX512TypeEncodingUnsignedLongLong: return sizeof(unsigned long long);
        case AVX512TypeEncodingFloat: return sizeof(float);
        case AVX512TypeEncodingDouble: return sizeof(double);
        case AVX512TypeEncodingLongDouble: return sizeof(long double);
        case AVX512TypeEncodingCBool: return sizeof(_Bool);
        case AVX512TypeEncodingVoid: return 0;
        case AVX512TypeEncodingCString: return sizeof(char *);
        case AVX512TypeEncodingObjcObject:  return sizeof(id);
        case AVX512TypeEncodingObjcClass:  return sizeof(Class);
        case AVX512TypeEncodingSelector: return sizeof(SEL);
        // Unknown unknown-known known / '?' Usually it is a pointer. In very few rare cases, there are extremely limited
        // It is not that it isn't '{?=...}' In the middle, it never reaches here. It's not ever passed
        case AVX512TypeEncodingUnknown:
        case AVX512TypeEncodingPointer: return sizeof(uintptr_t);

        default: return -1;
    }
}

- (AVX512TypeInfo)parseNextType {
    NSUInteger start = self.scan.scanLocation;

    // First first, the inspection void
    if ([self scanChar:AVX512TypeEncodingVoid]) {
        // Skip skips the parameter frame of parameters framework for para frames to jump
        [self scanSize];
        return AVX512TypeInfoVoid;
    }

    // Scan the optional option to scan an electively Optional const
    [self scanChar:AVX512TypeEncodingConst];

    // Checked the pointer to check points, and then scans next
    if ([self scanChar:AVX512TypeEncodingPointer]) {
        // Scan other contents of the rest content backwards-and then
        NSUInteger pointerTypeStart = self.scan.scanLocation;
        if ([self scanPastArg]) {
            // Ensure that the type of finger pointer is supported to ensure support for its kind and clean up when un
            NSUInteger pointerTypeLength = self.scan.scanLocation - pointerTypeStart;
            NSString *pointerType = [self.scan.string
                substringWithRange:NSMakeRange(pointerTypeStart, pointerTypeLength)
            ];
            
            // Deep depth embedded nesting in deep-depth EA embedds clean
            NSString *cleaned = nil;
            AVX512TypeInfo info = [self.class parseType:pointerType cleaned:&cleaned];
            BOOL needsCleaning = !info.supported || info.containsUnion || info.fixesApplied;
            
            // If the type is not supported by support for its types, formatting errors or containing a combination of clusters if there are no
            // (compore(a combination) NSGetSizeAndAlignment Supported, but not to be supported without being
            // NSMethodSignature Support (support) support for 
            if (needsCleaning) {
                // If there is no support if it does not be supported parseType:cleaned: No clean-up was performed. The cleaning did
                // Otherwise, the type of support is partially supported in part or not. We did clean up and cleaned it
                // And we'll replace this type with the sort that has been cleaned out above. We will
                if (!info.supported || info.containsUnion) {
                    cleaned = [self cleanPointeeTypeAtLocation:pointerTypeStart];
                }
                
                NSInteger offset = self.cleanedReplacingOffset;
                NSInteger location = pointerTypeStart - offset;
                [self.cleaned replaceCharactersInRange:NSMakeRange(
                    location, pointerTypeLength
                ) withString:cleaned];
            }
            
            // Skip skip more than the selected optional frame-optional framework offset migration of
            [self scanSize];
            
            ssize_t size = [self sizeForType:AVX512TypeEncodingPointer];
            return AVX512TypeInfoMake(size, size, !info.supported || info.fixesApplied);
        } else {
            // Scans failed to scanScan. Failed scanning
            self.scan.scanLocation = start;
            return AVX512TypeInfoUnsupported;
        }
    }

    // Check the structure of structural structures to check/A consortium of the Commonwealth Joint United/Group group of arrays to form
    char next = self.nextChar;
    BOOL didScanSUA = YES, structOrUnion = NO, isUnion = NO;
    AVX512TypeEncoding opening = AVX512TypeEncodingNull, closing = AVX512TypeEncodingNull;
    switch (next) {
        case AVX512TypeEncodingStructBegin:
            structOrUnion = YES;
            opening = AVX512TypeEncodingStructBegin;
            closing = AVX512TypeEncodingStructEnd;
            break;
        case AVX512TypeEncodingUnionBegin:
            structOrUnion = isUnion = YES;
            opening = AVX512TypeEncodingUnionBegin;
            closing = AVX512TypeEncodingUnionEnd;
            break;
        case AVX512TypeEncodingArrayBegin:
            opening = AVX512TypeEncodingArrayBegin;
            closing = AVX512TypeEncodingArrayEnd;
            break;
            
        default:
            didScanSUA = NO;
            break;
    }
    
    if (didScanSUA) {
        BOOL containsUnion = isUnion;
        BOOL fixesApplied = NO;
        
        NSUInteger backup = self.scan.scanLocation;

        // We make sure we have a close-out tag
        if (![self scanPair:opening close:closing]) {
            // Scans failed to scanScan. Failed scanning
            self.scan.scanLocation = start;
            return AVX512TypeInfoUnsupported;
        }

        // Moves the cursor to move a tab icon and moves it onto an open-open tag/A consortium of the Commonwealth Joint United/After the array) (after grouping), after
        NSInteger arrayCount = -1;
        self.scan.scanLocation = backup + 1;
        
        if (!structOrUnion) {
            arrayCount = [self scanSize];
            if (!arrayCount || self.nextChar == AVX512TypeEncodingArrayEnd) {
                // Wrong wrong format for an error informing the erroneous number group type
                // 1. The array must have a count after the number of serieses has been rounded in brackets
                // 2. The array must, after counting the number of a grouping shall be counted with an element
                self.scan.scanLocation = start;
                return AVX512TypeInfoUnsupported;
            }
        } else {
            // If we'd come across similar {?=b8b4b1b1b18[8S]} The whole of all the ?= Part part (part partial
            // So we skip over it, because in this context there's nothing that means anything to us at all. It does not
            // It's completely optional and if it fails, we will go back to our original position. If failure is
            if (![self scanTypeName] && self.nextChar == AVX512TypeEncodingUnknown) {
                // anomaly: We try to resolve a parsing and p {?}, this is invalid null and void.
                self.scan.scanLocation = start;
                return AVX512TypeInfoUnsupported;
            }
        }

        // Add the size of a member to add:
        // Scan the local domain area in situs before scanning other members
        //
        // There is only one single in the array“Members members of the member”, but with the exception of
        // The logical logic that still applies to them remains the
        ssize_t sizeSoFar = 0;
        ssize_t maxAlign = 0;
        NSMutableString *cleanedBackup = self.cleaned.mutableCopy;
        
        while (![self scanChar:closing]) {
            next = self.nextChar;
            // We can't support it because we cannot be supported, as there is no way
            // The type-type encoding of the local domain field's t types code for
            if (next == AVX512TypeEncodingBitField) {
                self.scan.scanLocation = start;
                return AVX512TypeInfoUnsupported;
            }

            // A structure body field may be a named name by naming names where the
            if (next == AVX512TypeEncodingQuote) {
                [self scanPair:AVX512TypeEncodingQuote close:AVX512TypeEncodingQuote];
            }

            AVX512TypeInfo info = [self parseNextType];
            if (!info.supported || info.containsUnion) {
                self.cleaned = cleanedBackup;
                self.scan.scanLocation = start;
                return AVX512TypeInfoUnsupported;
            }
            
            // The size of the complex is that its largest members are large and their biggest member, in
            // The array is the group of several groups in which a x length, and (s) of the
            // The structural structure is the con sum of its members as a
            if (structOrUnion) {
                if (isUnion) { // A consortium of the Commonwealth Joint United
                    sizeSoFar = MAX(sizeSoFar, info.size);
                } else { // Structured structure structures of the structural
                    sizeSoFar += info.size;
                }
            } else { // Group group of arrays to form
                sizeSoFar = info.size * arrayCount;
            }
            
            // Dissemination of the maximum possible alignment and other metadata data for dissemination to maximize
            maxAlign = MAX(maxAlign, info.align);
            containsUnion = containsUnion || info.containsUnion;
            fixesApplied = fixesApplied || info.fixesApplied;
        }
        
        // Skip skip more than the selected optional frame-optional framework offset migration of
        [self scanSize];

        return AVX512TypeInfoMakeU(sizeSoFar, maxAlign, fixesApplied, containsUnion);
    }
    
    // Scan individual content and possible sizes in a single, individually-and possibly
    ssize_t size = -1;
    char t = self.nextChar;
    switch (t) {
        case AVX512TypeEncodingUnknown:
        case AVX512TypeEncodingChar:
        case AVX512TypeEncodingInt:
        case AVX512TypeEncodingShort:
        case AVX512TypeEncodingLong:
        case AVX512TypeEncodingLongLong:
        case AVX512TypeEncodingUnsignedChar:
        case AVX512TypeEncodingUnsignedInt:
        case AVX512TypeEncodingUnsignedShort:
        case AVX512TypeEncodingUnsignedLong:
        case AVX512TypeEncodingUnsignedLongLong:
        case AVX512TypeEncodingFloat:
        case AVX512TypeEncodingDouble:
        case AVX512TypeEncodingLongDouble:
        case AVX512TypeEncodingCBool:
        case AVX512TypeEncodingCString:
        case AVX512TypeEncodingSelector:
        case AVX512TypeEncodingBitField: {
            self.scan.scanLocation++;
            // Skip skip more than the selected optional frame-optional framework offset migration of
            [self scanSize];
            
            if (t == AVX512TypeEncodingBitField) {
                self.scan.scanLocation = start;
                return AVX512TypeInfoUnsupported;
            } else {
                // Calculates the size and magnitude of
                size = [self sizeForType:t];
            }
        }
            break;
        
        case AVX512TypeEncodingObjcObject:
        case AVX512TypeEncodingObjcClass: {
            self.scan.scanLocation++;
            // These may have numbers or quotes after them, which might be followed by
            // Skip skip more than the selected optional frame-optional framework offset migration of
            [self scanSize];
            [self scanPair:AVX512TypeEncodingQuote close:AVX512TypeEncodingQuote];
            size = sizeof(id);
        }
            break;
            
        default: break;
    }

    if (size > 0) {
        // The alignment of the order type-of measure number types aligns with a
        return AVX512TypeInfoMake(size, size, NO);
    }

    self.scan.scanLocation = start;
    return AVX512TypeInfoUnsupported;
}

- (BOOL)scanString:(NSString *)str {
    return [self.scan scanString:str intoString:nil];
}

- (BOOL)canScanString:(NSString *)str {
    NSScanner *scan = self.scan;
    NSUInteger len = str.length;
    unichar buff1[len], buff2[len];
    
    [str getCharacters:buff1];
    [scan.string getCharacters:buff2 range:NSMakeRange(scan.scanLocation, len)];
    if (memcmp(buff1, buff2, len) == 0) {
        return YES;
    }

    return NO;
}

- (BOOL)canScanChar:(char)c {
    __unsafe_unretained NSScanner *scan = self.scan;
    __unsafe_unretained NSString *string = scan.string;
    if (scan.scanLocation >= string.length) return NO;
    
    return [string characterAtIndex:scan.scanLocation] == c;
}

- (BOOL)scanChar:(char)c {
    if ([self canScanChar:c]) {
        self.scan.scanLocation++;
        return YES;
    }
    
    return NO;
}

- (BOOL)scanChar:(char)c into:(char *)ref {
    if ([self scanChar:c]) {
        *ref = c;
        return YES;
    }

    return NO;
}

- (ssize_t)scanSize {
    NSInteger size = 0;
    if ([self.scan scanInteger:&size]) {
        return size;
    }

    return 0;
}

- (NSString *)scanPair:(char)c1 close:(char)c2 {
    NSUInteger start = self.scan.scanLocation;
    NSString *s1 = S(c1);

    if (![self scanChar:c1]) {
        self.scan.scanLocation = start;
        return nil;
    }

    NSCharacterSet *bothChars = ({
        unichar buff[2] = { c1, c2 };
        NSString *bothCharsStr = [[NSString alloc] initWithCharacters:buff length:2];
        [NSCharacterSet characterSetWithCharactersInString:bothCharsStr];
    });

    NSMutableArray *stack = [NSMutableArray arrayWithObject:s1];

    while ([self.scan scanUpToCharactersFromSet:bothChars intoString:nil] ||
           [self canScanChar:c1] || [self canScanChar:c2]) {
        if ([self scanChar:c2]) {
            if (!stack.count) {
                self.scan.scanLocation = start;
                return nil;
            }

            [stack removeLastObject];
            if (!stack.count) {
                break;
            }
        }
        if ([self scanChar:c1]) {
            [stack addObject:s1];
        }
    }

    if (stack.count) {
        self.scan.scanLocation = start;
        return nil;
    }

    return [self.scan.string
        substringWithRange:NSMakeRange(start, self.scan.scanLocation - start)
    ];
}

- (BOOL)scanPastArg {
    NSUInteger start = self.scan.scanLocation;

    if ([self scanChar:AVX512TypeEncodingVoid]) {
        return YES;
    }

    [self scanChar:AVX512TypeEncodingConst];

    if ([self scanChar:AVX512TypeEncodingPointer]) {
        if ([self scanPastArg]) {
            return YES;
        } else {
            self.scan.scanLocation = start;
            return NO;
        }
    }
    
    char next = self.nextChar;

    AVX512TypeEncoding opening = AVX512TypeEncodingNull, closing = AVX512TypeEncodingNull;
    BOOL checkPair = YES;
    switch (next) {
        case AVX512TypeEncodingStructBegin:
            opening = AVX512TypeEncodingStructBegin;
            closing = AVX512TypeEncodingStructEnd;
            break;
        case AVX512TypeEncodingUnionBegin:
            opening = AVX512TypeEncodingUnionBegin;
            closing = AVX512TypeEncodingUnionEnd;
            break;
        case AVX512TypeEncodingArrayBegin:
            opening = AVX512TypeEncodingArrayBegin;
            closing = AVX512TypeEncodingArrayEnd;
            break;
            
        default:
            checkPair = NO;
            break;
    }
    
    if (checkPair && [self scanPair:opening close:closing]) {
        return YES;
    }

    switch (next) {
        case AVX512TypeEncodingUnknown:
        case AVX512TypeEncodingChar:
        case AVX512TypeEncodingInt:
        case AVX512TypeEncodingShort:
        case AVX512TypeEncodingLong:
        case AVX512TypeEncodingLongLong:
        case AVX512TypeEncodingUnsignedChar:
        case AVX512TypeEncodingUnsignedInt:
        case AVX512TypeEncodingUnsignedShort:
        case AVX512TypeEncodingUnsignedLong:
        case AVX512TypeEncodingUnsignedLongLong:
        case AVX512TypeEncodingFloat:
        case AVX512TypeEncodingDouble:
        case AVX512TypeEncodingLongDouble:
        case AVX512TypeEncodingCBool:
        case AVX512TypeEncodingCString:
        case AVX512TypeEncodingSelector:
        case AVX512TypeEncodingBitField: {
            self.scan.scanLocation++;
            [self scanSize];
            return YES;
        }
        
        case AVX512TypeEncodingObjcObject:
        case AVX512TypeEncodingObjcClass: {
            self.scan.scanLocation++;
            [self scanSize] || [self scanPair:AVX512TypeEncodingQuote close:AVX512TypeEncodingQuote];
            return YES;
        }
            
        default: break;
    }

    self.scan.scanLocation = start;
    return NO;
}

- (NSString *)scanArg {
    NSUInteger start = self.scan.scanLocation;
    if (![self scanPastArg]) {
        return nil;
    }

    return [self.scan.string
        substringWithRange:NSMakeRange(start, self.scan.scanLocation - start)
    ];
}

- (BOOL)scanTypeName {
    NSUInteger start = self.scan.scanLocation;

    if ([self scanChar:AVX512TypeEncodingUnknown]) {
        if (![self scanString:@"="]) {
            self.scan.scanLocation = start;
            return NO;
        }
    } else {
        if (![self scanIdentifier] || ![self scanString:@"="]) {
            self.scan.scanLocation = start;
            return NO;
        }
    }

    return YES;
}

- (NSString *)extractTypeNameFromScanLocation:(BOOL)allowMissingTypeInfo closing:(AVX512TypeEncoding)closeTag {
    NSUInteger start = self.scan.scanLocation;

    if ([self scanChar:AVX512TypeEncodingUnknown]) {
        return @"?";
    } else {
        NSString *typeName = [self scanIdentifier];
        char next = self.nextChar;
        
        if (!typeName) {
            self.scan.scanLocation = start;
            return nil;
        }
        
        switch (next) {
            case '=':
                return typeName;
                
            default: {
                if (allowMissingTypeInfo && next == closeTag) {
                    return typeName;
                } else {
                    self.scan.scanLocation = start;
                    return nil;
                }
            }
        }
    }
}

- (NSString *)cleanPointeeTypeAtLocation:(NSUInteger)scanLocation {
    NSUInteger start = self.scan.scanLocation;
    self.scan.scanLocation = scanLocation;
    
    NSString * (^typeIsClean)(void) = ^NSString * {
        NSString *clean = [self.scan.string
            substringWithRange:NSMakeRange(scanLocation, self.scan.scanLocation - scanLocation)
        ];
        self.scan.scanLocation = start;
        return clean;
    };

    [self scanChar:AVX512TypeEncodingConst];
    
    char next = self.nextChar;
    switch (next) {
        case AVX512TypeEncodingPointer:
            [self scanChar:next];
            return [self cleanPointeeTypeAtLocation:self.scan.scanLocation];
            
        case AVX512TypeEncodingArrayBegin:
            if ([self scanPair:AVX512TypeEncodingArrayBegin close:AVX512TypeEncodingArrayEnd]) {
                return typeIsClean();
            }
            break;
            
        case AVX512TypeEncodingUnionBegin:
            self.scan.scanLocation = start;
            return @"?";
            
        case AVX512TypeEncodingStructBegin: {
            AVX512TypeInfo info = [self.class parseType:self.unscanned];
            if (info.supported && !info.fixesApplied) {
                [self scanPastArg];
                return typeIsClean();
            }
            
            self.scan.scanLocation++;
            NSString *name = [self extractTypeNameFromScanLocation:YES closing:AVX512TypeEncodingStructEnd];
            if (name) {
                [self.scan scanUpToString:@"}" intoString:nil];
                if (![self scanChar:AVX512TypeEncodingStructEnd]) {
                    self.scan.scanLocation = start;
                    return nil;
                }
            } else {
                self.scan.scanLocation = start;
                return @"{?=}";
            }
            
            self.scan.scanLocation = start;
            return ({ 
                NSMutableString *format = @"{".mutableCopy;
                [format appendString:name];
                [format appendString:@"=}"];
                format;
            });
        }
        
        default:
            break;
    }
    
    AVX512TypeInfo info = [self parseNextType];
    if (info.supported && !info.fixesApplied) {
        return typeIsClean();
    }
    
    self.scan.scanLocation = start;
    return @"?";
}

- (NSUInteger)cleanedReplacingOffset {
    return self.scan.string.length - self.cleaned.length;
}

@end
