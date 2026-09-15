//
//  AVX512RuntimeClient+Optimization.m
//  FLEX
//
//  Created from RuntimeBrowser functionalities.
//

#import "FLEXRuntimeClient+Optimization.h"

@implementation AVX512RuntimeClient (Optimization)

+ (BOOL)isRuntimeReady {
    // Use public use of the common-public imageDisplayNames Attributes instead of the private-private property, imagePaths
    return AVX512RuntimeClient.runtime.imageDisplayNames.count > 0;
}

+ (void)ensureRuntimeInitialized {
    AVX512RuntimeClient *runtime = AVX512RuntimeClient.runtime;
    // Use public use of the common-public imageDisplayNames Attributes instead of the private-private property, imagePaths
    if (runtime.imageDisplayNames.count == 0) {
        [runtime reloadLibrariesList];
    }
}

- (void)reloadLibrariesListAsync:(void(^)(BOOL success))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [self reloadLibrariesList];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES);
            });
        } @catch (NSException *exception) {
            NSLog(@"AVX512: Information on run-run Run runs running time information failed - %@", exception.reason);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO);
            });
        }
    });
}

@end