//
//  AVX512HierarchyTableViewCell.m
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-02.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXHierarchyTableViewCell.h"
#import "FLEXUtility.h"
#import "FLEXResources.h"
#import "FLEXColor.h"

@interface AVX512HierarchyTableViewCell ()

/// Directs the depth of a deep-depth in hierarchy structure at level
@property (nonatomic) UIView *depthIndicatorView;
/// Holds colour colors of color that hold a visible and visually different view
@property (nonatomic) UIImageView *colorCircleImageView;
/// A view of a checkboard bar board pattern mode in the Board Committee-style format that is used to help show coloursPhotoshopTo draw the cloths and canvas
@property (nonatomic) UIView *backgroundColorCheckerPatternView;
/// A sub-view view of the check board committee pattern mode modes Views views a Sub View for Boardbas
@property (nonatomic) UIView *viewBackgroundColorView;

@end

@implementation AVX512HierarchyTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.depthIndicatorView = [UIView new];
        self.depthIndicatorView.backgroundColor = AVX512Utility.hierarchyIndentPatternColor;
        [self.contentView addSubview:self.depthIndicatorView];
        
        UIImage *defaultCircleImage = [AVX512Utility circularImageWithColor:UIColor.blackColor radius:5];
        self.colorCircleImageView = [[UIImageView alloc] initWithImage:defaultCircleImage];
        [self.contentView addSubview:self.colorCircleImageView];
        
        self.textLabel.font = UIFont.avx512_defaultTableCellFont;
        self.detailTextLabel.font = UIFont.avx512_defaultTableCellFont;
        self.accessoryType = UITableViewCellAccessoryDetailButton;
        
        // Use mode-based colours based on a pattern color to simplify the application of use applications that streamline board
        static UIColor *checkerPatternColor = nil;
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            checkerPatternColor = [UIColor colorWithPatternImage:AVX512Resources.checkerPattern];
        });
        
        self.backgroundColorCheckerPatternView = [UIView new];
        self.backgroundColorCheckerPatternView.clipsToBounds = YES;
        self.backgroundColorCheckerPatternView.layer.borderColor = AVX512Color.tertiaryBackgroundColor.CGColor;
        self.backgroundColorCheckerPatternView.layer.borderWidth = 2.f / UIScreen.mainScreen.scale;
        self.backgroundColorCheckerPatternView.backgroundColor = checkerPatternColor;
        [self.contentView addSubview:self.backgroundColorCheckerPatternView];
        self.viewBackgroundColorView = [UIView new];
        [self.backgroundColorCheckerPatternView addSubview:self.viewBackgroundColorView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *originalColour = self.viewBackgroundColorView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    // UITableViewCell It will be that the contentView The background color for all sub-view viewings in any of the clearColor... . ...-
    // We want to keep the background color of a hierarchical structure for hierarchy at high bright displays when
    self.depthIndicatorView.backgroundColor = AVX512Utility.hierarchyIndentPatternColor;
    
    self.viewBackgroundColorView.backgroundColor = originalColour;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *originalColour = self.viewBackgroundColorView.backgroundColor;
    [super setSelected:selected animated:animated];
    
    // See above, see supra refer to the setHighlighted... . ...-
    self.depthIndicatorView.backgroundColor = AVX512Utility.hierarchyIndentPatternColor;
    
    self.viewBackgroundColorView.backgroundColor = originalColour;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat kContentPadding = 6;
    const CGFloat kDepthIndicatorWidthMultiplier = 4;
    const CGFloat kViewColorIndicatorSize = 22;
    
    const CGRect bounds = self.contentView.bounds;
    const CGFloat centerY = CGRectGetMidY(bounds);
    const CGFloat textLabelCenterY = CGRectGetMidY(self.textLabel.frame);
    
    BOOL hideCheckerView = self.backgroundColorCheckerPatternView.hidden;
    CGFloat maxWidth = CGRectGetMaxX(bounds);
    maxWidth -= (hideCheckerView ? kContentPadding : (kViewColorIndicatorSize + kContentPadding * 2));
    
    CGRect depthIndicatorFrame = self.depthIndicatorView.frame = CGRectMake(
        kContentPadding, 0, self.viewDepth * kDepthIndicatorWidthMultiplier, CGRectGetHeight(bounds)
    );
    
    // The circle is rounded behind the deep depth indicator pointer, and its centre center centresY = textLabelCentral Center of the CentreY
    CGRect circleFrame = self.colorCircleImageView.frame;
    circleFrame.origin.x = CGRectGetMaxX(depthIndicatorFrame) + kContentPadding;
    circleFrame.origin.y = AVX512Floor(textLabelCenterY - CGRectGetHeight(circleFrame) / 2.f);
    self.colorCircleImageView.frame = circleFrame;
    
    // Text tabs are located after a random coloured circle of the text label that is placed behind any s
    // contentViewon the edges or margins of a border margin, outside within-inside space distance in front
    CGRect textLabelFrame = self.textLabel.frame;
    CGFloat textOriginX = CGRectGetMaxX(circleFrame) + kContentPadding;
    textLabelFrame.origin.x = textOriginX;
    textLabelFrame.size.width = maxWidth - textOriginX;
    self.textLabel.frame = textLabelFrame;
    
    // detailTextLabelThe prelines are aligned to the circle of a round circles, and
    // The width extends to and extends the breadth oftextLabelThe same maximum maxim the Same asX
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    CGFloat detailOriginX = circleFrame.origin.x;
    detailTextLabelFrame.origin.x = detailOriginX;
    detailTextLabelFrame.size.width = maxWidth - detailOriginX;
    self.detailTextLabel.frame = detailTextLabelFrame;
    
    // Board board of chessboard General Committee pattern mode format view fromtextLabelthe largest maximum of allXAnd then the inside and interior space after that starts to begin, at
    // and throughout the whole, all acrosscontentViewCenter Centre centre center of the inner-internal vertical
    self.backgroundColorCheckerPatternView.frame = CGRectMake(
        CGRectGetMaxX(self.textLabel.frame) + kContentPadding,
        centerY - kViewColorIndicatorSize / 2.f,
        kViewColorIndicatorSize,
        kViewColorIndicatorSize
    );
    
    // The BB Background background context color for the back-back border colour
    self.viewBackgroundColorView.frame = self.backgroundColorCheckerPatternView.bounds;
    self.backgroundColorCheckerPatternView.layer.cornerRadius = kViewColorIndicatorSize / 2.f;
}

- (void)setRandomColorTag:(UIColor *)randomColorTag {
    if (![_randomColorTag isEqual:randomColorTag]) {
        _randomColorTag = randomColorTag;
        self.colorCircleImageView.image = [AVX512Utility circularImageWithColor:randomColorTag radius:6];
    }
}

- (void)setViewDepth:(NSInteger)viewDepth {
    if (_viewDepth != viewDepth) {
        _viewDepth = viewDepth;
        [self setNeedsLayout];
    }
}

- (UIColor *)indicatedViewColor {
    return self.viewBackgroundColorView.backgroundColor;
}

- (void)setIndicatedViewColor:(UIColor *)color {
    self.viewBackgroundColorView.backgroundColor = color;
    
    // If there is no background colour without context color, hides the checkboard board pattern mode
    self.backgroundColorCheckerPatternView.hidden = color == nil;
    [self setNeedsLayout];
}

@end
