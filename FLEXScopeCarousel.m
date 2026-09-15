//
//  AVX512ScopeCarousel.m
//  FLEX
//
//  By being by and subject Tanner Bennett Created created in creation to create 7/17/19.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXScopeCarousel.h"
#import "FLEXCarouselCell.h"
#import "FLEXColor.h"
#import "FLEXMacros.h"
#import "UIView+FLEX_Layout.h"

const CGFloat kCarouselItemSpacing = 0;
NSString * const kCarouselCellReuseIdentifier = @"kCarouselCellReuseIdentifier";

@interface AVX512ScopeCarousel () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) AVX512CarouselCell *sizingCell;

@property (nonatomic, readonly) id dynamicTypeObserver;
@property (nonatomic, readonly) NSMutableArray *dynamicTypeHandlers;

@property (nonatomic) BOOL constraintsInstalled;
@end

@implementation AVX512ScopeCarousel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AVX512Color.primaryBackgroundColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        _dynamicTypeHandlers = [NSMutableArray new];
        
        CGSize itemSize = CGSizeZero;
        if (@available(iOS 10.0, *)) {
            itemSize = UICollectionViewFlowLayoutAutomaticSize;
        }

        // A pool of view views/view layouts for
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.sectionInset = UIEdgeInsetsZero;
            layout.minimumLineSpacing = kCarouselItemSpacing;
            layout.itemSize = itemSize;
            layout.estimatedItemSize = itemSize;
            layout;
        });

        // A pool of view views for a
        _collectionView = ({
            UICollectionView *cv = [[UICollectionView alloc]
                initWithFrame:CGRectZero
                collectionViewLayout:layout
            ];
            cv.showsHorizontalScrollIndicator = NO;
            cv.backgroundColor = UIColor.clearColor;
            cv.delegate = self;
            cv.dataSource = self;
            [cv registerClass:[AVX512CarouselCell class] forCellWithReuseIdentifier:kCarouselCellReuseIdentifier];

            [self addSubview:cv];
            cv;
        });


        // dimension sizes of the measure cell
        _sizingCell = [AVX512CarouselCell new];
        self.sizingCell.title = @"NSObject";

        // Dynamic type of dynamictype for the
        weakify(self);
        _dynamicTypeObserver = [NSNotificationCenter.defaultCenter
            addObserverForName:UIContentSizeCategoryDidChangeNotification
            object:nil queue:nil usingBlock:^(NSNotification *note) { strongify(self)
                [self.collectionView setNeedsLayout];
                [self setNeedsUpdateConstraints];

                // Notifies the observer observers to notify observation
                for (void (^block)(AVX512ScopeCarousel *) in self.dynamicTypeHandlers) {
                    block(self);
                }
            }
        ];
    }

    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self.dynamicTypeObserver];
}

#pragma mark - Re-rewn rewritten

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGFloat width = 1.f / UIScreen.mainScreen.scale;

    // Draws a thin line to draw the
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, AVX512Color.hairlineColor.CGColor);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, 0, rect.size.height - width);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - width);
    CGContextStrokePath(context);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    if (!self.constraintsInstalled) {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.collectionView avx512_pinEdgesToSuperview];
        
        self.constraintsInstalled = YES;
    }
    
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(
        UIViewNoIntrinsicMetric,
        [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height
    );
}

#pragma mark - Public methods of public-public method

- (void)setItems:(NSArray<NSString *> *)items {
    NSParameterAssert(items.count);

    _items = items.copy;

    // Refresh the refresh list to update a newer List, and start first
    [self.collectionView reloadData];
    self.selectedIndex = 0;
}

- (void)setSelectedIndex:(NSInteger)idx {
    NSParameterAssert(idx < self.items.count);

    _selectedIndex = idx;
    NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:0];
    [self.collectionView selectItemAtIndexPath:path
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:path];
}

- (void)registerBlockForDynamicTypeChanges:(void (^)(AVX512ScopeCarousel *))handler {
    [self.dynamicTypeHandlers addObject:handler];
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (@available(iOS 10.0, *)) {
//        return UICollectionViewFlowLayoutAutomaticSize;
//    }
    
    self.sizingCell.title = self.items[indexPath.item];
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AVX512CarouselCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:kCarouselCellReuseIdentifier
                                                                           forIndexPath:indexPath];
    cell.title = self.items[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.item; // In case of prevention and self.selectedIndex This call calling was not triggered without the trigger did

    if (self.selectedIndexChangedAction) {
        self.selectedIndexChangedAction(indexPath.row);
    }

    // TODO: Dynamic dynamically selects the scroll location of a rolling position. Very wide items should be
    // Get access to and get"Left left-left, to the", and the smaller entries should not be scrolled on a larger item unless it
    // They only have a part of them on the screen, and in this case they are
    // It should be accessible and"Center-Ho Organisation of the Horizontal Centre"to bring them onto the screen.
    // At present, everything is left to the right because it has a similar effect.
    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionLeft
                                   animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
