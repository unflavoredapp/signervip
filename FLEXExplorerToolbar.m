//
//  AVX512ExplorerToolbar.m
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXColor.h"
#import "FLEXExplorerToolbar.h"
#import "FLEXExplorerToolbarItem.h"
#import "FLEXResources.h"
#import "FLEXUtility.h"

// xFunctional modules of the functional-mod
#import "x/ClassDump/UCClassDumpTool.h"
#import "x/filza/UCFilzaTool.h"
#import "x/Decrypt/UCDecryptTool.h"
#import "x/AppProtection/UCAppProtectionTool.h"

@interface AVX512ExplorerToolbar ()

@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *globalsItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *hierarchyItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *selectItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *recentItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *moveItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *closeItem;
@property (nonatomic, readwrite) UIView *dragHandle;

@property (nonatomic) UIImageView *dragHandleImageView;

@property (nonatomic) UIView *selectedViewDescriptionContainer;
@property (nonatomic) UIView *selectedViewDescriptionSafeAreaContainer;
@property (nonatomic) UIView *selectedViewColorIndicator;
@property (nonatomic) UILabel *selectedViewDescriptionLabel;

@property (nonatomic,readwrite) UIView *backgroundView;

// Second second line, 2
@property (nonatomic, readwrite) UIView *secondRowDragHandle;
@property (nonatomic) UIImageView *secondRowDragHandleImageView;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *classdumpItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *disassemblerItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *hookGenItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *decryptItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *filzaItem;
@property (nonatomic, readwrite) AVX512ExplorerToolbarItem *protectionItem;
@property (nonatomic) UIView *secondRowBackground;

@end

