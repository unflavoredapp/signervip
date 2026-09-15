//
//  AVX512FieldEditorViewController.m
//  FLEX
//
//  Created by Tanner on 11/22/18.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXFieldEditorViewController.h"
#import "FLEXFieldEditorView.h"
#import "FLEXArgumentInputViewFactory.h"
#import "FLEXPropertyAttributes.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXMetadataExtras.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "UIBarButtonItem+FLEX.h"

@interface AVX512FieldEditorViewController () <AVX512ArgumentInputViewDelegate>

@property (nonatomic, readonly) id<AVX512MetadataAuxiliaryInfo> auxiliaryInfoProvider;
@property (nonatomic) AVX512Property *property;
@property (nonatomic) AVX512Ivar *ivar;

@property (nonatomic, readonly) id currentValue;
@property (nonatomic, readonly) const AVX512TypeEncoding *typeEncoding;
@property (nonatomic, readonly) NSString *fieldDescription;

@end

@implementation AVX512FieldEditorViewController

#pragma mark - Initial initialisation to start-in

+ (instancetype)target:(id)target property:(nonnull AVX512Property *)property commitHandler:(void(^)(void))onCommit {
    AVX512FieldEditorViewController *editor = [self target:target data:property commitHandler:onCommit];
    editor.title = [@"The property of the attribute: " stringByAppendingString:property.name];
    editor.property = property;
    return editor;
}

+ (instancetype)target:(id)target ivar:(nonnull AVX512Ivar *)ivar commitHandler:(void(^)(void))onCommit {
    AVX512FieldEditorViewController *editor = [self target:target data:ivar commitHandler:onCommit];
    editor.title = [@"The example instance case for the examples: " stringByAppendingString:ivar.name];
    editor.ivar = ivar;
    return editor;
}

#pragma mark - Re-rewn rewritten

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = AVX512Color.groupedBackgroundColor;

    // Creates a button to create the get-to
    _getterButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Enter entered entry into entering"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(getterButtonPressed:)
    ];
    self.toolbarItems = @[
        UIBarButtonItem.avx512_flexibleSpace, self.getterButton, self.actionButton
    ];
    
    [self registerAuxiliaryInfo];

    // Configure the configuration of conf Configuration Input
    self.fieldEditorView.fieldDescription = self.fieldDescription;
    AVX512ArgumentInputView *inputView = [AVX512ArgumentInputViewFactory argumentInputViewForTypeEncoding:self.typeEncoding];
    inputView.inputValue = self.currentValue;
    inputView.delegate = self;
    self.fieldEditorView.argumentInputViews = @[inputView];

    // Not to show for the switch is not shown as"Set the setting of a"buttons; we change changes when the switch flip switches are turned to reverse. We make a
    if ([inputView isKindOfClass:[AVX512ArgumentInputSwitchView class]]) {
        self.actionButton.enabled = NO;
        self.actionButton.title = @"Flip flip the switch to overturn turn Turn Switch switches so that calling calls call for";
        // Positioning the access button to put a searcher key in front of putting before setting
        self.toolbarItems = @[
            UIBarButtonItem.avx512_flexibleSpace, self.actionButton, self.getterButton
        ];
    }
}

- (void)actionButtonPressed:(id)sender {
    if (self.property) {
        id userInputObject = self.firstInputView.inputValue;
        NSArray *arguments = userInputObject ? @[userInputObject] : nil;
        SEL setterSelector = self.property.likelySetter;
        NSError *error = nil;
        [AVX512RuntimeUtility performSelector:setterSelector onObject:self.target withArguments:arguments error:&error];
        if (error) {
            [AVX512Alert showAlert:@"Properties settings failed to function for the attribute" message:error.localizedDescription from:self];
            sender = nil; // Do not return to the previous page before
        }
    } else {
        // TODO: To check for the detection and, where necessary or usemutableCopy; and also, or
        // This may now, and this is likelyNSArrayAllocation of allocated allocation toNSMutableArray
        [self.ivar setValue:self.firstInputView.inputValue onObject:self.target];
    }
    
    // Turns the keyboard turn off keyboard and processes submitted changes that have been
    [super actionButtonPressed:sender];

    // returns back after settings have been set, but does not apply to the switch
    if (sender) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.firstInputView.inputValue = self.currentValue;
    }
}

- (void)getterButtonPressed:(id)sender {
    [self.fieldEditorView endEditing:YES];

    [self exploreObjectOrPopViewController:self.currentValue];
}

- (void)argumentInputViewValueDidChange:(AVX512ArgumentInputView *)argumentInputView {
    if ([argumentInputView isKindOfClass:[AVX512ArgumentInputSwitchView class]]) {
        [self actionButtonPressed:nil];
    }
}

#pragma mark - Private private methods and privately-private

- (void)registerAuxiliaryInfo {
    // IT ISIT isReflexWhen running in run-run, theSwiftStructures the structure of a structured architecture body field fields area name names to organize how
    NSDictionary<NSString *, NSArray *> *labels = [self.auxiliaryInfoProvider
        auxiliaryInfoForKey:AVX512AuxiliarynfoKeyFieldLabels
    ];
    
    for (NSString *type in labels) {
        [AVX512ArgumentInputViewFactory registerFieldNames:labels[type] forTypeEncoding:type];
    }
}

- (id)currentValue {
    if (self.property) {
        return [self.property getValue:self.target];
    } else {
        return [self.ivar getValue:self.target];
    }
}

- (id<AVX512MetadataAuxiliaryInfo>)auxiliaryInfoProvider {
    return self.ivar ?: self.property;
}

- (const AVX512TypeEncoding *)typeEncoding {
    if (self.property) {
        return self.property.attributes.typeEncoding.UTF8String;
    } else {
        return self.ivar.typeEncoding.UTF8String;
    }
}

- (NSString *)fieldDescription {
    if (self.property) {
        return self.property.fullDescription;
    } else {
        return self.ivar.description;
    }
}

@end
