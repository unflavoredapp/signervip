#import "FLEXMachOClassBrowserViewController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXRuntimeHeaderViewController.h"
#import "UIBarButtonItem+FLEX.h"

@implementation AVX512MachOClassBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ClassCell"];
    
    // Adds to the Export Origin First forEx-Out first
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem 
        avx512_itemWithTitle:@"All all exports out of the export"
        target:self 
        action:@selector(exportAllHeaders)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.classNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassCell" forIndexPath:indexPath];
    
    NSString *className = self.classNames[indexPath.row];
    cell.textLabel.text = className;
    cell.textLabel.font = [UIFont fontWithName:@"Menlo" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *className = self.classNames[indexPath.row];
    Class cls = NSClassFromString(className);
    
    if (cls) {
        // Create a create-C creation class brows
        UIViewController *classExplorer = [AVX512ObjectExplorerFactory explorerViewControllerForObject:cls];
        [self.navigationController pushViewController:classExplorer animated:YES];
    }
}

- (void)exportAllHeaders {
    // From all from the RuntimeBrowser The function of a transplant for which the
    NSMutableString *allHeaders = [NSMutableString string];
    
    for (NSString *className in self.classNames) {
        Class cls = NSClassFromString(className);
        if (cls) {
            NSString *header = [self generateHeaderForClass:cls];
            [allHeaders appendFormat:@"// %@\n%@\n\n", className, header];
        }
    }
    
    // Create temporary files and share sharing to create ad-s
    NSString *fileName = [NSString stringWithFormat:@"%@_headers.h", self.title];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    NSError *error;
    BOOL success = [allHeaders writeToFile:tempPath 
                                atomically:YES 
                                  encoding:NSUTF8StringEncoding 
                                     error:&error];
    
    if (success) {
        NSURL *fileURL = [NSURL fileURLWithPath:tempPath];
        UIActivityViewController *shareVC = [[UIActivityViewController alloc] 
                                           initWithActivityItems:@[fileURL] 
                                           applicationActivities:nil];
        [self presentViewController:shareVC animated:YES completion:nil];
    }
}

- (NSString *)generateHeaderForClass:(Class)cls {
    // From all from the RTBRuntimeHeader The transplant's head start-of the imm
    NSMutableString *header = [NSMutableString string];
    
    if (!cls) return @"";
    
    // type of declarations, declaration-type
    Class superclass = class_getSuperclass(cls);
    NSString *superclassName = superclass ? NSStringFromClass(superclass) : @"NSObject";
    
    [header appendFormat:@"@interface %@ : %@\n\n", NSStringFromClass(cls), superclassName];
    
    // The property of the attribute
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    
    if (propertyCount > 0) {
        [header appendString:@"// Properties\n"];
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            const char *propertyAttributes = property_getAttributes(property);
            
            [header appendFormat:@"@property %s %s;\n", propertyAttributes, propertyName];
        }
        [header appendString:@"\n"];
    }
    free(properties);
    
    // Example example examples of methodological case-
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    if (methodCount > 0) {
        [header appendString:@"// Instance Methods\n"];
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            const char *typeEncoding = method_getTypeEncoding(method);
            
            [header appendFormat:@"- (%s)%s;\n", typeEncoding, sel_getName(selector)];
        }
        [header appendString:@"\n"];
    }
    free(methods);
    
    // Category group of methodological methodologies for categories
    methods = class_copyMethodList(object_getClass(cls), &methodCount);
    
    if (methodCount > 0) {
        [header appendString:@"// Class Methods\n"];
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            const char *typeEncoding = method_getTypeEncoding(method);
            
            [header appendFormat:@"+ (%s)%s;\n", typeEncoding, sel_getName(selector)];
        }
        [header appendString:@"\n"];
    }
    free(methods);
    
    [header appendString:@"@end"];
    
    return header;
}

@end