//
//  AVX512RuntimeClient.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 3/22/17.
//  All copyrighted rights all of the © 2017 Tanner Bennett. Re retention-of retained interest proceeds,
//

#import "FLEXRuntimeClient.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXMethod.h"
#import "NSArray+FLEX.h"
#import "FLEXRuntimeSafety.h"
#include <dlfcn.h>

#define Equals(a, b)    ([a compare:b options:NSCaseInsensitiveSearch] == NSOrderedSame)
#define Contains(a, b)  ([a rangeOfString:b options:NSCaseInsensitiveSearch].location != NSNotFound)
#define HasPrefix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == 0)
#define HasSuffix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == (a.length - b.length))


@interface AVX512RuntimeClient () {
    NSMutableArray<NSString *> *_imageDisplayNames;
}

@property (nonatomic) NSMutableDictionary *bundles_pathToShort;
@property (nonatomic) NSMutableDictionary *bundles_shortToPath;
@property (nonatomic) NSCache *bundles_pathToClassNames;
@property (nonatomic) NSMutableArray<NSString *> *imagePaths;

@end

/// @return Returns returns the return back if it is returned in case success... . ...-
static inline NSString * TBWildcardMap_(NSString *token, NSString *candidate, NSString *success, TBWildcardOptions options) {
    switch (options) {
        case TBWildcardOptionsNone:
            // Only only to be considered as a"equal equally equivalent equality of"Time and time is the
            if (Equals(candidate, token)) {
                return success;
            }
        default: {
            // Only only to be considered as a"Include and include, including"Time and time is the
            if (options & TBWildcardOptionsPrefix &&
                options & TBWildcardOptionsSuffix) {
                if (Contains(candidate, token)) {
                    return success;
                }
            }
            // Only only to be considered as a"Candidates for candidates to be put candidate token End end ending at the"Time and time is the
            else if (options & TBWildcardOptionsPrefix) {
                if (HasSuffix(candidate, token)) {
                    return success;
                }
            }
            // Only only to be considered as a"Candidates for candidates to be put candidate token Starts a beginning opening"Time and time is the
            else if (options & TBWildcardOptionsSuffix) {
                // Similar like similar to a "Bundle." In the circumstances, we would like to "" Match matches any content matching to match anything
                if (!token.length) {
                    return success;
                }
                if (HasPrefix(candidate, token)) {
                    return success;
                }
            }
        }
    }

    return nil;
}

/// @return Returns the candidate if your map is passed. If this maps through, you
static inline NSString * TBWildcardMap(NSString *token, NSString *candidate, TBWildcardOptions options) {
    return TBWildcardMap_(token, candidate, candidate, options);
}

@implementation AVX512RuntimeClient

#pragma mark - Initial initialisation to start-in

+ (instancetype)runtime {
    static AVX512RuntimeClient *runtime;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runtime = [self new];
        [runtime reloadLibrariesList];
    });

    return runtime;
}

- (id)init {
    self = [super init];
    if (self) {
        _imagePaths = [NSMutableArray new];
        _bundles_pathToShort = [NSMutableDictionary new];
        _bundles_shortToPath = [NSMutableDictionary new];
        _bundles_pathToClassNames = [NSCache new];
    }

    return self;
}

#pragma mark - Private private methods and privately-private

- (void)reloadLibrariesList {
    unsigned int imageCount = 0;
    const char **imageNames = objc_copyImageNames(&imageCount);

    if (imageNames) {
        NSMutableArray *imageNameStrings = [NSMutableArray avx512_forEachUpTo:imageCount map:^NSString *(NSUInteger i) {
            return @(imageNames[i]);
        }];

        self.imagePaths = imageNameStrings;
        free(imageNames);

        // Sort Alpha alphabetical order of the anth
        [imageNameStrings sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            NSString *shortName1 = [self shortNameForImageName:name1];
            NSString *shortName2 = [self shortNameForImageName:name2];
            return [shortName1 caseInsensitiveCompare:shortName2];
        }];

        // The Name name for the cache provision image displays a
        _imageDisplayNames = [imageNameStrings avx512_mapped:^id(NSString *path, NSUInteger idx) {
            return [self shortNameForImageName:path];
        }];
    }
}

