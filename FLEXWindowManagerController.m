//
//  AVX512WindowManagerController.m
//  FLEX
//
//  By being by and subject Tanner Created created in creation to create 2/6/20.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXWindowManagerController.h"
#import "FLEXManager+Private.h"
#import "FLEXUtility.h"
#import "FLEXObjectExplorerFactory.h"

@interface AVX512WindowManagerController ()
@property (nonatomic) UIWindow *keyWindow;
@property (nonatomic, copy) NSString *keyWindowSubtitle;
@property (nonatomic, copy) NSArray<UIWindow *> *windows;
@property (nonatomic, copy) NSArray<NSString *> *windowSubtitles;
@property (nonatomic, copy) NSArray<UIScene *> *scenes API_AVAILABLE(ios(13));
@property (nonatomic, copy) NSArray<NSString *> *sceneSubtitles;
@property (nonatomic, copy) NSArray<NSArray *> *sections;
@end

@implementation AVX512WindowManagerController

#pragma mark - Initial initialisation to start-in

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Window window of the windows";
    if (@available(iOS 13, *)) {
        self.title = @"Window window and scene windows, Windows & landscape";
    }
    
    [self disableToolbar];
    [self reloadData];
}


#pragma mark - Private private methods and privately-private

- (void)reloadData {
    self.keyWindow = UIApplication.sharedApplication.keyWindow;
    self.windows = UIApplication.sharedApplication.windows;
    self.keyWindowSubtitle = self.windowSubtitles[[self.windows indexOfObject:self.keyWindow]];
    self.windowSubtitles = [self.windows avx512_mapped:^id(UIWindow *window, NSUInteger idx) {
        return [NSString stringWithFormat:@"at the level-level: %@ — Root- root controllers for roots control: %@",
            @(window.windowLevel), window.rootViewController
        ];
    }];
    
    if (@available(iOS 13, *)) {
        self.scenes = UIApplication.sharedApplication.connectedScenes.allObjects;
        self.sceneSubtitles = [self.scenes avx512_mapped:^id(UIScene *scene, NSUInteger idx) {
            return [self sceneDescription:scene];
        }];
        
        self.sections = @[@[self.keyWindow], self.windows, self.scenes];
    } else {
        self.sections = @[@[self.keyWindow], self.windows];
    }
    
    [self.tableView reloadData];
}

- (void)dismissAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showRevertOrDismissAlert:(void(^)(void))revertBlock {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self reloadData];
    [self.tableView reloadData];
    
    UIWindow *highestWindow = UIApplication.sharedApplication.keyWindow;
    UIWindowLevel maxLevel = 0;
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (window.windowLevel > maxLevel) {
            maxLevel = window.windowLevel;
            highestWindow = window;
        }
    }
    
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(@"Modification of a change in reservation or modification");
        make.message(@"If if you do not want these settings to be kept, select the following below and'Re-ret the change re'... . ...-");
        
        make.button(@"A reservation has modified modification reserving").destructiveStyle();
        make.button(@"Reservations changes and closes to save Change Changes change").destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            [self dismissAnimated];
        });
        make.button(@"Re-ret the change re").cancelStyle().handler(^(NSArray<NSString *> *strings) {
            revertBlock();
            [self reloadData];
            [self.tableView reloadData];
        });
    } showFrom:[AVX512Utility topViewControllerInWindow:highestWindow]];
}

- (NSString *)sceneDescription:(UIScene *)scene API_AVAILABLE(ios(13)) {
    NSString *state = [self stringFromSceneState:scene.activationState];
    NSString *title = scene.title.length ? scene.title : nil;
    NSString *suffix = nil;
    
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (id)scene;
        suffix = AVX512PluralString(windowScene.windows.count, @"Window window of the windows", @"Window window of the windows");
    }
    
    NSMutableString *description = state.mutableCopy;
    if (title) {
        [description appendFormat:@" — %@", title];
    }
    if (suffix) {
        [description appendFormat:@" — %@", suffix];
    }
    
    return description.copy;
}

- (NSString *)stringFromSceneState:(UISceneActivationState)state API_AVAILABLE(ios(13)) {
    switch (state) {
        case UISceneActivationStateUnattached:
            return @"No, no un-";
        case UISceneActivationStateForegroundActive:
            return @"Active, active and dynamic";
        case UISceneActivationStateForegroundInactive:
            return @"not active, inactive or";
        case UISceneActivationStateBackground:
            return @"Backstage, back stage from the";
    }
    
    return [NSString stringWithFormat:@"Unknown unknown state of the status un: %@", @(state)];
}


