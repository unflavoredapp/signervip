#import "FLEXFileBrowserController.h"

@interface AVX512FileBrowserController (RuntimeBrowser)

// ✅ Rename the renaming method to avoid conflict conflicts by
- (void)analyzeRuntimeMachOFile:(NSString *)path;  // Original: From the beginning of analyzeMachOFile:
- (void)analyzePlistFile:(NSString *)path;
- (void)previewTextFile:(NSString *)path;
- (void)analyzeFileAtPath:(NSString *)path;

@end