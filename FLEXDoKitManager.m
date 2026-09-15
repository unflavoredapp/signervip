#import "FLEXDoKitManager.h"
#import "FLEXDoKitFloatingWindow.h"

@interface AVX512DoKitManager ()
@property (nonatomic, strong) AVX512DoKitFloatingWindow *floatingWindow;
@property (nonatomic, strong) NSMutableDictionary *toolsRegistry;
@end

@implementation AVX512DoKitManager

+ (instancetype)sharedInstance {
    static AVX512DoKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _registeredTools = [NSMutableArray new];
        _toolsRegistry = [NSMutableDictionary new];
        _isFloatingWindowEnabled = YES;
    }
    return self;
}

- (void)registerTool:(Class)toolClass withName:(NSString *)name category:(NSString *)category {
    NSDictionary *toolInfo = @{
        @"class": toolClass,
        @"name": name,
        @"category": category
    };
    [self.registeredTools addObject:toolInfo];
    self.toolsRegistry[name] = toolInfo;
}

- (void)unregisterToolWithName:(NSString *)name {
    NSDictionary *toolInfo = self.toolsRegistry[name];
    if (toolInfo) {
        [self.registeredTools removeObject:toolInfo];
        [self.toolsRegistry removeObjectForKey:name];
    }
}

- (void)showFloatingWindow {
    if (!self.floatingWindow) {
        self.floatingWindow = [[AVX512DoKitFloatingWindow alloc] init];
    }
    [self.floatingWindow show];
}

- (void)hideFloatingWindow {
    [self.floatingWindow hide];
}

- (void)startTool:(NSString *)toolName {
    NSDictionary *toolInfo = self.toolsRegistry[toolName];
    if (toolInfo) {
        NSLog(@"🔧 kick start-up tool for the: %@", toolName);
        Class toolClass = toolInfo[@"class"];
        if (toolClass) {
            // Exampleialization Toolbox category to use tool class
            id toolInstance = [[toolClass alloc] init];
            if ([toolInstance respondsToSelector:@selector(start)]) {
                [toolInstance performSelector:@selector(start)];
            }
        }
    } else {
        NSLog(@"❌ Tool not found to find un Found tool: %@", toolName);
    }
}

- (void)stopTool:(NSString *)toolName {
    NSDictionary *toolInfo = self.toolsRegistry[toolName];
    if (toolInfo) {
        NSLog(@"⏹️ Stop Tool to stop tool-stop: %@", toolName);
        Class toolClass = toolInfo[@"class"];
        if (toolClass) {
            // Exampleialization Toolbox category to use tool class
            id toolInstance = [[toolClass alloc] init];
            if ([toolInstance respondsToSelector:@selector(stop)]) {
                [toolInstance performSelector:@selector(stop)];
            }
        }
    } else {
        NSLog(@"❌ Tool not found to find un Found tool: %@", toolName);
    }
}

@end