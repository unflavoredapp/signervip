//
//  AVX512Utility.m
//  Flipboard
//
//  By being by and subject Ryan Olson Created created in creation to create 4/18/14.
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXColor.h"
#import "FLEXUtility.h"
#import "FLEXResources.h"
#import "FLEXWindow.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <zlib.h>

BOOL AVX512ConstructorsShouldRun(void) {
    #if AVX512_DISABLE_CTORS
        return NO;
    #else
        static BOOL _FLEXConstructorsShouldRun_storage = YES;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *key = @"AVX512_SKIP_INIT";
            if (getenv(key.UTF8String) || [NSUserDefaults.standardUserDefaults boolForKey:key]) {
                _FLEXConstructorsShouldRun_storage = NO;
            }
        });
        
        return _FLEXConstructorsShouldRun_storage;
    #endif
}

@implementation AVX512Utility

+ (UIWindow *)appKeyWindow {
    // First of first, the check- UIApplication.keyWindow
    AVX512Window *window = (id)UIApplication.sharedApplication.keyWindow;
    if (window) {
        if ([window isKindOfClass:[AVX512Window class]]) {
            return window.previousKeyWindow;
        }
        
        return window;
    }
    
    // From all from the iOS 13 Start, start and begin.UIApplication.keyWindow No return will not be nil...... .,
    // So it's more so therefore much like a prevention of future return nil Safety and security.
    //
    // Moreover, it is also clear that these are clearly not AVX512Windows; to use and , with AVX512Window 
    // It's because we can call if so that window.previousKeyWindow Without the need for ugly types of ugly type-type
    for (AVX512Window *window in UIApplication.sharedApplication.windows) {
        if (window.isKeyWindow) {
            if ([window isKindOfClass:[AVX512Window class]]) {
                return window.previousKeyWindow;
            }
            
            return window;
        }
    }
    
    return nil;
}

+ (UIWindowScene *)activeScene {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        // Looking for a dynamic and active search to UIWindowScene
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            return (UIWindowScene *)scene;
        }
    }
    
    return nil;
}

+ (UIViewController *)topViewControllerInWindow:(UIWindow *)window {
    UIViewController *topViewController = window.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

+ (UIColor *)consistentRandomColorForObject:(id)object {
    CGFloat hue = (((NSUInteger)object >> 4) % 256) / 255.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

+ (NSString *)descriptionForView:(UIView *)view includingFrame:(BOOL)includeFrame {
    NSString *description = [[view class] description];
    
    NSString *viewControllerDescription = [[[self viewControllerForView:view] class] description];
    if (viewControllerDescription.length > 0) {
        description = [description stringByAppendingFormat:@" (%@)", viewControllerDescription];
    }
    
    if (includeFrame) {
        description = [description stringByAppendingFormat:@" %@", [self stringForCGRect:view.frame]];
    }
    
    if (view.accessibilityLabel.length > 0 || view.accessibilityIdentifier.length > 0) {
        description = [description stringByAppendingFormat:@" · %@",
                       view.accessibilityLabel.length > 0 ? view.accessibilityLabel : view.accessibilityIdentifier];
    }
    
    return description;
}

+ (NSString *)stringForCGRect:(CGRect)rect {
    return [NSString stringWithFormat:@"{(%g, %g), (%g, %g)}",
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height
    ];
}

+ (UIViewController *)viewControllerForView:(UIView *)view {
    NSString *viewDelegate = @"_viewDelegate";
    if ([view respondsToSelector:NSSelectorFromString(viewDelegate)]) {
        return [view valueForKey:viewDelegate];
    }

    return nil;
}

+ (UIViewController *)viewControllerForAncestralView:(UIView *)view {
    NSString *_viewControllerForAncestor = @"_viewControllerForAncestor";
    if ([view respondsToSelector:NSSelectorFromString(_viewControllerForAncestor)]) {
        return [view valueForKey:_viewControllerForAncestor];
    }

    return nil;
}

+ (UIImage *)previewImageForView:(UIView *)view {
    if (CGRectIsEmpty(view.bounds)) {
        return [UIImage new];
    }
    
    CGSize viewSize = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 0.0);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, viewSize.width, viewSize.height) afterScreenUpdates:YES];
    UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return previewImage;
}

+ (UIImage *)previewImageForLayer:(CALayer *)layer {
    if (CGRectIsEmpty(layer.bounds)) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 0.0);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    [layer renderInContext:imageContext];
    UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return previewImage;
}

+ (NSString *)detailDescriptionForView:(UIView *)view {
    return [NSString stringWithFormat:@"frame %@", [self stringForCGRect:view.frame]];
}

+ (UIImage *)circularImageWithColor:(UIColor *)color radius:(CGFloat)radius {
    CGFloat diameter = radius * 2.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 0.0);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(imageContext, color.CGColor);
    CGContextFillEllipseInRect(imageContext, CGRectMake(0, 0, diameter, diameter));
    UIImage *circularImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circularImage;
}