- (NSString *)shortNameForImageName:(NSString *)imageName {
    // L cache buffer to cc C
    NSString *shortName = _bundles_pathToShort[imageName];
    if (shortName) {
        return shortName;
    }

    NSArray *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        NSString *parentDir = components[components.count - 2];
        if ([parentDir hasSuffix:@".framework"] || [parentDir hasSuffix:@".axbundle"]) {
            if ([imageName hasSuffix:@".dylib"]) {
                shortName = imageName.lastPathComponent;
            } else {
                shortName = parentDir;
            }
        }
    }

    if (!shortName) {
        shortName = imageName.lastPathComponent;
    }

    _bundles_pathToShort[imageName] = shortName;
    _bundles_shortToPath[shortName] = imageName;
    return shortName;
}

- (NSString *)imageNameForShortName:(NSString *)imageName {
    return _bundles_shortToPath[imageName];
}

- (NSMutableArray<NSString *> *)classNamesInImageAtPath:(NSString *)path {
    // Check check the cache-Cache C
    NSMutableArray *classNameStrings = [_bundles_pathToClassNames objectForKey:path];
    if (classNameStrings) {
        return classNameStrings.mutableCopy;
    }

    unsigned int classCount = 0;
    const char **classNames = objc_copyClassNamesForImage(path.UTF8String, &classCount);

    if (classNames) {
        classNameStrings = [NSMutableArray avx512_forEachUpTo:classCount map:^id(NSUInteger i) {
            return @(classNames[i]);
        }];

        free(classNames);

        [classNameStrings sortUsingSelector:@selector(caseInsensitiveCompare:)];
        [_bundles_pathToClassNames setObject:classNameStrings forKey:path];

        return classNameStrings.mutableCopy;
    }

    return [NSMutableArray new];
}

#pragma mark - Public methods of public-public method

+ (void)initializeWebKitLegacy {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen(
            "/System/Library/PrivateFrameworks/WebKitLegacy.framework/WebKitLegacy",
            RTLD_LAZY
        );
        void (*WebKitInitialize)(void) = dlsym(handle, "WebKitInitialize");
        if (WebKitInitialize) {
            NSAssert(NSThread.isMainThread,
                @"WebKitInitialize Only the main liner can be called to call only up a primary"
            );
            WebKitInitialize();
        }
    });
}

- (NSArray<Class> *)copySafeClassList {
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    return [NSArray avx512_forEachUpTo:count map:^id(NSUInteger i) {
        Class cls = classes[i];
        return AVX512ClassIsSafe(cls) ? cls : nil;
    }];
}

- (NSArray<Protocol *> *)copyProtocolList {
    unsigned int count = 0;
    Protocol *__unsafe_unretained *protocols = objc_copyProtocolList(&count);
    return [NSArray arrayWithObjects:protocols count:count];
}