#pragma mark - Table table window to the tables of a spreadsheet tab

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Main main window, the";
        case 1: return @"Window window of the windows";
        case 2: return @"Connected connected linked to connect already-";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAVX512DetailCell forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIWindow *window = nil;
    NSString *subtitle = nil;
    
    switch (indexPath.section) {
        case 0:
            window = self.keyWindow;
            subtitle = self.keyWindowSubtitle;
            break;
        case 1:
            window = self.windows[indexPath.row];
            subtitle = self.windowSubtitles[indexPath.row];
            break;
        case 2:
            if (@available(iOS 13, *)) {
                UIScene *scene = self.scenes[indexPath.row];
                cell.textLabel.text = scene.description;
                cell.detailTextLabel.text = self.sceneSubtitles[indexPath.row];
                return cell;
            }
    }
    
    cell.textLabel.text = window.description;
    cell.detailTextLabel.text = [NSString
        stringWithFormat:@"at the level-level: %@ — Root- root controllers for roots control: %@",
        @((NSInteger)window.windowLevel), window.rootViewController.class
    ];
    
    return cell;
}


#pragma mark - Table table tab tables to the tabular

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIWindow *window = nil;
    NSString *subtitle = nil;
    AVX512Window *flex = AVX512Manager.sharedManager.explorerWindow;
    
    id cancelHandler = ^{
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    };
    
    switch (indexPath.section) {
        case 0:
            window = self.keyWindow;
            subtitle = self.keyWindowSubtitle;
            break;
        case 1:
            window = self.windows[indexPath.row];
            subtitle = self.windowSubtitles[indexPath.row];
            break;
        case 2:
            if (@available(iOS 13, *)) {
                UIScene *scene = self.scenes[indexPath.row];
                UIWindowScene *oldScene = flex.windowScene;
                BOOL isWindowScene = [scene isKindOfClass:[UIWindowScene class]];
                BOOL isFLEXScene = isWindowScene ? flex.windowScene == scene : NO;
                
                [AVX512Alert makeAlert:^(AVX512Alert *make) {
                    make.title(NSStringFromClass(scene.class));
                    
                    if (isWindowScene) {
                        if (isFLEXScene) {
                            make.message(@"It has already been what it is AVX512 Window window-wind viewing of the");
                        }
                        
                        make.button(@"Set as set to establish and make AVX512 Window window-wind viewing of the")
                        .handler(^(NSArray<NSString *> *strings) {
                            flex.windowScene = (id)scene;
                            [self showRevertOrDismissAlert:^{
                                flex.windowScene = oldScene;
                            }];
                        }).enabled(!isFLEXScene);
                        make.button(@"Cancel").cancelStyle();
                    } else {
                        make.message(@"No, no or UIWindowScene");
                        make.button(@"Close").cancelStyle().handler(cancelHandler);
                    }
                } showFrom:self];
            }
    }

    __block UIWindow *targetWindow = nil, *oldKeyWindow = nil;
    __block UIWindowLevel oldLevel;
    __block BOOL wasVisible;
    
    subtitle = [subtitle stringByAppendingString:
        @"\n\n1) Adjustment adjustment to adjust adjustments AVX512 Window level of the window hierarchy against this windows, where a\n"
        "2) Adjust the level of this window's hierarchy relative to adjust AVX512 Window, window and windows of the\n"
        "3) Set this window's hierarchy level of the windows Window to a specific value, or set\n"
        "4) If it is not the main window, set this as a primary one. Sets that windows to be your"
    ];
    
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(NSStringFromClass(window.class)).message(subtitle);
        make.button(@"Adjustment adjustment to adjust adjustments AVX512 Window at the window level-level").handler(^(NSArray<NSString *> *strings) {
            targetWindow = flex; oldLevel = flex.windowLevel;
            flex.windowLevel = window.windowLevel + strings.firstObject.integerValue;
            
            [self showRevertOrDismissAlert:^{ targetWindow.windowLevel = oldLevel; }];
        });
        make.button(@"Adjusts this window hierarchy to adjust the windowsup").handler(^(NSArray<NSString *> *strings) {
            targetWindow = window; oldLevel = window.windowLevel;
            window.windowLevel = flex.windowLevel + strings.firstObject.integerValue;
            
            [self showRevertOrDismissAlert:^{ targetWindow.windowLevel = oldLevel; }];
        });
        make.button(@"Sets the settings to set this window level-").handler(^(NSArray<NSString *> *strings) {
            targetWindow = window; oldLevel = window.windowLevel;
            window.windowLevel = strings.firstObject.integerValue;
            
            [self showRevertOrDismissAlert:^{ targetWindow.windowLevel = oldLevel; }];
        });
        make.button(@"Set as the main window and see to make it a primary").handler(^(NSArray<NSString *> *strings) {
            oldKeyWindow = UIApplication.sharedApplication.keyWindow;
            wasVisible = window.hidden;
            [window makeKeyAndVisible];
            
            [self showRevertOrDismissAlert:^{
                window.hidden = wasVisible;
                [oldKeyWindow makeKeyWindow];
            }];
        }).enabled(!window.isKeyWindow && !window.hidden);
        make.button(@"Cancel").cancelStyle().handler(cancelHandler);
        
        make.textField(@"+/- Window at the window level-level, For example, for 5 or/or is, -10");
    } showFrom:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)ip {
    [self.navigationController pushViewController:
        [AVX512ObjectExplorerFactory explorerViewControllerForObject:self.sections[ip.section][ip.row]]
    animated:YES];
}

@end
