//
//  AVX512ShortcutsFactory+Defaults.m
//  FLEX
//
//  By being by and subject Tanner Bennett Created created in creation to create 8/29/19.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXShortcutsFactory+Defaults.h"
#import "FLEXShortcut.h"
#import "FLEXMacros.h"
#import "FLEXRuntimeUtility.h"
#import "NSArray+FLEX.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXObjcInternal.h"
#import "Cocoa+FLEXShortcuts.h"

#pragma mark - UIApplication

@implementation AVX512ShortcutsFactory (UIApplication)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    // sharedApplication The class properties may extend until the group attributes can iOS 10 It is only as a
    // Adds to the F face-level class property addition
    AVX512RuntimeUtilityTryAddObjectProperty(
        2, sharedApplication, UIApplication.avx512_metaclass, UIApplication, PropertyKey(ReadOnly)
    );
    
    self.append.classProperties(@[@"sharedApplication"]).forClass(UIApplication.avx512_metaclass);
    self.append.properties(@[
        @"delegate", @"keyWindow", @"windows"
    ]).forClass(UIApplication.class);

    if (@available(iOS 13, *)) {
        self.append.properties(@[
            @"connectedScenes", @"openSessions", @"supportsMultipleScenes"
        ]).forClass(UIApplication.class);
    }
}

@end

#pragma mark - Views

@implementation AVX512ShortcutsFactory (Views)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    // UIView and a characteristic of some other category: many are numerous; there is `@property` 
    // From the point of view at run-time when running, it is not
    //
    // If these properties have not been added to the property if they are yet no additional attributes, we add them in class when running
    // In this way, we can use our property properties editor to access and change them as a means of using the attribute editors
    // The attribute properties property characteristics match the attributes that are matched by those stated in their header

    // UIView, Public, public and common
    Class UIView_ = UIView.class;
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, frame, UIView_, CGRect);
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, alpha, UIView_, CGFloat);
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, clipsToBounds, UIView_, BOOL);
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, opaque, UIView_, BOOL, PropertyKeyGetter(isOpaque));
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, hidden, UIView_, BOOL, PropertyKeyGetter(isHidden));
    AVX512RuntimeUtilityTryAddObjectProperty(2, backgroundColor, UIView_, UIColor, PropertyKey(Copy));
    AVX512RuntimeUtilityTryAddObjectProperty(6, constraints, UIView_, NSArray, PropertyKey(ReadOnly));
    AVX512RuntimeUtilityTryAddObjectProperty(2, subviews, UIView_, NSArray, PropertyKey(ReadOnly));
    AVX512RuntimeUtilityTryAddObjectProperty(2, superview, UIView_, UIView, PropertyKey(ReadOnly));
    AVX512RuntimeUtilityTryAddObjectProperty(7, tintColor, UIView_, UIView);

    // UIButton, Private private (private and
    AVX512RuntimeUtilityTryAddObjectProperty(2, font, UIButton.class, UIFont, PropertyKey(ReadOnly));
    
    // from only (from) and not iOS 3.2 Start is available to start workable, but we have never iOS 3, so whatever doesn's okay
    NSArray *ivars = @[@"_gestureRecognizers"];
    NSArray *methods = @[@"sizeToFit", @"setNeedsLayout", @"removeFromSuperview"];

    // UIView
    self.append.ivars(ivars).methods(methods).properties(@[
        @"frame", @"bounds", @"center", @"transform",
        @"backgroundColor", @"alpha", @"opaque", @"hidden",
        @"clipsToBounds", @"userInteractionEnabled", @"layer",
        @"superview", @"subviews",
        @"accessibilityIdentifier", @"accessibilityLabel"
    ]).forClass(UIView.class);

    // UILabel
    self.append.ivars(ivars).methods(methods).properties(@[
        @"text", @"attributedText", @"font", @"frame",
        @"textColor", @"textAlignment", @"numberOfLines",
        @"lineBreakMode", @"enabled", @"backgroundColor",
        @"alpha", @"hidden", @"preferredMaxLayoutWidth",
        @"superview", @"subviews",
        @"accessibilityIdentifier", @"accessibilityLabel"
    ]).forClass(UILabel.class);

    // UIWindow
    self.append.ivars(ivars).properties(@[
        @"rootViewController", @"windowLevel", @"keyWindow",
        @"frame", @"bounds", @"center", @"transform",
        @"backgroundColor", @"alpha", @"opaque", @"hidden",
        @"clipsToBounds", @"userInteractionEnabled", @"layer",
        @"subviews"
    ]).forClass(UIWindow.class);

    if (@available(iOS 13, *)) {
        self.append.properties(@[@"windowScene"]).forClass(UIWindow.class);
    }

    ivars = @[@"_targetActions", @"_gestureRecognizers"];
    
    // The property at the properties in attribute iOS 10 , but we would like to hope that if added iOS 9 There have also been a number of
    AVX512RuntimeUtilityTryAddObjectProperty(9, allTargets, UIControl.class, NSArray, PropertyKey(ReadOnly));

    // UIControl
    self.append.ivars(ivars).methods(methods).properties(@[
        @"enabled", @"allTargets", @"frame",
        @"backgroundColor", @"hidden", @"clipsToBounds",
        @"userInteractionEnabled", @"superview", @"subviews",
        @"accessibilityIdentifier", @"accessibilityLabel"
    ]).forClass(UIControl.class);

    // UIButton
    self.append.ivars(ivars).properties(@[
        @"titleLabel", @"font", @"imageView", @"tintColor",
        @"currentTitle", @"currentImage", @"enabled", @"frame",
        @"superview", @"subviews",
        @"accessibilityIdentifier", @"accessibilityLabel"
    ]).forClass(UIButton.class);
    
    // UIImageView
    self.append.properties(@[
        @"image", @"animationImages", @"frame", @"bounds", @"center",
        @"transform", @"alpha", @"hidden", @"clipsToBounds",
        @"userInteractionEnabled", @"layer", @"superview", @"subviews",
        @"accessibilityIdentifier", @"accessibilityLabel"
    ]).forClass(UIImageView.class);
}