+ (UIColor *)hierarchyIndentPatternColor {
    static UIColor *patternColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *indentationPatternImage = AVX512Resources.hierarchyIndentPattern;
        patternColor = [UIColor colorWithPatternImage:indentationPatternImage];
        if (@available(iOS 13.0, *)) {
            // Creates a version versions of the Bw-B
            UIGraphicsBeginImageContextWithOptions(
                indentationPatternImage.size, NO, indentationPatternImage.scale
            );
            [AVX512Color.iconColor set];
            [indentationPatternImage drawInRect:CGRectMake(
                0, 0, indentationPatternImage.size.width, indentationPatternImage.size.height
            )];
            UIImage *darkModePatternImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            // Create a dynamic dynamics colour provider Provider to create
            patternColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
                return (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight
                        ? [UIColor colorWithPatternImage:indentationPatternImage]
                        : [UIColor colorWithPatternImage:darkModePatternImage]);
            }];
        }
    });

    return patternColor;
}

+ (NSString *)applicationImageName {
    return NSBundle.mainBundle.executablePath;
}

+ (NSString *)applicationName {
    return AVX512Utility.applicationImageName.lastPathComponent;
}

+ (NSString *)pointerToString:(void *)ptr {
    return [NSString stringWithFormat:@"%p", ptr];
}

+ (NSString *)addressOfObject:(id)object {
    return [NSString stringWithFormat:@"%p", object];
}

+ (NSString *)stringByEscapingHTMLEntitiesInString:(NSString *)originalString {
    static NSDictionary<NSString *, NSString *> *escapingDictionary = nil;
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        escapingDictionary = @{ @" " : @"&nbsp;",
                                @">" : @"&gt;",
                                @"<" : @"&lt;",
                                @"&" : @"&amp;",
                                @"'" : @"&apos;",
                                @"\"" : @"&quot;",
                                @"«" : @"&laquo;",
                                @"»" : @"&raquo;"
                                };
        regex = [NSRegularExpression regularExpressionWithPattern:@"(&|>|<|'|\"|«|»)" options:0 error:NULL];
    });
    
    NSMutableString *mutableString = originalString.mutableCopy;
    
    NSArray<NSTextCheckingResult *> *matches = [regex
        matchesInString:mutableString options:0 range:NSMakeRange(0, mutableString.length)
    ];
    for (NSTextCheckingResult *result in matches.reverseObjectEnumerator) {
        NSString *foundString = [mutableString substringWithRange:result.range];
        NSString *replacementString = escapingDictionary[foundString];
        if (replacementString) {
            [mutableString replaceCharactersInRange:result.range withString:replacementString];
        }
    }
    
    return [mutableString copy];
}

+ (UIInterfaceOrientationMask)infoPlistSupportedInterfaceOrientationsMask {
    NSArray<NSString *> *supportedOrientations = NSBundle.mainBundle.infoDictionary[@"UISupportedInterfaceOrientations"];
    UIInterfaceOrientationMask supportedOrientationsMask = 0;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskPortrait;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationMaskLandscapeRight"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskLandscapeRight;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationMaskPortraitUpsideDown"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"]) {
        supportedOrientationsMask |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    return supportedOrientationsMask;
}

+ (UIImage *)thumbnailedImageWithMaxPixelDimension:(NSInteger)dimension fromImageData:(NSData *)data {
    UIImage *thumbnail = nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, 0);
    if (imageSource) {
        NSDictionary<NSString *, id> *options = @{
            (__bridge id)kCGImageSourceCreateThumbnailWithTransform : @YES,
            (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
            (__bridge id)kCGImageSourceThumbnailMaxPixelSize : @(dimension)
        };

        CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, (__bridge CFDictionaryRef)options
        );
        if (scaledImageRef) {
            thumbnail = [UIImage imageWithCGImage:scaledImageRef];
            CFRelease(scaledImageRef);
        }
        CFRelease(imageSource);
    }
    return thumbnail;
}

+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration {
    NSString *string = @"0s";
    if (duration > 0.0) {
        if (duration < 1.0) {
            string = [NSString stringWithFormat:@"%dms", (int)(duration * 1000)];
        } else if (duration < 10.0) {
            string = [NSString stringWithFormat:@"%.2fs", duration];
        } else {
            string = [NSString stringWithFormat:@"%.1fs", duration];
        }
    }
    return string;
}

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response {
    NSString *httpResponseString = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *statusCodeDescription = nil;
        if (httpResponse.statusCode == 200) {
            // Priority Use priority to use the preferred OK rather than by default, instead of the "no error"
            statusCodeDescription = @"OK";
        } else {
            statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        }
        httpResponseString = [NSString stringWithFormat:@"%ld %@", (long)httpResponse.statusCode, statusCodeDescription];
    }
    return httpResponseString;
}

+ (BOOL)isErrorStatusCodeFromURLResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        return httpResponse.statusCode >= 400;
    }
    
    return NO;
}

