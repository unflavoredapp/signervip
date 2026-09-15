//
//  AVX512ArgumentInputColorView.m
//  Flipboard
//
//  Created by Ryan Olson on 6/30/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXArgumentInputColorView.h"
#import "FLEXUtility.h"
#import "FLEXRuntimeUtility.h"

@protocol AVX512ColorComponentInputViewDelegate;

@interface AVX512ColorComponentInputView : UIView

@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *valueLabel;

@property (nonatomic, weak) id <AVX512ColorComponentInputViewDelegate> delegate;

@end

@protocol AVX512ColorComponentInputViewDelegate <NSObject>

- (void)colorComponentInputViewValueDidChange:(AVX512ColorComponentInputView *)colorComponentInputView;

@end


@implementation AVX512ColorComponentInputView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.slider = [UISlider new];
        [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        self.valueLabel = [UILabel new];
        self.valueLabel.backgroundColor = self.backgroundColor;
        self.valueLabel.font = [UIFont systemFontOfSize:14.0];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.valueLabel];
        
        [self updateValueLabel];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.slider.backgroundColor = backgroundColor;
    self.valueLabel.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat kValueLabelWidth = 50.0;
    
    [self.slider sizeToFit];
    CGFloat sliderWidth = self.bounds.size.width - kValueLabelWidth;
    self.slider.frame = CGRectMake(0, 0, sliderWidth, self.slider.frame.size.height);
    
    [self.valueLabel sizeToFit];
    CGFloat valueLabelOriginX = CGRectGetMaxX(self.slider.frame);
    CGFloat valueLabelOriginY = AVX512Floor((self.slider.frame.size.height - self.valueLabel.frame.size.height) / 2.0);
    self.valueLabel.frame = CGRectMake(valueLabelOriginX, valueLabelOriginY, kValueLabelWidth, self.valueLabel.frame.size.height);
}

- (void)sliderChanged:(id)sender {
    [self.delegate colorComponentInputViewValueDidChange:self];
    [self updateValueLabel];
}

- (void)updateValueLabel {
    self.valueLabel.text = [NSString stringWithFormat:@"%.3f", self.slider.value];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self.slider sizeThatFits:size].height;
    return CGSizeMake(size.width, height);
}

@end

@interface AVX512ColorPreviewBox : UIView

@property (nonatomic) UIColor *color;

@property (nonatomic) UIView *colorOverlayView;

@end

@implementation AVX512ColorPreviewBox

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.backgroundColor = [UIColor colorWithPatternImage:[[self class] backgroundPatternImage]];
        
        self.colorOverlayView = [[UIView alloc] initWithFrame:self.bounds];
        self.colorOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.colorOverlayView.backgroundColor = UIColor.clearColor;
        [self addSubview:self.colorOverlayView];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    self.colorOverlayView.backgroundColor = color;
}

- (UIColor *)color {
    return self.colorOverlayView.backgroundColor;
}

+ (UIImage *)backgroundPatternImage {
    const CGFloat kSquareDimension = 5.0;
    CGSize squareSize = CGSizeMake(kSquareDimension, kSquareDimension);
    CGSize imageSize = CGSizeMake(2.0 * kSquareDimension, 2.0 * kSquareDimension);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, UIScreen.mainScreen.scale);
    
    [UIColor.whiteColor setFill];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    [UIColor.grayColor setFill];
    UIRectFill(CGRectMake(squareSize.width, 0, squareSize.width, squareSize.height));
    UIRectFill(CGRectMake(0, squareSize.height, squareSize.width, squareSize.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@interface AVX512ArgumentInputColorView () <AVX512ColorComponentInputViewDelegate>

@property (nonatomic) AVX512ColorPreviewBox *colorPreviewBox;
@property (nonatomic) UILabel *hexLabel;
@property (nonatomic) AVX512ColorComponentInputView *alphaInput;
@property (nonatomic) AVX512ColorComponentInputView *redInput;
@property (nonatomic) AVX512ColorComponentInputView *greenInput;
@property (nonatomic) AVX512ColorComponentInputView *blueInput;

@end

@implementation AVX512ArgumentInputColorView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithArgumentTypeEncoding:typeEncoding];
    if (self) {
        self.colorPreviewBox = [AVX512ColorPreviewBox new];
        [self addSubview:self.colorPreviewBox];
        
        self.hexLabel = [UILabel new];
        self.hexLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        self.hexLabel.textAlignment = NSTextAlignmentCenter;
        self.hexLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.hexLabel];
        
        self.alphaInput = [AVX512ColorComponentInputView new];
        self.alphaInput.slider.minimumTrackTintColor = UIColor.blackColor;
        self.alphaInput.delegate = self;
        [self addSubview:self.alphaInput];
        
        self.redInput = [AVX512ColorComponentInputView new];
        self.redInput.slider.minimumTrackTintColor = UIColor.redColor;
        self.redInput.delegate = self;
        [self addSubview:self.redInput];
        
        self.greenInput = [AVX512ColorComponentInputView new];
        self.greenInput.slider.minimumTrackTintColor = UIColor.greenColor;
        self.greenInput.delegate = self;
        [self addSubview:self.greenInput];
        
        self.blueInput = [AVX512ColorComponentInputView new];
        self.blueInput.slider.minimumTrackTintColor = UIColor.blueColor;
        self.blueInput.delegate = self;
        [self addSubview:self.blueInput];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.alphaInput.backgroundColor = backgroundColor;
    self.redInput.backgroundColor = backgroundColor;
    self.greenInput.backgroundColor = backgroundColor;
    self.blueInput.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat runningOriginY = 0;
    CGSize constrainSize = CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
    
    self.colorPreviewBox.frame = CGRectMake(0, runningOriginY, self.bounds.size.width, [[self class] colorPreviewBoxHeight]);
    runningOriginY = CGRectGetMaxY(self.colorPreviewBox.frame) + [[self class] inputViewVerticalPadding];
    
    [self.hexLabel sizeToFit];
    const CGFloat kLabelVerticalOutsetAmount = 0.0;
    const CGFloat kLabelHorizontalOutsetAmount = 2.0;
    UIEdgeInsets labelOutset = UIEdgeInsetsMake(-kLabelVerticalOutsetAmount, -kLabelHorizontalOutsetAmount, -kLabelVerticalOutsetAmount, -kLabelHorizontalOutsetAmount);
    self.hexLabel.frame = UIEdgeInsetsInsetRect(self.hexLabel.frame, labelOutset);
    CGFloat hexLabelOriginX = self.colorPreviewBox.layer.borderWidth;
    CGFloat hexLabelOriginY = CGRectGetMaxY(self.colorPreviewBox.frame) - self.colorPreviewBox.layer.borderWidth - self.hexLabel.frame.size.height;
    self.hexLabel.frame = CGRectMake(hexLabelOriginX, hexLabelOriginY, self.hexLabel.frame.size.width, self.hexLabel.frame.size.height);
    
    NSArray<AVX512ColorComponentInputView *> *colorComponentInputViews = @[self.alphaInput, self.redInput, self.greenInput, self.blueInput];
    for (AVX512ColorComponentInputView *inputView in colorComponentInputViews) {
        CGSize fitSize = [inputView sizeThatFits:constrainSize];
        inputView.frame = CGRectMake(0, runningOriginY, fitSize.width, fitSize.height);
        runningOriginY = CGRectGetMaxY(inputView.frame) + [[self class] inputViewVerticalPadding];
    }
}

