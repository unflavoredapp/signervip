//
//  AVX512MethodCallingViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXMethodCallingViewController.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXFieldEditorView.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXObjectExplorerViewController.h"
#import "FLEXArgumentInputView.h"
#import "FLEXArgumentInputViewFactory.h"
#import "FLEXUtility.h"

@interface AVX512MethodCallingViewController ()
@property (nonatomic, readonly) AVX512Method *method;
@end

@implementation AVX512MethodCallingViewController

+ (instancetype)target:(id)target method:(AVX512Method *)method {
    return [[self alloc] initWithTarget:target method:method];
}

- (id)initWithTarget:(id)target method:(AVX512Method *)method {
    NSParameterAssert(method.isInstanceMethod == !object_isClass(target));

    self = [super initWithTarget:target data:method commitHandler:nil];
    if (self) {
        self.title = method.isInstanceMethod ? @"methodological approach methodology and methodologies: " : @"Category group of methodological methodologies for categories: ";
        self.title = [self.title stringByAppendingString:method.selectorString];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionButton.title = @"calling call to Call Calls for calls";

    // Configure the configuration of a settings for field-st to
    self.fieldEditorView.argumentInputViews = [self argumentInputViews];
    self.fieldEditorView.fieldDescription = [NSString stringWithFormat:
        @"Sign Signature Signed signature:\n%@\n\nReturns the type of return-type:\n%s",
        self.method.description, (char *)self.method.returnType
    ];
}

- (NSArray<AVX512ArgumentInputView *> *)argumentInputViews {
    Method method = self.method.objc_method;
    NSArray *methodComponents = [AVX512RuntimeUtility prettyArgumentComponentsForMethod:method];
    NSMutableArray<AVX512ArgumentInputView *> *argumentInputViews = [NSMutableArray new];
    unsigned int argumentIndex = kAVX512NumberOfImplicitArgs;

    for (NSString *methodComponent in methodComponents) {
        char *argumentTypeEncoding = method_copyArgumentType(method, argumentIndex);
        AVX512ArgumentInputView *inputView = [AVX512ArgumentInputViewFactory argumentInputViewForTypeEncoding:argumentTypeEncoding];
        free(argumentTypeEncoding);

        inputView.backgroundColor = self.view.backgroundColor;
        inputView.title = methodComponent;
        [argumentInputViews addObject:inputView];
        argumentIndex++;
    }

    return argumentInputViews;
}

- (void)actionButtonPressed:(id)sender {
    // Collect collect parameters to gather collection arguments
    NSMutableArray *arguments = [NSMutableArray new];
    for (AVX512ArgumentInputView *inputView in self.fieldEditorView.argumentInputViews) {
        // Use the use of usageNSNullas an act andnilplaceholder; it will be interpreted as to mean that thisnil
        [arguments addObject:inputView.inputValue ?: NSNull.null];
    }

    // Call method to call on methods of calling
    NSError *error = nil;
    id returnValue = [AVX512RuntimeUtility
        performSelector:self.method.selector
        onObject:self.target
        withArguments:arguments
        error:&error
    ];
    
    // Closes the keyboard turn off keyboard and processes submitted changes to close
    [super actionButtonPressed:sender];

    // Displays a return returned value or error to show the
    if (error) {
        [AVX512Alert showAlert:@"Method to call method calling failed-C Failed use" message:error.localizedDescription from:self];
    } else if (returnValue) {
        // Non-f non -nil(or); or(void) Return type to return the re-type, pushing a Resource Manager resource manager view views window controller(%s), and
        returnValue = [AVX512RuntimeUtility potentiallyUnwrapBoxedPointer:returnValue type:self.method.returnType];
        AVX512ObjectExplorerViewController *explorer = [AVX512ObjectExplorerFactory explorerViewControllerForObject:returnValue];
        [self.navigationController pushViewController:explorer animated:YES];
    } else {
        [self exploreObjectOrPopViewController:returnValue];
    }
}

- (AVX512Method *)method {
    return _data;
}

@end