@end


#pragma mark - View Controllers

@implementation AVX512ShortcutsFactory (ViewControllers)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    // toolbarItems In fact, it is not actually an attribute but rather a
    AVX512RuntimeUtilityTryAddObjectProperty(3, toolbarItems, UIViewController.class, NSArray);
    
    // UIViewController
    self.append
        .properties(@[
            @"viewIfLoaded", @"title", @"navigationItem", @"toolbarItems", @"tabBarItem",
            @"childViewControllers", @"navigationController", @"tabBarController", @"splitViewController",
            @"parentViewController", @"presentedViewController", @"presentingViewController",
        ])
        .methods(@[@"view"])
        .forClass(UIViewController.class);
    
    // UIAlertController
    NSMutableArray *alertControllerProps = @[
        @"title", @"message", @"actions", @"textFields",
        @"preferredAction", @"presentingViewController", @"viewIfLoaded",
    ].mutableCopy;
    if (@available(iOS 14.0, *)) {
        [alertControllerProps insertObject:@"image" atIndex:4];
    }
    self.append
        .properties(alertControllerProps)
        .methods(@[@"addAction:"])
        .forClass(UIAlertController.class);
    self.append.properties(@[
        @"title", @"style", @"enabled", @"avx512_styleName",
        @"image", @"keyCommandInput", @"_isPreferred", @"_alertController",
    ]).forClass(UIAlertAction.class);
}

@end


#pragma mark - UIImage

@implementation AVX512ShortcutsFactory (UIImage)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.methods(@[
        @"CGImage", @"CIImage"
    ]).properties(@[
        @"scale", @"size", @"capInsets",
        @"alignmentRectInsets", @"duration", @"images"
    ]).forClass(UIImage.class);

    if (@available(iOS 13, *)) {
        self.append.properties(@[@"symbolImage"]).forClass(UIImage.class);
    }
}

@end


#pragma mark - NSBundle

@implementation AVX512ShortcutsFactory (NSBundle)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.properties(@[
        @"bundleIdentifier", @"principalClass",
        @"infoDictionary", @"bundlePath",
        @"executablePath", @"loaded"
    ]).forClass(NSBundle.class);
}

@end


#pragma mark - Classes

@implementation AVX512ShortcutsFactory (Classes)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.classMethods(@[@"new", @"alloc"]).forClass(NSObject.avx512_metaclass);
}

@end


#pragma mark - Activities

@implementation AVX512ShortcutsFactory (Activities)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    // The property at the properties in attribute iOS 10 , but we would like to hope that if added iOS 9 There have also been a number of
    AVX512RuntimeUtilityTryAddNonatomicProperty(9, item, UIActivityItemProvider.class, id, PropertyKey(ReadOnly));
    
    self.append.properties(@[
        @"item", @"placeholderItem", @"activityType"
    ]).forClass(UIActivityItemProvider.class);

    self.append.properties(@[
        @"activityItems", @"applicationActivities", @"excludedActivityTypes", @"completionHandler"
    ]).forClass(UIActivityViewController.class);
}

@end


#pragma mark - Blocks