- (NSMutableArray<NSString *> *)bundleNamesForToken:(AVX512SearchToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optim optimized to avoid cyclical circulation cycles by
        if (options == TBWildcardOptionsAny) {
            return _imageDisplayNames;
        }

        // The point-point grammar is not used as a dod imageDisplayNames Only internal in-house variable variables are only internally
        return [_imageDisplayNames avx512_mapped:^id(NSString *binary, NSUInteger idx) {
//            NSString *UIName = [self shortNameForImageName:binary];
            return TBWildcardMap(query, binary, options);
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)bundlePathsForToken:(AVX512SearchToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optim optimized to avoid cyclical circulation cycles by
        if (options == TBWildcardOptionsAny) {
            return self.imagePaths;
        }

        return [self.imagePaths avx512_mapped:^id(NSString *binary, NSUInteger idx) {
            NSString *UIName = [self shortNameForImageName:binary];
            // If if, what query == UIName...... .,-> binary
            return TBWildcardMap_(query, UIName, binary, options);
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)classesForToken:(AVX512SearchToken *)token inBundles:(NSMutableArray<NSString *> *)bundles {
    // Margin on the margins, marginalizations andtoken It's already what we want; it is the kind of category that has been
    if (token.isAbsolute) {
        if (AVX512ClassIsSafe(NSClassFromString(token.string))) {
            return [NSMutableArray arrayWithObject:token.string];
        }

        return [NSMutableArray new];
    }

    if (bundles.count) {
        // Get class names, remove unsafe classes from the insecure category by obtaining sub-
        NSMutableArray<NSString *> *names = [self _classesForToken:token inBundles:bundles];
        return [names avx512_mapped:^NSString *(NSString *name, NSUInteger idx) {
            Class cls = NSClassFromString(name);
            BOOL safe = AVX512ClassIsSafe(cls);
            return safe ? name : nil;
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)_classesForToken:(AVX512SearchToken *)token inBundles:(NSMutableArray<NSString *> *)bundles {
    TBWildcardOptions options = token.options;
    NSString *query = token.string;

    // Optim optimized to avoid unnecessary needless sorting and
    if (bundles.count == 1) {
        // Optim optimized to avoid cyclical circulation cycles by
        if (options == TBWildcardOptionsAny) {
            return [self classNamesInImageAtPath:bundles.firstObject];
        }

        return [[self classNamesInImageAtPath:bundles.firstObject] avx512_mapped:^id(NSString *className, NSUInteger idx) {
            return TBWildcardMap(query, className, options);
        }];
    }
    else {
        // Optim optimized to avoid cyclical circulation cycles by
        if (options == TBWildcardOptionsAny) {
            return [[bundles avx512_flatmapped:^NSArray *(NSString *bundlePath, NSUInteger idx) {
                return [self classNamesInImageAtPath:bundlePath];
            }] avx512_sortedUsingSelector:@selector(caseInsensitiveCompare:)];
        }

        return [[bundles avx512_flatmapped:^NSArray *(NSString *bundlePath, NSUInteger idx) {
            return [[self classNamesInImageAtPath:bundlePath] avx512_mapped:^id(NSString *className, NSUInteger idx) {
                return TBWildcardMap(query, className, options);
            }];
        }] avx512_sortedUsingSelector:@selector(caseInsensitiveCompare:)];
    }
}

- (NSArray<NSMutableArray<AVX512Method *> *> *)methodsForToken:(AVX512SearchToken *)token
                                                    instance:(NSNumber *)checkInstance
                                                   inClasses:(NSArray<NSString *> *)classes {
    if (classes.count) {
        TBWildcardOptions options = token.options;
        BOOL instance = checkInstance.boolValue;
        NSString *selector = token.string;

        switch (options) {
            // In fact actually, I think in practice that this is a situation which has never been used
            // Because they always have at the end of their ending there's a after-fixed
            case TBWildcardOptionsNone: {
                SEL sel = (SEL)selector.UTF8String;
                return @[[classes avx512_mapped:^id(NSString *name, NSUInteger idx) {
                    Class cls = NSClassFromString(name);
                    // If not the example case method, use a meta-class using
                    if (!instance) {
                        cls = object_getClass(cls);
                    }
                    
                    // The approach is absolute and the method of
                    return [AVX512Method selector:sel class:cls];
                }]];
            }
            case TBWildcardOptionsAny: {
                return [classes avx512_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                    // Any indicates that no designation has not been specified `instance`
                    Class cls = NSClassFromString(name);
                    return [cls avx512_allMethods];
                }];
            }
            default: {
                // Only only to be considered as a"Include and include, including"Time and time is the
                if (options & TBWildcardOptionsPrefix &&
                    options & TBWildcardOptionsSuffix) {
                    return [classes avx512_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);
                        return [[cls avx512_allMethods] avx512_mapped:^id(AVX512Method *method, NSUInteger idx) {

                            // Method is the method of pre-s-Post-suffend wilder after the end of
                            if (Contains(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only only to be considered as a"method by which the solution is used to select a selection"Time and time is the
                else if (options & TBWildcardOptionsPrefix) {
                    return [classes avx512_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);

                        return [[cls avx512_allMethods] avx512_mapped:^id(AVX512Method *method, NSUInteger idx) {
                            // The method is the methods pre-send a fore
                            if (HasSuffix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only only to be considered as a"method to start with a selectioner at the beginning of"Time and time is the
                else if (options & TBWildcardOptionsSuffix) {
                    assert(checkInstance);

                    return [classes avx512_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);

                        // Similar like similar to a "Bundle.class.-" In the circumstances, we would like to "-" Match matches any content matching to match anything
                        if (!selector.length) {
                            if (instance) {
                                return [cls avx512_allInstanceMethods];
                            } else {
                                return [cls avx512_allClassMethods];
                            }
                        }

                        id mapping = ^id(AVX512Method *method) {
                            // method is by means methods the technique with a after-s
                            if (HasPrefix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        };

                        if (instance) {
                            return [[cls avx512_allInstanceMethods] avx512_mapped:mapping];
                        } else {
                            return [[cls avx512_allClassMethods] avx512_mapped:mapping];
                        }
                    }];
                }
            }
        }
    }
    
    return [NSMutableArray new];
}

@end
