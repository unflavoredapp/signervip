#import "FLEXDoKitPerformanceMonitor.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/time.h>

// Comp compatibility with the compatible processing treatment process
#ifndef __has_include
#define __has_include(x) 0
#endif

#if __has_include(<ifaddrs.h>)
#import <ifaddrs.h>
#import <net/if.h>
#import <net/if_dl.h>
#define AVX512_NETWORK_MONITORING_AVAILABLE 1
#else
#define AVX512_NETWORK_MONITORING_AVAILABLE 0
#warning "Network monitor and control functions are not available for network: missing information isifaddrs.hSupport for support to the"
#endif

@interface AVX512DoKitPerformanceMonitor ()
@property (nonatomic, strong) CADisplayLink *fpsDisplayLink;
@property (nonatomic, strong) NSTimer *cpuTimer;
@property (nonatomic, strong) NSTimer *memoryTimer;
@property (nonatomic, strong) CADisplayLink *lagDetectionDisplayLink;
@property (nonatomic, strong) NSTimer *networkTimer;
@property (nonatomic, assign) CFTimeInterval lastFPSTime;
@property (nonatomic, assign) CFTimeInterval lastLagCheckTime;
@property (nonatomic, assign) NSInteger fpsCount;
@property (nonatomic, assign) NSInteger lagFrameCount;
@property (nonatomic, assign) uint64_t uploadFlowBytes;
@property (nonatomic, assign) uint64_t downloadFlowBytes;
@end

@implementation AVX512DoKitPerformanceMonitor

+ (instancetype)sharedInstance {
    static AVX512DoKitPerformanceMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startFPSMonitoring {
    if (self.fpsDisplayLink) return;
    
    self.fpsDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(fpsDisplayLinkTick:)];
    [self.fpsDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.lastFPSTime = CACurrentMediaTime();
    self.fpsCount = 0;
}

- (void)stopFPSMonitoring {
    [self.fpsDisplayLink invalidate];
    self.fpsDisplayLink = nil;
}

- (void)fpsDisplayLinkTick:(CADisplayLink *)displayLink {
    self.fpsCount++;
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval deltaTime = currentTime - self.lastFPSTime;
    
    if (deltaTime >= 1.0) {
        _currentFPS = self.fpsCount / deltaTime;
        self.fpsCount = 0;
        self.lastFPSTime = currentTime;
        
        // Send sent to send outFPSUpdate the update notification notice updating updates
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitFPSUpdated" 
                                                            object:@(self.currentFPS)];
    }
}

- (void)startCPUMonitoring {
    if (self.cpuTimer) return;
    
    self.cpuTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                     target:self
                                                   selector:@selector(updateCPUUsage)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)stopCPUMonitoring {
    [self.cpuTimer invalidate];
    self.cpuTimer = nil;
}

- (void)updateCPUUsage {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCount = 0;
    
    if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
        return;
    }
    
    double totalCPU = 0;
    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t threadInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        
        if (thread_info(threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            thread_basic_info_t basicInfo = (thread_basic_info_t)threadInfo;
            if (!(basicInfo->flags & TH_FLAGS_IDLE)) {
                totalCPU += basicInfo->cpu_usage / (double)TH_USAGE_SCALE * 100.0;
            }
        }
    }
    
    vm_deallocate(mach_task_self(), (vm_offset_t)threads, threadCount * sizeof(thread_t));
    
    _currentCPUUsage = totalCPU;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitCPUUpdated" 
                                                        object:@(self.currentCPUUsage)];
}

- (void)startMemoryMonitoring {
    if (self.memoryTimer) return;
    
    self.memoryTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateMemoryUsage)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopMemoryMonitoring {
    [self.memoryTimer invalidate];
    self.memoryTimer = nil;
}

- (void)updateMemoryUsage {
    vm_size_t page_size;
    mach_port_t mach_port = mach_host_self();
    host_page_size(mach_port, &page_size);
    
    vm_statistics64_data_t vm_stat;
    mach_msg_type_number_t host_size = sizeof(vm_statistics64_data_t) / sizeof(natural_t);
    host_statistics64(mach_port, HOST_VM_INFO, (host_info64_t)&vm_stat, &host_size);
    
    // Calculate memory usage (calc calculates the use ofMB()), and the
    uint64_t used_memory = (uint64_t)(vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * page_size;
    _currentMemoryUsage = used_memory / (1024.0 * 1024.0);
    
    // Send RAM memory update updates notification to send the Memory
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitMemoryUpdated" 
                                                        object:@(self.currentMemoryUsage)];
}

- (void)startLagDetection {
    // Use the use of usageCADisplayLinkTest primary thread to detect main line for detection of Carton
    if (self.lagDetectionDisplayLink) {
        [self stopLagDetection];
    }
    
    self.lagDetectionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(lagDetectionTick:)];
    [self.lagDetectionDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    self.lastLagCheckTime = CACurrentMediaTime();
    self.lagFrameCount = 0;
    
    NSLog(@"✅ Catton test has been activated for start-");
}

- (void)stopLagDetection {
    if (self.lagDetectionDisplayLink) {
        [self.lagDetectionDisplayLink invalidate];
        self.lagDetectionDisplayLink = nil;
        NSLog(@"✅ Carton test has stopped for Caden cat");
    }
}

