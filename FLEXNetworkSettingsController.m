//
//  AVX512NetworkSettingsController.m
//  AVX512Injected
//
//  Created by Ryan Olson on 2/20/15.
//

#import "FLEXNetworkSettingsController.h"
#import "FLEXNetworkObserver.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXUtility.h"
#import "FLEXTableView.h"
#import "FLEXColor.h"
#import "NSUserDefaults+FLEX.h"

@interface AVX512NetworkSettingsController () <UIActionSheetDelegate>
@property (nonatomic) float cacheLimitValue;
@property (nonatomic, readonly) NSString *cacheLimitCellTitle;

@property (nonatomic, readonly) UISwitch *observerSwitch;
@property (nonatomic, readonly) UISwitch *cacheMediaSwitch;
@property (nonatomic, readonly) UISwitch *jsonViewerSwitch;
@property (nonatomic, readonly) UISlider *cacheLimitSlider;
@property (nonatomic) UILabel *cacheLimitLabel;

@property (nonatomic) NSMutableArray<NSString *> *hostDenylist;
@end

@implementation AVX512NetworkSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self disableToolbar];
    self.hostDenylist = AVX512NetworkRecorder.defaultRecorder.hostDenylist.mutableCopy;
    
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    _observerSwitch = [UISwitch new];
    _cacheMediaSwitch = [UISwitch new];
    _jsonViewerSwitch = [UISwitch new];
    _cacheLimitSlider = [UISlider new];
    
    self.observerSwitch.on = AVX512NetworkObserver.enabled;
    [self.observerSwitch addTarget:self
        action:@selector(networkDebuggingToggled:)
        forControlEvents:UIControlEventValueChanged
    ];
    
    self.cacheMediaSwitch.on = AVX512NetworkRecorder.defaultRecorder.shouldCacheMediaResponses;
    [self.cacheMediaSwitch addTarget:self
        action:@selector(cacheMediaResponsesToggled:)
        forControlEvents:UIControlEventValueChanged
    ];
    
    self.jsonViewerSwitch.on = defaults.avx512_registerDictionaryJSONViewerOnLaunch;
    [self.jsonViewerSwitch addTarget:self
        action:@selector(jsonViewerSettingToggled:)
        forControlEvents:UIControlEventValueChanged
    ];
    
    [self.cacheLimitSlider addTarget:self
        action:@selector(cacheLimitAdjusted:)
        forControlEvents:UIControlEventValueChanged
    ];
    
    UISlider *slider = self.cacheLimitSlider;
    self.cacheLimitValue = AVX512NetworkRecorder.defaultRecorder.responseCacheByteLimit;
    const NSUInteger fiftyMega = 50 * 1024 * 1024;
    slider.minimumValue = 0;
    slider.maximumValue = fiftyMega;
    slider.value = self.cacheLimitValue;
}

- (void)setCacheLimitValue:(float)cacheLimitValue {
    _cacheLimitValue = cacheLimitValue;
    self.cacheLimitLabel.text = self.cacheLimitCellTitle;
    [AVX512NetworkRecorder.defaultRecorder setResponseCacheByteLimit:cacheLimitValue];
}

- (NSString *)cacheLimitCellTitle {
    NSInteger cacheLimit = self.cacheLimitValue;
    NSInteger limitInMB = round(cacheLimit / (1024 * 1024));
    return [NSString stringWithFormat:@"Cache cache limit limitations on CaC (%@ MB)", @(limitInMB)];
}


#pragma mark - Settings Actions

- (void)networkDebuggingToggled:(UISwitch *)sender {
    AVX512NetworkObserver.enabled = sender.isOn;
}

- (void)cacheMediaResponsesToggled:(UISwitch *)sender {
    AVX512NetworkRecorder.defaultRecorder.shouldCacheMediaResponses = sender.isOn;
}

- (void)jsonViewerSettingToggled:(UISwitch *)sender {
    [NSUserDefaults.standardUserDefaults avx512_toggleBoolForKey:kAVX512DefaultsRegisterJSONExplorerKey];
}

