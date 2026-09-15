//
//  AVX512GlobalsSection.m
//  FLEX
//
//  Created by Tanner Bennett on 7/11/19.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXGlobalsSection.h"
#import "NSArray+FLEX.h"
#import "UIFont+FLEX.h"

@interface AVX512GlobalsSection ()
/// Filtered rows
@property (nonatomic) NSArray<AVX512GlobalsEntry *> *rows;
/// Unfiltered rows
@property (nonatomic) NSArray<AVX512GlobalsEntry *> *allRows;
@end
@implementation AVX512GlobalsSection

#pragma mark - Initialization

+ (instancetype)title:(NSString *)title rows:(NSArray<AVX512GlobalsEntry *> *)rows {
    AVX512GlobalsSection *s = [self new];
    s->_title = title;
    s.allRows = rows;

    return s;
}

- (void)setAllRows:(NSArray<AVX512GlobalsEntry *> *)allRows {
    _allRows = allRows.copy;
    [self reloadData];
}

#pragma mark - Overrides

- (NSInteger)numberOfRows {
    return self.rows.count;
}

- (void)setFilterText:(NSString *)filterText {
    super.filterText = filterText;
    [self reloadData];
}

- (void)reloadData {
    NSString *filterText = self.filterText;
    
    if (filterText.length) {
        self.rows = [self.allRows avx512_filtered:^BOOL(AVX512GlobalsEntry *entry, NSUInteger idx) {
            return [entry.entryNameFuture() localizedCaseInsensitiveContainsString:filterText];
        }];
    } else {
        self.rows = self.allRows;
    }
}

- (BOOL)canSelectRow:(NSInteger)row {
    return YES;
}

- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    return (id)self.rows[row].rowAction;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return self.rows[row].viewControllerFuture ? self.rows[row].viewControllerFuture() : nil;
}

- (void)configureCell:(__kindof UITableViewCell *)cell forRow:(NSInteger)row {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = UIFont.avx512_defaultTableCellFont;
    NSString *title = self.rows[row].entryNameFuture();
    cell.textLabel.text = title;

    // Unique SF Symbol per globals entry (replaces the old hard-coded emoji).
    // Keyed off the clean title so no entry-class changes are needed.
    static NSDictionary<NSString *, NSString *> *symbols = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        symbols = @{
            @"App Delegate":                 @"app.badge",
            @"Key Window":                   @"macwindow",
            @"Root View Controller":         @"rectangle.stack",
            @"Process Info":                 @"cpu",
            @"NSUserDefaults":               @"externaldrive",
            @"Main Bundle":                  @"shippingbox",
            @"UIApplication.shared":         @"app.dashed",
            @"UIScreen.main":                @"display",
            @"UIDevice.current":             @"iphone",
            @"UIPasteboard.general":         @"doc.on.clipboard",
            @"NSURLSession.shared":          @"antenna.radiowaves.left.and.right",
            @"NSURLCache.shared":            @"hourglass",
            @"NSNotificationCenter.default": @"bell",
            @"UIMenuController.shared":      @"filemenu.and.selection",
            @"NSFileManager.default":        @"folder",
            @"NSTimeZone.system":            @"globe",
            @"NSLocale.current":             @"character.bubble",
            @"NSCalendar.current":           @"calendar",
            @"NSRunLoop.main":               @"arrow.triangle.2.circlepath",
            @"NSThread.main":                @"line.3.horizontal",
            @"NSOperationQueue.main":        @"square.stack.3d.up",
            @"Network History":              @"antenna.radiowaves.left.and.right",
            @"System Log":                   @"doc.text.magnifyingglass",
            @"Address Explorer":             @"magnifyingglass",
            @"Runtime Browser":              @"books.vertical",
            @"Live Objects":                 @"cube.transparent",
            @"Push Notifications":           @"bell.badge",
            @"Keychain":                     @"key",
            @"Browse Bundle":                @"folder",
            @"Browse Container":             @"folder.badge.gearshape",
            @"Cookies":                      @"birthday.cake",
            @"Runtime Analysis":             @"scope",
            @"Class Hierarchy":              @"list.bullet.indent",
            @"Memory Analyzer":              @"memorychip",
            @"Hook Detector":                @"link",
            @"Framework Browser":            @"books.vertical",
        };
    });
    NSString *symbolName = symbols[title];
    if (symbolName) {
        cell.imageView.image = [UIImage systemImageNamed:symbolName];
        cell.imageView.tintColor = UIColor.systemBlueColor;
    } else {
        cell.imageView.image = nil;
    }
}

@end


@implementation AVX512GlobalsSection (Subscripting)

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.rows[idx];
}

@end
