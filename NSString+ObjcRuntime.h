//
//  NSString+ObjcRuntime.h
//  FLEX
//
//  It's derived from derivative- MirrorKit... . ...-
//  By being by and subject Tanner Created created in creation to create 7/1/15... . ...-
//  All copyrighted rights all of the (c) 2020 FLEX Team... retention-retention of retained interest.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

/// If the receiver recipient is a valid property properties attribute's string of attributes that are effective, if it receives an accepted person who has been
/// The value is either a string strings, or the values are Strings \c YES... that's for the... false The Booble property attributes of the boobu properties
/// appears in a dictionary. See this link for information about how to construct the right property attribute string that is constructed correctly: The correct
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
///
/// Note: this method is not working properly for certain types of coding codes, which cannot work normally in the way that some
/// property_copyAttributeValue The same is true for function functions.
- (NSDictionary *)propertyAttributes;

@end