- (void)lagDetectionTick:(CADisplayLink *)displayLink {
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval deltaTime = currentTime - self.lastLagCheckTime;
    
    // The normal frame range rate should be the standard frames1/60 ≈ 0.0167seconds second sec ss
    if (deltaTime > 0.033) { // over more than excess of2Frametime thought Carton Caden was the catun
        self.lagFrameCount++;
    }
    
    self.lastLagCheckTime = currentTime;
    
    // One time every second a seconds of the Carton conden
    static CFTimeInterval lastReportTime = 0;
    if (currentTime - lastReportTime >= 1.0) {
        if (self.lagFrameCount > 0) {
            NSLog(@"⚠️ Cartun frame detected caden core detect detection to: %ld", (long)self.lagFrameCount);
            
            // Send Carton notification notice for Caden to send
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitLagDetected" 
                                                                object:@(self.lagFrameCount)];
        }
        
        self.lagFrameCount = 0;
        lastReportTime = currentTime;
    }
}

- (void)calculateAppLaunchTime {
    // Ret capture process start-up time to get
    struct kinfo_proc proc;
    size_t size = sizeof(proc);
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    
    if (sysctl(mib, 4, &proc, &size, NULL, 0) == 0) {
        struct timeval startTime = proc.kp_proc.p_starttime;
        
        // Calculates the time between start-up and commencement to
        struct timeval currentTime;
        gettimeofday(&currentTime, NULL);
        
        NSTimeInterval launchTime = (currentTime.tv_sec - startTime.tv_sec) + 
                                   (currentTime.tv_usec - startTime.tv_usec) / 1000000.0;
        
        _appLaunchTime = launchTime;
        
        NSLog(@"📱 Application start-up timed to apply the application: %.3fseconds second sec ss", launchTime);
        
        // Send a notice of start time notification to send the
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitAppLaunchTimeCalculated" 
                                                            object:@(launchTime)];
    } else {
        NSLog(@"❌ Could not calculate applied startup time application to the applicable");
        _appLaunchTime = 0;
    }
}

- (void)startNetworkMonitoring {
    // Act to activate the launch of network traffic-flow
    if (self.networkTimer) return;
    
    self.networkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(updateNetworkUsage)
                                                       userInfo:nil
                                                        repeats:YES];
    
    [self resetNetworkCounters];
}

- (void)stopNetworkMonitoring {
    [self.networkTimer invalidate];
    self.networkTimer = nil;
}

- (void)updateNetworkUsage {
#if AVX512_NETWORK_MONITORING_AVAILABLE
    // ✅ only compile and translate the web-based monitoring network (webs) security control code codes
    struct ifaddrs *addrs = NULL;
    
    @try {
        if (getifaddrs(&addrs) == 0) {
            struct ifaddrs *cursor = addrs;
            
            uint64_t totalUploadBytes = 0;
            uint64_t totalDownloadBytes = 0;
            
            while (cursor != NULL) {
                // ✅ Check check network interface type types for checking the web
                if (cursor->ifa_addr && cursor->ifa_addr->sa_family == AF_LINK) {
                    struct if_data *if_data = (struct if_data *)cursor->ifa_data;
                    if (if_data) {
                        totalUploadBytes += if_data->ifi_obytes;
                        totalDownloadBytes += if_data->ifi_ibytes;
                    }
                }
                cursor = cursor->ifa_next;
            }
            
            // Calculates the flow speed to calculate traffic-rate (by/s (s) seconds(second
            static uint64_t lastUploadBytes = 0;
            static uint64_t lastDownloadBytes = 0;
            
            if (lastUploadBytes > 0 && lastDownloadBytes > 0) {
                _uploadFlowBytes = totalUploadBytes - lastUploadBytes;
                _downloadFlowBytes = totalDownloadBytes - lastDownloadBytes;
            } else {
                // Runs first run for start-first running, initial
                _uploadFlowBytes = 0;
                _downloadFlowBytes = 0;
            }
            
            lastUploadBytes = totalUploadBytes;
            lastDownloadBytes = totalDownloadBytes;
            
            // Send send sent web-net update notification notice for
            NSDictionary *networkInfo = @{
                @"upload": @(self.uploadFlowBytes),
                @"download": @(self.downloadFlowBytes),
                @"totalUpload": @(totalUploadBytes),
                @"totalDownload": @(totalDownloadBytes)
            };
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitNetworkUpdated" 
                                                                    object:networkInfo];
            });
            
        } else {
            NSLog(@"⚠️ Failed to fail failed failure in the error fetching web");
        }
        
    } @finally {
        if (addrs) {
            freeifaddrs(addrs);
        }
    }
#else
    // Platform platform platforms that do not support a web-based
    NSLog(@"⚠️ The current platform currently does not support the web-based monitoring and network");
    
    // Send Empty empty network information to send an vacant web-
    NSDictionary *networkInfo = @{
        @"upload": @0,
        @"download": @0,
        @"error": @"No support for network-based surveillance and"
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVX512DoKitNetworkUpdated" 
                                                            object:networkInfo];
    });
#endif
}

- (void)resetNetworkCounters {
    _uploadFlowBytes = 0;
    _downloadFlowBytes = 0;
}

@end