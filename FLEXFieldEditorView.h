//
//  AVX512FieldEditorView.h
//  Flipboard
//
//  Created by Ryan Olson on 5/16/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVX512ArgumentInputView;

@interface AVX512FieldEditorView : UIView

@property (nonatomic, copy) NSString *targetDescription;
@property (nonatomic, copy) NSString *fieldDescription;

@property (nonatomic, copy) NSArray<AVX512ArgumentInputView *> *argumentInputViews;

@end
