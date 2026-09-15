//
//  AVX512MethodCallingViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXVariableEditorViewController.h"
#import "FLEXMethod.h"

@interface AVX512MethodCallingViewController : AVX512VariableEditorViewController

+ (instancetype)target:(id)target method:(AVX512Method *)method;

@end