@implementation AVX512ShortcutsFactory (Blocks)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.methods(@[@"invoke"]).forClass(NSClassFromString(@"NSBlock"));
}

@end

#pragma mark - Foundation

@implementation AVX512ShortcutsFactory (Foundation)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.properties(@[
        @"configuration", @"delegate", @"delegateQueue", @"sessionDescription",
    ]).methods(@[
        @"dataTaskWithURL:", @"finishTasksAndInvalidate", @"invalidateAndCancel",
    ]).forClass(NSURLSession.class);
    
    self.append.methods(@[
        @"cachedResponseForRequest:", @"storeCachedResponse:forRequest:",
        @"storeCachedResponse:forDataTask:", @"removeCachedResponseForRequest:",
        @"removeCachedResponseForDataTask:", @"removeCachedResponsesSinceDate:",
        @"removeAllCachedResponses",
    ]).forClass(NSURLCache.class);
    
    
    self.append.methods(@[
        @"postNotification:", @"postNotificationName:object:userInfo:",
        @"addObserver:selector:name:object:", @"removeObserver:",
        @"removeObserver:name:object:",
    ]).forClass(NSNotificationCenter.class);
    
    // NSTimeZone Class-type property is not a class attribute, the
    AVX512RuntimeUtilityTryAddObjectProperty(2, localTimeZone, NSTimeZone.avx512_metaclass, NSTimeZone);
    AVX512RuntimeUtilityTryAddObjectProperty(2, systemTimeZone, NSTimeZone.avx512_metaclass, NSTimeZone);
    AVX512RuntimeUtilityTryAddObjectProperty(2, defaultTimeZone, NSTimeZone.avx512_metaclass, NSTimeZone);
    AVX512RuntimeUtilityTryAddObjectProperty(2, knownTimeZoneNames, NSTimeZone.avx512_metaclass, NSArray);
    AVX512RuntimeUtilityTryAddObjectProperty(2, abbreviationDictionary, NSTimeZone.avx512_metaclass, NSDictionary);
    
    self.append.classMethods(@[
        @"timeZoneWithName:", @"timeZoneWithAbbreviation:", @"timeZoneForSecondsFromGMT:",
    ]).forClass(NSTimeZone.avx512_metaclass);
    
    self.append.classProperties(@[
        @"defaultTimeZone", @"systemTimeZone", @"localTimeZone",
    ]).forClass(NSTimeZone.class);
    
    // UTF8String It's not the actual properties of
    AVX512RuntimeUtilityTryAddNonatomicProperty(2, UTF8String, NSString.class, const char *, PropertyKey(ReadOnly));
    
    self.append.properties(@[@"length"]).methods(@[@"characterAtIndex:"]).forClass(NSString.class);
    self.append.methods(@[
        @"writeToFile:atomically:", @"subdataWithRange:", @"isEqualToData:",
    ]).properties(@[
        @"length", @"bytes",
    ]).forClass(NSData.class);
    
    self.append.classMethods(@[
        @"dataWithJSONObject:options:error:",
        @"JSONObjectWithData:options:error:",
        @"isValidJSONObject:",
    ]).forClass(NSJSONSerialization.class);
    
    // NSArray
    self.append.classMethods(@[
        @"arrayWithObject:", @"arrayWithContentsOfFile:"
    ]).forClass(NSArray.avx512_metaclass);
    self.append.methods(@[
        @"valueForKeyPath:", @"subarrayWithRange:",
        @"arrayByAddingObject:", @"arrayByAddingObjectsFromArray:",
        @"filteredArrayUsingPredicate:", @"subarrayWithRange:",
        @"containsObject:", @"objectAtIndex:", @"indexOfObject:",
        @"makeObjectsPerformSelector:", @"makeObjectsPerformSelector:withObject:",
        @"sortedArrayUsingSelector:", @"reverseObjectEnumerator",
        @"isEqualToArray:", @"mutableCopy",
    ]).forClass(NSArray.class);
    // NSDictionary
    self.append.methods(@[
        @"objectForKey:", @"valueForKeyPath:",
        @"isEqualToDictionary:", @"mutableCopy",
    ]).forClass(NSDictionary.class);
    // NSSet
    self.append.classMethods(@[
        @"setWithObject:", @"setWithArray:"
    ]).forClass(NSSet.avx512_metaclass);
    self.append.methods(@[
        @"allObjects", @"valueForKeyPath:", @"containsObject:",
        @"setByAddingObject:", @"setByAddingObjectsFromArray:",
        @"filteredSetUsingPredicate:", @"isSubsetOfSet:",
        @"makeObjectsPerformSelector:", @"makeObjectsPerformSelector:withObject:",
        @"reverseObjectEnumerator", @"isEqualToSet:", @"mutableCopy",
    ]).forClass(NSSet.class);
    
    // NSMutableArray
    self.prepend.methods(@[
        @"addObject:", @"insertObject:atIndex:", @"addObjectsFromArray:", 
        @"removeObject:", @"removeObjectAtIndex:",
        @"removeObjectsInArray:", @"removeAllObjects", 
        @"removeLastObject", @"filterUsingPredicate:",
        @"sortUsingSelector:", @"copy",
    ]).forClass(NSMutableArray.class);
    // NSMutableDictionary
    self.prepend.methods(@[
        @"setObject:forKey:", @"removeObjectForKey:",
        @"removeAllObjects", @"removeObjectsForKeys:", @"copy",
    ]).forClass(NSMutableDictionary.class);
    // NSMutableSet
    self.prepend.methods(@[
        @"addObject:", @"removeObject:", @"filterUsingPredicate:",
        @"removeAllObjects", @"addObjectsFromArray:",
        @"unionSet:", @"minusSet:", @"intersectSet:", @"copy"
    ]).forClass(NSMutableSet.class);
    
    self.append.methods(@[@"nextObject", @"allObjects"]).forClass(NSEnumerator.class);
    
    self.append.properties(@[@"avx512_observers"]).forClass(NSNotificationCenter.class);
}