@implementation AVX512ExplorerToolbar

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Background - And with and from the original,AVX512Un un United, unanimous
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [AVX512Color secondaryBackgroundColorWithAlpha:0.95];
        [self addSubview:self.backgroundView];

        // Drag handle - First line, first lines
        self.dragHandle = [UIView new];
        self.dragHandle.backgroundColor = UIColor.clearColor;
        self.dragHandleImageView = [[UIImageView alloc] initWithImage:AVX512Resources.dragHandle];
        self.dragHandleImageView.tintColor = [AVX512Color.iconColor colorWithAlphaComponent:0.666];
        [self.dragHandle addSubview:self.dragHandleImageView];
        [self addSubview:self.dragHandle];
        
        // Buttons - First line of the first row (two separate buttons that have recently moved and move are
        self.globalsItem   = [AVX512ExplorerToolbarItem itemWithTitle:@"Menu" image:AVX512Resources.globalsIcon];
        self.hierarchyItem = [AVX512ExplorerToolbarItem itemWithTitle:@"View" image:AVX512Resources.hierarchyIcon];
        self.selectItem    = [AVX512ExplorerToolbarItem itemWithTitle:@"Select" image:AVX512Resources.selectIcon];
        self.recentItem    = [AVX512ExplorerToolbarItem itemWithTitle:@"Recent" image:AVX512Resources.recentIcon];
        self.moveItem      = [AVX512ExplorerToolbarItem itemWithTitle:@"Move" image:AVX512Resources.moveIcon];
        self.closeItem     = [AVX512ExplorerToolbarItem itemWithTitle:@"Close" image:AVX512Resources.closeIcon];
        
        // Second second line, 2 Drag handle - Add first to the bottom base, add
        self.secondRowDragHandle = [UIView new];
        self.secondRowDragHandle.backgroundColor = UIColor.clearColor;
        self.secondRowDragHandleImageView = [[UIImageView alloc] initWithImage:AVX512Resources.dragHandle];
        self.secondRowDragHandleImageView.tintColor = [AVX512Color.iconColor colorWithAlphaComponent:0.666];
        [self.secondRowDragHandle addSubview:self.secondRowDragHandleImageView];
        
        // Second line, second lines of background - Include and include, including dragHandle And and But buttons &
        self.secondRowBackground = [[UIView alloc] init];
        self.secondRowBackground.backgroundColor = [AVX512Color secondaryBackgroundColorWithAlpha:0.95];
        [self.secondRowBackground addSubview:self.secondRowDragHandle];
        [self addSubview:self.secondRowBackground];
        
        // Buttons - Second second line, 2
        self.classdumpItem  = [AVX512ExplorerToolbarItem itemWithTitle:@"xx.h" image:[UIImage systemImageNamed:@"doc.text.fill"]];
        self.disassemblerItem = [AVX512ExplorerToolbarItem itemWithTitle:@"Disasm" image:[UIImage systemImageNamed:@"cpu.fill"]];
        self.decryptItem    = [AVX512ExplorerToolbarItem itemWithTitle:@"Capture" image:[UIImage systemImageNamed:@"lock.open.fill"]];
        self.filzaItem      = [AVX512ExplorerToolbarItem itemWithTitle:@"Filza" image:[UIImage systemImageNamed:@"folder.fill"]];
        self.protectionItem = [AVX512ExplorerToolbarItem itemWithTitle:@"Protect" image:[UIImage systemImageNamed:@"shield.fill"]];
        self.hookGenItem    = [AVX512ExplorerToolbarItem itemWithTitle:@"Hook" image:[UIImage systemImageNamed:@"link.badge.plus"]];
        // The last position at the end of line 2, second row, is empty in an blank space with

        // Selected view box //
        
        self.selectedViewDescriptionContainer = [UIView new];
        self.selectedViewDescriptionContainer.backgroundColor = [AVX512Color tertiaryBackgroundColorWithAlpha:0.95];
        self.selectedViewDescriptionContainer.hidden = YES;
        [self addSubview:self.selectedViewDescriptionContainer];

        self.selectedViewDescriptionSafeAreaContainer = [UIView new];
        self.selectedViewDescriptionSafeAreaContainer.backgroundColor = UIColor.clearColor;
        [self.selectedViewDescriptionContainer addSubview:self.selectedViewDescriptionSafeAreaContainer];
        
        self.selectedViewColorIndicator = [UIView new];
        self.selectedViewColorIndicator.backgroundColor = UIColor.redColor;
        [self.selectedViewDescriptionSafeAreaContainer addSubview:self.selectedViewColorIndicator];
        
        self.selectedViewDescriptionLabel = [UILabel new];
        self.selectedViewDescriptionLabel.backgroundColor = UIColor.clearColor;
        self.selectedViewDescriptionLabel.font = [[self class] descriptionLabelFont];
        [self.selectedViewDescriptionSafeAreaContainer addSubview:self.selectedViewDescriptionLabel];
        
        // toolbarItems - First line (first row, first6buttons: menu, Menumen; Viewes and viewing. Select selection (Selection)
        self.toolbarItems = @[_globalsItem, _hierarchyItem, _selectItem, _recentItem, _moveItem, _closeItem];
        
        // secondRowItems - Line 2 (second line, second6button to a Butt-but+B-B white blank=7column) (Rals),
        self.secondRowItems = @[_classdumpItem, _disassemblerItem, _decryptItem, _filzaItem, _protectionItem, _hookGenItem];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];


    CGRect safeArea = [self safeArea];
    const CGFloat kToolbarItemHeight = [[self class] toolbarItemHeight];
    CGFloat totalWidth = CGRectGetWidth(safeArea);
    
    // 7Liebd layout: Libeble scale ofdragHandle | 6button to a Button (all columns have the same width of all rows with
    const NSInteger kTotalColumns = 7;
    CGFloat columnWidth = AVX512Floor(totalWidth / kTotalColumns);
    
    // First line, first lines Drag Handle
    self.dragHandle.frame = CGRectMake(0, 0, columnWidth, kToolbarItemHeight);
    CGRect dragHandleImageFrame = self.dragHandleImageView.frame;
    dragHandleImageFrame.origin.x = AVX512Floor((columnWidth - dragHandleImageFrame.size.width) / 2.0);
    dragHandleImageFrame.origin.y = AVX512Floor((kToolbarItemHeight - dragHandleImageFrame.size.height) / 2.0);
    self.dragHandleImageView.frame = dragHandleImageFrame;
    
    // First line first row, lines 1
    CGFloat originX = columnWidth;
    CGFloat originY = 0;
    CGFloat height = kToolbarItemHeight;
    
    for (NSInteger i = 0; i < self.toolbarItems.count; i++) {
        AVX512ExplorerToolbarItem *toolbarItem = self.toolbarItems[i];
        toolbarItem.currentItem.frame = CGRectMake(originX, originY, columnWidth, height);
        originX += columnWidth;
    }
    
    self.backgroundView.frame = CGRectMake(0, 0, totalWidth, kToolbarItemHeight);
    
    // Second line, second lines of background
    CGFloat secondRowY = kToolbarItemHeight;
    self.secondRowBackground.frame = CGRectMake(0, secondRowY, totalWidth, kToolbarItemHeight);
    
    // Second second line, 2 Drag Handle (In being in thesecondRowBackgroundCoordinates in the system of coordinates within)
    self.secondRowDragHandle.frame = CGRectMake(0, 0, columnWidth, kToolbarItemHeight);
    CGRect secondRowDragHandleImageFrame = self.secondRowDragHandleImageView.frame;
    secondRowDragHandleImageFrame.origin.x = AVX512Floor((columnWidth - secondRowDragHandleImageFrame.size.width) / 2.0);
    secondRowDragHandleImageFrame.origin.y = AVX512Floor((kToolbarItemHeight - secondRowDragHandleImageFrame.size.height) / 2.0);
    self.secondRowDragHandleImageView.frame = secondRowDragHandleImageFrame;
    
    // But button (in the second line, 2ndsecondRowBackgroundCoordinate system, central coordinates of the coordinate systems indragHandle(after and after)))(
    // Note: CNote note that the button is alreadysetSecondRowItemsAdds to add added into the secondRowBackground, only updates are updated here to update theframe
    originX = columnWidth;
    for (NSInteger i = 0; i < self.secondRowItems.count; i++) {
        AVX512ExplorerToolbarItem *toolbarItem = self.secondRowItems[i];
        toolbarItem.currentItem.frame = CGRectMake(originX, 0, columnWidth, height);
        originX += columnWidth;
    }
    
    const CGFloat kSelectedViewColorDiameter = [[self class] selectedViewColorIndicatorDiameter];
    const CGFloat kDescriptionLabelHeight = [[self class] descriptionLabelHeight];
    const CGFloat kHorizontalPadding = [[self class] horizontalPadding];
    const CGFloat kDescriptionVerticalPadding = [[self class] descriptionVerticalPadding];
    const CGFloat kDescriptionContainerHeight = [[self class] descriptionContainerHeight];
    
    CGFloat bottomY = kToolbarItemHeight * 2;
    
    CGRect descriptionContainerFrame = CGRectZero;
    descriptionContainerFrame.size.width = CGRectGetWidth(self.bounds);
    descriptionContainerFrame.size.height = kDescriptionContainerHeight;
    descriptionContainerFrame.origin.x = CGRectGetMinX(self.bounds);
    descriptionContainerFrame.origin.y = kToolbarItemHeight * 2;
    self.selectedViewDescriptionContainer.frame = descriptionContainerFrame;

    CGRect descriptionSafeAreaContainerFrame = CGRectZero;
    descriptionSafeAreaContainerFrame.size.width = CGRectGetWidth(safeArea);
    descriptionSafeAreaContainerFrame.size.height = kDescriptionContainerHeight;
    descriptionSafeAreaContainerFrame.origin.x = CGRectGetMinX(safeArea) - CGRectGetMinX(self.bounds);
    descriptionSafeAreaContainerFrame.origin.y = 0;
    self.selectedViewDescriptionSafeAreaContainer.frame = descriptionSafeAreaContainerFrame;

    // Selected View Color
    CGRect selectedViewColorFrame = CGRectZero;
    selectedViewColorFrame.size.width = kSelectedViewColorDiameter;
    selectedViewColorFrame.size.height = kSelectedViewColorDiameter;
    selectedViewColorFrame.origin.x = kHorizontalPadding;
    selectedViewColorFrame.origin.y = AVX512Floor((kDescriptionContainerHeight - kSelectedViewColorDiameter) / 2.0);
    self.selectedViewColorIndicator.frame = selectedViewColorFrame;
    self.selectedViewColorIndicator.layer.cornerRadius = ceil(selectedViewColorFrame.size.height / 2.0);
    
    // Selected View Description
    CGRect descriptionLabelFrame = CGRectZero;
    CGFloat descriptionOriginX = CGRectGetMaxX(selectedViewColorFrame) + kHorizontalPadding;
    descriptionLabelFrame.size.height = kDescriptionLabelHeight;
    descriptionLabelFrame.origin.x = descriptionOriginX;
    descriptionLabelFrame.origin.y = kDescriptionVerticalPadding;
    descriptionLabelFrame.size.width = CGRectGetMaxX(self.selectedViewDescriptionContainer.bounds) - kHorizontalPadding - descriptionOriginX;
    self.selectedViewDescriptionLabel.frame = descriptionLabelFrame;
}


