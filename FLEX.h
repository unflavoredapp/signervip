//
//  FLEX.h
//  FLEX
//
//  Created by Eric Horacek on 7/18/15.
//  Modified by Tanner Bennett on 3/12/20.
//  Copyright (c) 2025 for pxx917144686 FLEX Team. All rights reserved.
//

// === Core core architecture, central structure and ===
#import "FLEXManager.h"
#import "FLEXManager+Extensibility.h"
#import "FLEXManager+Networking.h"
#import "FLEXManager+DoKitExtensions.h"
#import "FLEXCompatibility.h"  // ✅ Compcompability compatibility compatible interoperability

#import "FLEXExplorerToolbar.h"
#import "FLEXExplorerToolbarItem.h"
#import "FLEXGlobalsEntry.h"

#import "FLEX-Core.h"
#import "FLEX-Runtime.h"
#import "FLEX-Categories.h"
#import "FLEX-ObjectExploring.h"

#import "FLEXMacros.h"
#import "FLEXAlert.h"
#import "FLEXResources.h"

// === DoKit Core core component parts, hard- ===
#import "FLEXDoKitManager.h"
#import "FLEXDoKitPerformanceMonitor.h"
#import "FLEXDoKitNetworkMonitor.h"
#import "FLEXDoKitVisualTools.h"
#import "FLEXDoKitCrashMonitor.h"
#import "FLEXDoKitLogViewer.h"
#import "FLEXDoKitLogEntry.h"  // ✅ Type type-type definition of the
#import "FLEXDoKitMemoryLeakDetector.h"

// === Main main primary controller master controlr ===
//#import "FLEXBugViewController.h"

// === Performance monitoring and performance-monitoring, control ===
#import "FLEXPerformanceViewController.h"
#import "FLEXMemoryMonitorViewController.h"
#import "FLEXFPSMonitorViewController.h"
#import "FLEXDoKitCPUViewController.h"
#import "FLEXDoKitLagViewController.h"
#import "FLEXMemoryLeakDetectorViewController.h"
#import "FLEXDoKitCrashViewController.h"

// === Web-net tool tools for web ===
#import "FLEXNetworkMonitorViewController.h"
#import "FLEXAPITestViewController.h"
#import "FLEXDoKitMockViewController.h"
#import "FLEXDoKitNetworkViewController.h"
#import "FLEXDoKitNetworkHistoryViewController.h"
#import "FLEXDoKitWeakNetworkViewController.h"
#import "FLEXNetworkMITMViewController.h"

// === Visual visual tools for video-visual ===
#import "FLEXDoKitColorPickerViewController.h"
#import "FLEXDoKitComponentViewController.h"
#import "FLEXDoKitVisualToolsViewController.h" 

// === The LogL log Journal journal tool ===
#import "FLEXDoKitLogViewController.h"
#import "FLEXDoKitLogFilterViewController.h"

// === Commonly-used tools, common ===
#import "FLEXDoKitAppInfoViewController.h"
#import "FLEXDoKitSystemInfoViewController.h"
#import "FLEXDoKitCleanViewController.h"
#import "FLEXDoKitUserDefaultsViewController.h"
#import "FLEXFileBrowserController.h"
#import "FLEXDoKitFileBrowserViewController.h"
#import "FLEXDoKitH5ViewController.h"
#import "FLEXDoKitDatabaseViewController.h"

// === RevealIntegrated In all integral parts, integrated ===
#import "FLEXRevealLikeInspector.h"
#import "FLEXRevealInspectorViewController.h"

// === LookinIntegrated In all integral parts, integrated ===
#import "FLEXLookinInspector.h"
#import "FLEXLookinHierarchyViewController.h"
#import "FLEXLookinComparisonViewController.h"
#import "FLEXLookinMeasureController.h"
#import "FLEXLookinMeasureResultView.h"
#import "FLEXLookinDisplayItem.h"
#import "FLEXLookinPreviewController.h"
#import "FLEXLookinMeasureViewController.h"

// === Run-R running time runtime analysis ===
#import "FLEXRuntimeClient.h"
#import "FLEXRuntimeClient+RuntimeBrowser.h"
#import "FLEXHookDetector.h"

// === Error repair tool to bug fix restoration utility ===
#import "FLEXSystemLogViewController.h"
#import "FLEXHierarchyTableViewController.h"

// === System system analysis and systematic analytical systems ===
#import "FLEXSystemAnalyzerViewController.h"