- (void)cacheLimitAdjusted:(UISlider *)sender {
    self.cacheLimitValue = sender.value;
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 5;
        case 1: return self.hostDenylist.count;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Universal common universal, generic";
        case 1: return @"Host host hosts hosted hosting to reject list";
        default: return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"defaults, in the case of DefaultJSONShows in the web page view of a Webpage views "
        "\"will be expected that theJSONConsider as a diction dictionary in the/Group group of arrays to form\"To convert conversion to translate for convertingJSONA valid payload carry-on effective load "
        "Object and view objects in the object resource manager. Objects are also viewed with them within "
        "This setting settings need to restart the application re-re";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kAVX512DefaultCell forIndexPath:indexPath
    ];
    
    cell.accessoryView = nil;
    cell.textLabel.textColor = AVX512Color.primaryTextColor;
    
    switch (indexPath.section) {
        // Settings
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Network-net listen listening bug Listen switch switches turn Switch";
                    cell.accessoryView = self.observerSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"C cacheCache media responded response to Cac";
                    cell.accessoryView = self.cacheMediaSwitch;
                    break;
                case 2:
                    cell.textLabel.text = @"will be expected that theJSONConsider as a diction dictionary in the/Group group of arrays to form";
                    cell.accessoryView = self.jsonViewerSwitch;
                    break;
                case 3:
                    cell.textLabel.text = @"Reset header to re-reaga the host hosts '";
                    cell.textLabel.textColor = tableView.tintColor;
                    break;
                case 4:
                    cell.textLabel.text = self.cacheLimitCellTitle;
                    self.cacheLimitLabel = cell.textLabel;
                    [self.cacheLimitSlider removeFromSuperview];
                    [cell.contentView addSubview:self.cacheLimitSlider];
                    
                    CGRect container = cell.contentView.frame;
                    UISlider *slider = self.cacheLimitSlider;
                    [slider sizeToFit];
                    
                    CGFloat sliderWidth = 150.f;
                    CGFloat sliderOriginY = AVX512Floor((container.size.height - slider.frame.size.height) / 2.0);
                    CGFloat sliderOriginX = CGRectGetMaxX(container) - sliderWidth - tableView.separatorInset.left;
                    self.cacheLimitSlider.frame = CGRectMake(
                        sliderOriginX, sliderOriginY, sliderWidth, slider.frame.size.height
                    );
                    
                    // Make wider, keep in middle of cell, keep to trailing edge of cell
                    self.cacheLimitSlider.autoresizingMask = ({
                        UIViewAutoresizingFlexibleWidth |
                        UIViewAutoresizingFlexibleLeftMargin |
                        UIViewAutoresizingFlexibleTopMargin |
                        UIViewAutoresizingFlexibleBottomMargin;
                    });
                    break;
            }
            
            break;
        }
        
        // Denylist entries
        case 1: {
            cell.textLabel.text = self.hostDenylist[indexPath.row];
            break;
        }
        
        default:
            @throw NSInternalInconsistencyException;
            break;
    }

    return cell;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)ip {
    // Only one choice is the only option"Reset header to re-reaga the host hosts '"By doing all the
    return ip.section == 0 && ip.row == 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [AVX512Alert makeAlert:^(AVX512Alert *make) {
        make.title(@"Reset header to re-reaga the host hosts '");
        make.message(@"You can't undo this move. Are you sure?");
        make.button(@"Reset re-restor the over").destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            self.hostDenylist = nil;
            [AVX512NetworkRecorder.defaultRecorder.hostDenylist removeAllObjects];
            [AVX512NetworkRecorder.defaultRecorder synchronizeDenylist];
            [self.tableView deleteSections:
                [NSIndexSet indexSetWithIndex:1]
            withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)style
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(style == UITableViewCellEditingStyleDelete);
    
    NSString *host = self.hostDenylist[indexPath.row];
    [self.hostDenylist removeObjectAtIndex:indexPath.row];
    [AVX512NetworkRecorder.defaultRecorder.hostDenylist removeObject:host];
    [AVX512NetworkRecorder.defaultRecorder synchronizeDenylist];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