#pragma mark - Setter Overrides

- (void)setToolbarItems:(NSArray<AVX512ExplorerToolbarItem *> *)toolbarItems {
    if (_toolbarItems == toolbarItems) {
        return;
    }
    
    for (AVX512ExplorerToolbarItem *item in _toolbarItems) {
        [item.currentItem removeFromSuperview];
    }
    
    // In the first line, there is6But buttons: menu, viewing and selection of the Menu; & simen. View/view
    if (toolbarItems.count > 6) {
        toolbarItems = [toolbarItems subarrayWithRange:NSMakeRange(0, 6)];
    }

    for (AVX512ExplorerToolbarItem *item in toolbarItems) {
        [self addSubview:item.currentItem];
    }

    _toolbarItems = toolbarItems.copy;

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSecondRowItems:(NSArray<AVX512ExplorerToolbarItem *> *)secondRowItems {
    if (_secondRowItems == secondRowItems) {
        return;
    }
    
    for (AVX512ExplorerToolbarItem *item in _secondRowItems) {
        [item.currentItem removeFromSuperview];
    }
    
    if (secondRowItems.count > 6) {
        secondRowItems = [secondRowItems subarrayWithRange:NSMakeRange(0, 6)];
    }
    
    for (AVX512ExplorerToolbarItem *item in secondRowItems) {
        [self.secondRowBackground addSubview:item.currentItem];
    }
    
    _secondRowItems = secondRowItems.copy;
    [self setNeedsLayout];
}

- (void)setSelectedViewOverlayColor:(UIColor *)selectedViewOverlayColor {
    if (![_selectedViewOverlayColor isEqual:selectedViewOverlayColor]) {
        _selectedViewOverlayColor = selectedViewOverlayColor;
        self.selectedViewColorIndicator.backgroundColor = selectedViewOverlayColor;
    }
}

- (void)setSelectedViewDescription:(NSString *)selectedViewDescription {
    if (![_selectedViewDescription isEqualToString:selectedViewDescription]) {
        _selectedViewDescription = selectedViewDescription;
        self.selectedViewDescriptionLabel.text = selectedViewDescription;
        BOOL showDescription = selectedViewDescription.length > 0;
        self.selectedViewDescriptionContainer.hidden = !showDescription;
    }
}


#pragma mark - Sizing Convenience Methods

+ (UIFont *)descriptionLabelFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (CGFloat)toolbarItemHeight {
    return 44.0;
}

+ (CGFloat)dragHandleWidth {
    return AVX512Resources.dragHandle.size.width;
}

+ (CGFloat)descriptionLabelHeight {
    return ceil([[self descriptionLabelFont] lineHeight]);
}

+ (CGFloat)descriptionVerticalPadding {
    return 2.0;
}

+ (CGFloat)descriptionContainerHeight {
    return [self descriptionVerticalPadding] * 2.0 + [self descriptionLabelHeight];
}

+ (CGFloat)selectedViewColorIndicatorDiameter {
    return ceil([self descriptionLabelHeight] / 2.0);
}

+ (CGFloat)horizontalPadding {
    return 11.0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0.0;
    height += [[self class] toolbarItemHeight];
    height += [[self class] toolbarItemHeight];
    height += [[self class] descriptionContainerHeight];
    return CGSizeMake(size.width, height);
}

- (CGRect)safeArea {
    CGRect safeArea = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeArea = UIEdgeInsetsInsetRect(self.bounds, self.safeAreaInsets);
    }

    return safeArea;
}

@end
