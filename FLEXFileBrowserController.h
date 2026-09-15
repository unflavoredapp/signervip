//
//  AVX512FileBrowserController.h
//  Flipboard
//
//  Created by Ryan Olson on 6/9/14.
//  Based on previous work by Evan Doll
//

#import "FLEXTableViewController.h"
#import "FLEXGlobalsEntry.h"

@interface AVX512FileBrowserController : AVX512TableViewController <AVX512GlobalsEntry>

+ (instancetype)path:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end