+ (NSArray<NSURLQueryItem *> *)itemsFromQueryString:(NSString *)query {
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray new];

    // [a=1, b=2, c=3]
    NSArray<NSString *> *queryComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValueString in queryComponents) {
        // [a, 1]
        NSArray<NSString *> *components = [keyValueString componentsSeparatedByString:@"="];
        if (components.count == 2) {
            NSString *key = components.firstObject.stringByRemovingPercentEncoding;
            NSString *value = components.lastObject.stringByRemovingPercentEncoding;

            [items addObject:[NSURLQueryItem queryItemWithName:key value:value]];
        }
    }

    return items.copy;
}

+ (NSString *)prettyJSONStringFromData:(NSData *)data {
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        // Thank thanked the thanks RaziPour1993
        prettyString = [[NSString alloc]
            initWithData:[NSJSONSerialization
                dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL
            ]
            encoding:NSUTF8StringEncoding
        ];
        // NSJSONSerialization will turn to the right and straight slash.
        // We hope to have a beautiful view of the beauty json, so go through and remove the slashes that have been changed to these curves.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString;
}

+ (BOOL)isValidJSONData:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] ? YES : NO;
}

// Thanks for the following link links to help with this method, and thanks
// https://www.cocoanetics.com/2012/02/decompressing-files-into-memory/
// https://github.com/nicklockwood/GZIP
+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData {
    NSData *inflatedData = nil;
    NSUInteger compressedDataLength = compressedData.length;
    if (compressedDataLength > 0) {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uInt)compressedDataLength;
        stream.next_in = (void *)compressedData.bytes;
        stream.total_out = 0;
        stream.avail_out = 0;

        NSMutableData *mutableData = [NSMutableData dataWithLength:compressedDataLength * 1.5];
        if (inflateInit2(&stream, 15 + 32) == Z_OK) {
            int status = Z_OK;
            while (status == Z_OK) {
                if (stream.total_out >= mutableData.length) {
                    mutableData.length += compressedDataLength / 2;
                }
                stream.next_out = (uint8_t *)[mutableData mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)(mutableData.length - stream.total_out);
                status = inflate(&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK) {
                if (status == Z_STREAM_END) {
                    mutableData.length = stream.total_out;
                    inflatedData = [mutableData copy];
                }
            }
        }
    }
    return inflatedData;
}

+ (BOOL)hasCompressedContentEncoding:(NSURLRequest *)request {
    NSString *contentEncoding = [request valueForHTTPHeaderField:@"Content-Encoding"];
    return ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0);
}

+ (NSArray<UIWindow *> *)allWindows {
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;

    // Conf confuse confusion between confusing the selection pick allWindowsIncludingInternalWindows:onlyVisibleWindows:
    NSArray<NSString *> *allWindowsComponents = @[
        @"al", @"lWindo", @"wsIncl", @"udingInt", @"ernalWin", @"dows:o", @"nlyVisi", @"bleWin", @"dows:"
    ];
    SEL allWindowsSelector = NSSelectorFromString([allWindowsComponents componentsJoinedByString:@""]);

    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];

    __unsafe_unretained NSArray<UIWindow *> *windows = nil;
    [invocation getReturnValue:&windows];
    return windows;
}

+ (UIAlertController *)alert:(NSString *)title message:(NSString *)message {
    return [UIAlertController
        alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert
    ];
}

+ (SEL)swizzledSelectorForSelector:(SEL)selector {
    return NSSelectorFromString([NSString stringWithFormat:
        @"_flex_swizzle_%x_%@", arc4random(), NSStringFromSelector(selector)
    ]);
}

+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls {
    if ([cls instancesRespondToSelector:selector]) {
        unsigned int numMethods = 0;
        Method *methods = class_copyMethodList(cls, &numMethods);
        
        BOOL implementsSelector = NO;
        for (int index = 0; index < numMethods; index++) {
            SEL methodSelector = method_getName(methods[index]);
            if (selector == methodSelector) {
                implementsSelector = YES;
                break;
            }
        }
        
        free(methods);
        
        if (!implementsSelector) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector
                                     onClass:(Class)class
                                   withBlock:(id)block
                            swizzledSelector:(SEL)swizzledSelector {
    // This method is used only for the exchange of methods that are known to exist in class classes
    // If this is not the case, then exits.
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    if (!originalMethod) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method newMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)replaceImplementationOfSelector:(SEL)selector
                           withSelector:(SEL)swizzledSelector
                               forClass:(Class)cls
                  withMethodDescription:(struct objc_method_description)methodDescription
                    implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock {
    if ([self instanceRespondsButDoesNotImplementSelector:selector class:cls]) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock((id)(
        [cls instancesRespondToSelector:selector] ? implementationBlock : undefinedBlock)
    );
    
    Method oldMethod = class_getInstanceMethod(cls, selector);
    const char *types = methodDescription.types;
    if (oldMethod) {
        if (!types) {
            types = method_getTypeEncoding(oldMethod);
        }

        class_addMethod(cls, swizzledSelector, implementation, types);
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        if (!types) {
            // Some of some agreed agreemental methodological approach descriptions, by way .types
            // Sets the return-type to set a returned type void and ignore the argument para parameter with ignored
            types = "v@:";
        }
        class_addMethod(cls, selector, implementation, types);
    }
}

@end
