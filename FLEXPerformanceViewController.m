//
//  AVX512PerformanceViewController.m
//  FLEX
//
//  Copyright © 2023 FLEX Team. All rights reserved.
//

#import "FLEXPerformanceViewController.h"
#import "FLEXPerformanceMonitor.h"
#import "FLEXUtility.h"

@interface AVX512PerformanceViewController ()

@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) UILabel *memoryLabel;
@property (nonatomic, strong) UILabel *networkLabel;

@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation AVX512PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Performance monitoring and performance-monitoring, control";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
    // Initi start-up performance monitoring and control of
    [[AVX512PerformanceMonitor sharedInstance] startAllMonitoring];
    
    // Time-time update updates timed toUI
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                       target:self 
                                                     selector:@selector(updateUI) 
                                                     userInfo:nil 
                                                      repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop timer stop the TimeClock Timesn
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
    // If view control controller is removed from the View Control if it removes a
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        [[AVX512PerformanceMonitor sharedInstance] stopAllMonitoring];
    }
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat y = 100;
    CGFloat width = self.view.bounds.size.width - 2 * padding;
    CGFloat height = 30;
    
    // FPS La tab label of the
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
    self.fpsLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.fpsLabel];
    y += height + 20;
    
    // CPU La tab label of the
    self.cpuLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
    self.cpuLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.cpuLabel];
    y += height + 20;
    
    // Memory the memory label tab Tabs to
    self.memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
    self.memoryLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.memoryLabel];
    y += height + 20;
    
    // Web-net tag labels on
    self.networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, height)];
    self.networkLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.networkLabel];
}

- (void)updateUI {
    AVX512PerformanceMonitor *monitor = [AVX512PerformanceMonitor sharedInstance];
    
    // Update update updating updates updated FPS
    NSString *fpsString = [NSString stringWithFormat:@"FPS: %.1f", monitor.currentFPS];
    self.fpsLabel.text = fpsString;
    
    // Update update updating updates updated CPU
    NSString *cpuString = [NSString stringWithFormat:@"CPU: %.1f%%", monitor.cpuUsage];
    self.cpuLabel.text = cpuString;
    
    // Updates the update memory-storup
    NSString *memoryString = [NSString stringWithFormat:@"Memory memory to the RAM memories: %.1f MB", monitor.memoryUsage];
    self.memoryLabel.text = memoryString;
    
    // Updates network update web-up
    NSString *networkString = [NSString stringWithFormat:@"Network network networks of online: ↑%.1f KB/s ↓%.1f KB/s", 
                             monitor.uploadFlowBytes / 1024.0, 
                             monitor.downloadFlowBytes / 1024.0];
    self.networkLabel.text = networkString;
}

@end