@end

#pragma mark - WebKit / Safari

@implementation AVX512ShortcutsFactory (WebKit_Safari)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    Class WKWebView = NSClassFromString(@"WKWebView");
    Class SafariVC = NSClassFromString(@"SFSafariViewController");
    
    if (WKWebView) {
        self.append.properties(@[
            @"configuration", @"scrollView", @"title", @"URL",
            @"customUserAgent", @"navigationDelegate"
        ]).methods(@[@"reload", @"stopLoading"]).forClass(WKWebView);
    }
    
    if (SafariVC) {
        self.append.properties(@[
            @"delegate"
        ]).forClass(SafariVC);
        if (@available(iOS 10.0, *)) {
            self.append.properties(@[
                @"preferredBarTintColor", @"preferredControlTintColor"
            ]).forClass(SafariVC);
        }
        if (@available(iOS 11.0, *)) {
            self.append.properties(@[
                @"configuration", @"dismissButtonStyle"
            ]).forClass(SafariVC);
        }
    }
}

@end

#pragma mark - Pasteboard

@implementation AVX512ShortcutsFactory (Pasteboard)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    self.append.properties(@[
        @"name", @"numberOfItems", @"items",
        @"string", @"image", @"color", @"URL",
    ]).forClass(UIPasteboard.class);
}

@end

@interface NSNotificationCenter (Observers)
@property (readonly) NSArray<NSString *> *avx512_observers;
@end

@implementation NSNotificationCenter (Observers)
- (id)avx512_observers {
    NSString *debug = self.debugDescription;
    NSArray<NSString *> *observers = [debug componentsSeparatedByString:@"\n"];
    NSArray<NSArray<NSString *> *> *splitObservers = [observers avx512_mapped:^id(NSString *entry, NSUInteger idx) {
        return [entry componentsSeparatedByString:@","];
    }];
    
    NSArray *names = [splitObservers avx512_mapped:^id(NSArray<NSString *> *entry, NSUInteger idx) {
        return entry[0];
    }];
    NSArray *objects = [splitObservers avx512_mapped:^id(NSArray<NSString *> *entry, NSUInteger idx) {
        if (entry.count < 2) return NSNull.null;
        NSScanner *scanner = [NSScanner scannerWithString:entry[1]];

        unsigned long long objectPointerValue;
        if ([scanner scanHexLongLong:&objectPointerValue]) {
            void *objectPointer = (void *)objectPointerValue;
            if (AVX512PointerIsValidObjcObject(objectPointer))
                return (__bridge id)(void *)objectPointer;
        }
        
        return NSNull.null;
    }];
    
    return [NSArray avx512_forEachUpTo:names.count map:^id(NSUInteger i) {
        return @[names[i], objects[i]];
    }];
}
@end

#pragma mark - Firebase Firestore

@implementation AVX512ShortcutsFactory (FirebaseFirestore)

+ (void)load { AVX512_EXIT_IF_NO_CTORS()
    Class FIRDocumentSnap = NSClassFromString(@"FIRDocumentSnapshot");
    if (FIRDocumentSnap) {
        AVX512RuntimeUtilityTryAddObjectProperty(2, data, FIRDocumentSnap, NSDictionary, PropertyKey(ReadOnly));        
    }
}

@end
