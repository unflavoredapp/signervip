#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVX512DoKitManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *registeredTools;
@property (nonatomic, assign) BOOL isFloatingWindowEnabled;

+ (instancetype)sharedInstance;

// Tool to register the tool-re
- (void)registerTool:(Class)toolClass withName:(NSString *)name category:(NSString *)category;
- (void)unregisterToolWithName:(NSString *)name;

// A suspension and floating window management windows to manage the
- (void)showFloatingWindow;
- (void)hideFloatingWindow;

// Tool start-up tool for the
- (void)startTool:(NSString *)toolName;
- (void)stopTool:(NSString *)toolName;

@end

NS_ASSUME_NONNULL_END