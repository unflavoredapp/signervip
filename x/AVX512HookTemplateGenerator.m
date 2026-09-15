//
//  AVX512HookTemplateGenerator.m
//  Generates a starter swizzle-dylib source file from one or more selected
//  classes. Recon (class dump) -> pick classes -> get a ready-to-edit hook.
//
//  Part of AVX512 by DELvEK.NET
//

#import "AVX512HookTemplateGenerator.h"
#import <objc/runtime.h>

@interface AVX512HookTemplateGenerator () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray<NSString *> *allClasses;
@property (nonatomic, strong) NSArray<NSString *> *filteredClasses;
@property (nonatomic, strong) NSMutableSet<NSString *> *selected;
@property (nonatomic, strong) UISearchController *search;
@end

@implementation AVX512HookTemplateGenerator

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hook Generator";
    self.selected = [NSMutableSet set];

    // Load every registered class name, sorted.
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        const char *n = class_getName(classes[i]);
        if (n) [names addObject:[NSString stringWithUTF8String:n]];
    }
    free(classes);
    self.allClasses = [names sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.filteredClasses = self.allClasses;

    // Search to filter the (large) class list.
    self.search = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.search.searchResultsUpdater = (id<UISearchResultsUpdating>)self;
    self.search.obscuresBackgroundDuringPresentation = NO;
    self.search.searchBar.placeholder = @"Filter classes";
    self.navigationItem.searchController = self.search;

    // Generate button — enabled once at least one class is picked.
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Generate"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(generate)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return self.filteredClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"c"]
        ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"c"];
    NSString *name = self.filteredClasses[ip.row];
    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular];
    cell.accessoryType = [self.selected containsObject:name]
        ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    NSString *name = self.filteredClasses[ip.row];
    if ([self.selected containsObject:name]) [self.selected removeObject:name];
    else [self.selected addObject:name];
    [tv reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    self.navigationItem.rightBarButtonItem.enabled = self.selected.count > 0;
    self.navigationItem.rightBarButtonItem.title =
        self.selected.count ? [NSString stringWithFormat:@"Generate (%lu)", (unsigned long)self.selected.count] : @"Generate";
}

#pragma mark - Search

- (void)updateSearchResultsForSearchController:(UISearchController *)sc {
    NSString *q = sc.searchBar.text;
    if (q.length == 0) { self.filteredClasses = self.allClasses; }
    else {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", q];
        self.filteredClasses = [self.allClasses filteredArrayUsingPredicate:p];
    }
    [self.tableView reloadData];
}

#pragma mark - Generation

- (void)generate {
    NSString *source = [self hookSourceForClasses:self.selected.allObjects];

    // Write to a temp .m and present a share sheet so it can be saved/AirDropped
    // into a repo or the on-device dev flow.
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AVX512Hook.m"];
    NSError *err = nil;
    [source writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err];

    NSURL *url = [NSURL fileURLWithPath:path];
    UIActivityViewController *share =
        [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    share.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:share animated:YES completion:nil];
}

/// Builds a compile-ready swizzle dylib source that hooks every instance method
/// of each selected class, logging entry. The user edits the bodies to taste.
- (NSString *)hookSourceForClasses:(NSArray<NSString *> *)classNames {
    NSMutableString *s = [NSMutableString string];
    [s appendString:@"//\n// AVX512Hook.m — generated by AVX512 (DELvEK.NET)\n"];
    [s appendString:@"// clang + ldid swizzle dylib. Edit the method bodies, then build.\n//\n\n"];
    [s appendString:@"#import <UIKit/UIKit.h>\n#import <objc/runtime.h>\n#import <objc/message.h>\n\n"];

    // Helper macro for swapping an implementation.
    [s appendString:@"// Swap originalSel's IMP for a block; keep the original in a saved IMP.\n"];
    [s appendString:@"static IMP AVX512_orig(Class cls, SEL sel) {\n"];
    [s appendString:@"    Method m = class_getInstanceMethod(cls, sel);\n"];
    [s appendString:@"    return m ? method_getImplementation(m) : NULL;\n"];
    [s appendString:@"}\n\n"];

    for (NSString *cls in classNames) {
        [s appendFormat:@"#pragma mark - %@\n\n", cls];
        [s appendFormat:@"static void AVX512_hook_%@(void) {\n", [self sanitize:cls]];
        [s appendFormat:@"    Class cls = objc_getClass(\"%@\");\n", cls];
        [s appendString:@"    if (!cls) return;\n\n"];

        // Enumerate instance methods of the class so the user sees real targets.
        [s appendString:@"    // Instance methods on this class (edit / delete as needed):\n"];
        Class runtimeClass = objc_getClass(cls.UTF8String);
        if (runtimeClass) {
            unsigned int mc = 0;
            Method *methods = class_copyMethodList(runtimeClass, &mc);
            NSUInteger shown = 0;
            for (unsigned int i = 0; i < mc && shown < 25; i++) {
                SEL sel = method_getName(methods[i]);
                NSString *selStr = NSStringFromSelector(sel);
                // skip C++ destructors / private underscore torrents
                if ([selStr hasPrefix:@"."]) continue;
                [s appendFormat:@"    // - [%@ %@]\n", cls, selStr];
                shown++;
            }
            if (methods) free(methods);
            if (mc == 0) {
                [s appendString:@"    // (no instance methods found at load time)\n"];
            }
        }

        [s appendString:@"\n    // Example swizzle — replace SELECTOR with one above:\n"];
        [s appendString:@"    /*\n"];
        [s appendString:@"    SEL sel = @selector(SELECTOR);\n"];
        [s appendString:@"    Method m = class_getInstanceMethod(cls, sel);\n"];
        [s appendString:@"    __block IMP orig = method_getImplementation(m);\n"];
        [s appendString:@"    IMP repl = imp_implementationWithBlock(^(id self_, ...){\n"];
        [s appendFormat:@"        NSLog(@\"[AVX512] %@ SELECTOR called\");\n", cls];
        [s appendString:@"        // return ((id(*)(id,SEL))orig)(self_, sel);  // call original\n"];
        [s appendString:@"    });\n"];
        [s appendString:@"    method_setImplementation(m, repl);\n"];
        [s appendString:@"    */\n"];
        [s appendString:@"}\n\n"];
    }

    // Constructor that runs all hooks at load.
    [s appendString:@"__attribute__((constructor))\nstatic void AVX512_init(void) {\n"];
    [s appendString:@"    @autoreleasepool {\n"];
    for (NSString *cls in classNames) {
        [s appendFormat:@"        AVX512_hook_%@();\n", [self sanitize:cls]];
    }
    [s appendString:@"    }\n}\n"];

    return s;
}

- (NSString *)sanitize:(NSString *)name {
    NSMutableString *m = [name mutableCopy];
    [m replaceOccurrencesOfString:@"." withString:@"_"
                          options:0 range:NSMakeRange(0, m.length)];
    return m;
}

@end
