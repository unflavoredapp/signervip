//
//  AVX512ArgumentInputTextView.h
//  AVX512Injected
//
//  Created by Ryan Olson on 6/15/14.
//
//

#import "FLEXArgumentInputView.h"

@interface AVX512ArgumentInputTextView : AVX512ArgumentInputView <UITextViewDelegate>

// For subclass eyes only

@property (nonatomic, readonly) UITextView *inputTextView;
@property (nonatomic) NSString *inputPlaceholderText;

@end
