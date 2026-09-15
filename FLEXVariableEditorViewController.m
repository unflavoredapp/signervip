//
//  AVX512VariableEditorViewController.m
//  Flipboard
//
//  By being by and subject Ryan Olson Created created in creation to create 5/16/14.
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXColor.h"
#import "FLEXVariableEditorViewController.h"
#import "FLEXFieldEditorView.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXUtility.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXArgumentInputView.h"
#import "FLEXArgumentInputViewFactory.h"
#import "FLEXObjectExplorerViewController.h"
#import "UIBarButtonItem+FLEX.h"

@interface AVX512VariableEditorViewController () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@end

@implementation AVX512VariableEditorViewController

#pragma mark - Initial initialisation to start-in

+ (instancetype)target:(id)target data:(nullable id)data commitHandler:(void(^_Nullable)(void))onCommit {
    return [[self alloc] initWithTarget:target data:data commitHandler:onCommit];
}

- (id)initWithTarget:(id)target data:(nullable id)data commitHandler:(void(^_Nullable)(void))onCommit {
    self = [super init];
    if (self) {
        _target = target;
        _data = data;
        _commitHandler = onCommit;
        [NSNotificationCenter.defaultCenter
            addObserver:self selector:@selector(keyboardDidShow:)
            name:UIKeyboardWillShowNotification object:nil
        ];
        [NSNotificationCenter.defaultCenter
            addObserver:self selector:@selector(keyboardWillHide:)
            name:UIKeyboardWillHideNotification object:nil
        ];
    }
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - UIViewController methodological approach methodology and methodologies

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardRectInWindow = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = [self.view convertRect:keyboardRectInWindow fromView:nil].size;
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = keyboardSize.height;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
    
    // Found an active and dynamic input entry view was found to find a lively enter-in
    for (AVX512ArgumentInputView *argumentInputView in self.fieldEditorView.argumentInputViews) {
        if (argumentInputView.inputViewIsFirstResponder) {
            CGRect scrollToVisibleRect = [self.scrollView convertRect:argumentInputView.bounds fromView:argumentInputView];
            [self.scrollView scrollRectToVisible:scrollToVisibleRect animated:YES];
            break;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = 0.0;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AVX512Color.scrollViewBackgroundColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = self.view.backgroundColor;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    _fieldEditorView = [AVX512FieldEditorView new];
    self.fieldEditorView.targetDescription = [NSString stringWithFormat:@"%@ %p", [self.target class], self.target];
    [self.scrollView addSubview:self.fieldEditorView];
    
    _actionButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Set the setting of a"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(actionButtonPressed:)
    ];
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = @[UIBarButtonItem.avx512_flexibleSpace, self.actionButton];
}

- (void)viewWillLayoutSubviews {
    CGSize constrainSize = CGSizeMake(self.scrollView.bounds.size.width, CGFLOAT_MAX);
    CGSize fieldEditorSize = [self.fieldEditorView sizeThatFits:constrainSize];
    self.fieldEditorView.frame = CGRectMake(0, 0, fieldEditorSize.width, fieldEditorSize.height);
    self.scrollView.contentSize = fieldEditorSize;
}

#pragma mark - Public methods of public-public method

- (AVX512ArgumentInputView *)firstInputView {
    return [self.fieldEditorView argumentInputViews].firstObject;
}

- (void)actionButtonPressed:(id)sender {
    // Sub-class classes can rewrite the sub class
    [self.fieldEditorView endEditing:YES];
    if (_commitHandler) {
        _commitHandler();
    }
}

- (void)exploreObjectOrPopViewController:(id)objectOrNil {
    if (objectOrNil) {
        // (or is not for non-empty /void) Returns the type of (return types to return a Type by pushing and sending one browser view views Viewer controller control
        AVX512ObjectExplorerViewController *explorerViewController = [AVX512ObjectExplorerFactory explorerViewControllerForObject:objectOrNil];
        [self.navigationController pushViewController:explorerViewController animated:YES];
    } else {
        // If we don't get a returned object but the method is successful, if you
        // Pop-out this view controller to indicate that the call has already been called and requested. This View control
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
