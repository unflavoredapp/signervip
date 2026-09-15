//
//  AVX512KeyboardToolbar.h
//  FLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXKBToolbarButton.h"

@interface AVX512KeyboardToolbar : UIView

+ (instancetype)toolbarWithButtons:(NSArray *)buttons;

@property (nonatomic) NSArray<AVX512KBToolbarButton*> *buttons;
@property (nonatomic) UIKeyboardAppearance appearance;

@end