- (void)setInputValue:(id)inputValue {
    if ([inputValue isKindOfClass:[UIColor class]]) {
        [self updateWithColor:inputValue];
    } else if ([inputValue isKindOfClass:[NSValue class]]) {
        const char *type = [inputValue objCType];
        if (strcmp(type, @encode(CGColorRef)) == 0) {
            CGColorRef colorRef;
            [inputValue getValue:&colorRef];
            UIColor *color = [[UIColor alloc] initWithCGColor:colorRef];
            [self updateWithColor:color];
        }
    } else {
        [self updateWithColor:UIColor.clearColor];
    }
}

- (id)inputValue {
    return [UIColor colorWithRed:self.redInput.slider.value green:self.greenInput.slider.value blue:self.blueInput.slider.value alpha:self.alphaInput.slider.value];
}

- (void)colorComponentInputViewValueDidChange:(AVX512ColorComponentInputView *)colorComponentInputView {
    [self updateColorPreview];
}

- (void)updateWithColor:(UIColor *)color {
    CGFloat red, green, blue, white, alpha;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        self.alphaInput.slider.value = alpha;
        [self.alphaInput updateValueLabel];
        self.redInput.slider.value = red;
        [self.redInput updateValueLabel];
        self.greenInput.slider.value = green;
        [self.greenInput updateValueLabel];
        self.blueInput.slider.value = blue;
        [self.blueInput updateValueLabel];
    } else if ([color getWhite:&white alpha:&alpha]) {
        self.alphaInput.slider.value = alpha;
        [self.alphaInput updateValueLabel];
        self.redInput.slider.value = white;
        [self.redInput updateValueLabel];
        self.greenInput.slider.value = white;
        [self.greenInput updateValueLabel];
        self.blueInput.slider.value = white;
        [self.blueInput updateValueLabel];
    }
    [self updateColorPreview];
}

- (void)updateColorPreview {
    self.colorPreviewBox.color = self.inputValue;
    unsigned char redByte = self.redInput.slider.value * 255;
    unsigned char greenByte = self.greenInput.slider.value * 255;
    unsigned char blueByte = self.blueInput.slider.value * 255;
    self.hexLabel.text = [NSString stringWithFormat:@"#%02X%02X%02X", redByte, greenByte, blueByte];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += [[self class] colorPreviewBoxHeight];
    height += [[self class] inputViewVerticalPadding];
    height += [self.alphaInput sizeThatFits:size].height;
    height += [[self class] inputViewVerticalPadding];
    height += [self.redInput sizeThatFits:size].height;
    height += [[self class] inputViewVerticalPadding];
    height += [self.greenInput sizeThatFits:size].height;
    height += [[self class] inputViewVerticalPadding];
    height += [self.blueInput sizeThatFits:size].height;
    return CGSizeMake(size.width, height);
}

+ (CGFloat)inputViewVerticalPadding {
    return 10.0;
}

+ (CGFloat)colorPreviewBoxHeight {
    return 40.0;
}

+ (BOOL)supportsObjCType:(const char *)type withCurrentValue:(id)value {
    NSParameterAssert(type);

    // We don't care if currentValue is a color or not; we will default to +clearColor
    return (strcmp(type, @encode(CGColorRef)) == 0) || (strcmp(type, AVX512EncodeClass(UIColor)) == 0);
}

@end
