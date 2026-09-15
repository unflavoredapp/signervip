#import "FLEXRuntimeHeaderViewController.h"
#import <objc/runtime.h>

@interface AVX512RuntimeHeaderViewController () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@end

@implementation AVX512RuntimeHeaderViewController

+ (instancetype)withClass:(Class)cls {
    AVX512RuntimeHeaderViewController *controller = [self new];
    controller.classObject = cls;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSStringFromClass(self.classObject);
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.font = [UIFont fontWithName:@"Menlo" size:14];
    self.textView.editable = NO;
    self.textView.text = [self generateHeaderForClass:self.classObject];
    [self.view addSubview:self.textView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
        target:self
        action:@selector(shareHeader)
    ];
}

- (void)shareHeader {
    NSString *header = [self generateHeaderForClass:self.classObject];
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] 
        initWithActivityItems:@[header] 
        applicationActivities:nil
    ];
    [self presentViewController:shareVC animated:YES completion:nil];
}

- (NSString *)generateHeaderForClass:(Class)cls {
    // from the fulfilment of realization, and AVX512MachOClassBrowserViewController Copy copy-copy duplicate
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