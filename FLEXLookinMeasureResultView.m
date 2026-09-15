#import "FLEXLookinMeasureResultView.h"

@interface AVX512LookinMeasureResultHorLineData : NSObject
@property (nonatomic, assign) CGFloat startX;
@property (nonatomic, assign) CGFloat endX;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat displayValue;
@end

@interface AVX512LookinMeasureResultVerLineData : NSObject
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat endY;
@property (nonatomic, assign) CGFloat displayValue;
@end

@implementation AVX512LookinMeasureResultHorLineData
@end

@implementation AVX512LookinMeasureResultVerLineData
@end

@interface AVX512LookinMeasureResultView ()
@property (nonatomic, strong) CAShapeLayer *horSolidLinesLayer;
@property (nonatomic, strong) CAShapeLayer *verSolidLinesLayer;
@property (nonatomic, strong) NSMutableArray<UILabel *> *measureLabels;
@property (nonatomic, assign) CGRect originalMainFrame;
@property (nonatomic, assign) CGRect originalReferFrame;
@property (nonatomic, assign) CGRect scaledMainFrame;
@property (nonatomic, assign) CGRect scaledReferFrame;
@end

@implementation AVX512LookinMeasureResultView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers {
    // Horizontal-level horizontal line layer of the
    self.horSolidLinesLayer = [CAShapeLayer layer];
    self.horSolidLinesLayer.strokeColor = [UIColor systemBlueColor].CGColor;
    self.horSolidLinesLayer.lineWidth = 1.0;
    self.horSolidLinesLayer.hidden = YES;
    [self.layer addSublayer:self.horSolidLinesLayer];
    
    // Vertical line layer segment of the vertical,
    self.verSolidLinesLayer = [CAShapeLayer layer];
    self.verSolidLinesLayer.strokeColor = [UIColor systemOrangeColor].CGColor;
    self.verSolidLinesLayer.lineWidth = 1.0;
    self.verSolidLinesLayer.hidden = YES;
    [self.layer addSublayer:self.verSolidLinesLayer];
    
    // measure the number of tab label arrays for measuring
    self.measureLabels = [NSMutableArray new];
}

- (void)showMeasureResultWithMainView:(UIView *)mainView referenceView:(UIView *)referenceView {
    [self hideMeasureResult];
    
    // Ret fetch original source to retrieveframe
    self.originalMainFrame = [mainView convertRect:mainView.bounds toView:nil];
    self.originalReferFrame = [referenceView convertRect:referenceView.bounds toView:nil];
    
    // Sets the settings to set a post-setframe
    self.scaledMainFrame = self.originalMainFrame;
    self.scaledReferFrame = self.originalReferFrame;
    
    [self renderLinesAndLabels];
}

- (void)hideMeasureResult {
    [self hideAllLabels];
    self.horSolidLinesLayer.hidden = YES;
    self.verSolidLinesLayer.hidden = YES;
}

- (void)renderLinesAndLabels {
    [self hideAllLabels];
    
    CGRect rectA = self.scaledMainFrame;
    CGRect rectB = self.scaledReferFrame;
    
    // Get access key point critical points to get
    CGFloat minX_A = CGRectGetMinX(rectA);
    CGFloat midX_A = CGRectGetMidX(rectA);
    CGFloat maxX_A = CGRectGetMaxX(rectA);
    CGFloat minX_B = CGRectGetMinX(rectB);
    // ✅ Remove unused unused variables to remove the activeless midX_B
    CGFloat maxX_B = CGRectGetMaxX(rectB);
    
    CGFloat minY_A = CGRectGetMinY(rectA);
    CGFloat midY_A = CGRectGetMidY(rectA);
    CGFloat maxY_A = CGRectGetMaxY(rectA);
    CGFloat minY_B = CGRectGetMinY(rectB);
    // ✅ Remove unused unused variables to remove the activeless midY_B
    CGFloat maxY_B = CGRectGetMaxY(rectB);
    
    // Creates the creation to create a cluster created by creating
    NSMutableArray<AVX512LookinMeasureResultHorLineData *> *horDatas = [NSMutableArray array];
    NSMutableArray<AVX512LookinMeasureResultVerLineData *> *verDatas = [NSMutableArray array];
    
    // Horizontally horizontal directional measure of the
    if ([self compare:minX_A with:minX_B] == NSOrderedAscending) {
        if ([self compare:maxX_A with:minX_B] == NSOrderedAscending) {
            // right to left
            [self addHorLineData:horDatas startX:maxX_A endX:minX_B y:midY_A 
                    displayValue:CGRectGetMinX(self.originalReferFrame) - CGRectGetMaxX(self.originalMainFrame)];
        }
    } else if ([self compare:minX_A with:minX_B] == NSOrderedDescending) {
        if ([self compare:minX_A with:maxX_B] == NSOrderedDescending) {
            // left to right
            [self addHorLineData:horDatas startX:maxX_B endX:minX_A y:midY_A 
                    displayValue:CGRectGetMinX(self.originalMainFrame) - CGRectGetMaxX(self.originalReferFrame)];
        }
    }
    
    // Vertically, the vertical direction-direct
    if ([self compare:minY_A with:minY_B] == NSOrderedAscending) {
        if ([self compare:maxY_A with:minY_B] == NSOrderedAscending) {
            // bottom to top
            [self addVerLineData:verDatas x:midX_A startY:maxY_A endY:minY_B 
                    displayValue:CGRectGetMinY(self.originalReferFrame) - CGRectGetMaxY(self.originalMainFrame)];
        }
    } else if ([self compare:minY_A with:minY_B] == NSOrderedDescending) {
        if ([self compare:minY_A with:maxY_B] == NSOrderedDescending) {
            // top to bottom
            [self addVerLineData:verDatas x:midX_A startY:maxY_B endY:minY_A 
                    displayValue:CGRectGetMinY(self.originalMainFrame) - CGRectGetMaxY(self.originalReferFrame)];
        }
    }
    
    // Draw lines and label tabs to draw a lineline
    [self drawLinesWithHorData:horDatas verData:verDatas];
}

- (void)addHorLineData:(NSMutableArray *)horDatas 
                startX:(CGFloat)startX 
                  endX:(CGFloat)endX 
                     y:(CGFloat)y 
          displayValue:(CGFloat)displayValue {
    AVX512LookinMeasureResultHorLineData *data = [AVX512LookinMeasureResultHorLineData new];
    data.startX = startX;
    data.endX = endX;
    data.y = y;
    data.displayValue = ABS(displayValue);
    [horDatas addObject:data];
}

- (void)addVerLineData:(NSMutableArray *)verDatas 
                     x:(CGFloat)x 
                startY:(CGFloat)startY 
                  endY:(CGFloat)endY 
          displayValue:(CGFloat)displayValue {
    AVX512LookinMeasureResultVerLineData *data = [AVX512LookinMeasureResultVerLineData new];
    data.x = x;
    data.startY = startY;
    data.endY = endY;
    data.displayValue = ABS(displayValue);
    [verDatas addObject:data];
}

- (void)drawLinesWithHorData:(NSArray *)horDatas verData:(NSArray *)verDatas {
    CGMutablePathRef horPath = CGPathCreateMutable();
    CGMutablePathRef verPath = CGPathCreateMutable();
    
    // Draws to draw a drawing of the
    for (AVX512LookinMeasureResultHorLineData *data in horDatas) {
        CGPathMoveToPoint(horPath, NULL, data.startX, data.y);
        CGPathAddLineToPoint(horPath, NULL, data.endX, data.y);
        
        // Adds the addition of a measured measure
        UILabel *label = [self createMeasurementLabel];
        label.text = [NSString stringWithFormat:@"%.1f", data.displayValue];
        label.center = CGPointMake((data.startX + data.endX) / 2, data.y - 10);
        [self addSubview:label];
        [self.measureLabels addObject:label];
    }
    
    // Draws to draw a drawing of the
    for (AVX512LookinMeasureResultVerLineData *data in verDatas) {
        CGPathMoveToPoint(verPath, NULL, data.x, data.startY);
        CGPathAddLineToPoint(verPath, NULL, data.x, data.endY);
        
        // Adds the addition of a measured measure
        UILabel *label = [self createMeasurementLabel];
        label.text = [NSString stringWithFormat:@"%.1f", data.displayValue];
        label.center = CGPointMake(data.x - 15, (data.startY + data.endY) / 2);
        label.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [self addSubview:label];
        [self.measureLabels addObject:label];
    }
    
    // Sets a path to set the
    self.horSolidLinesLayer.path = horPath;
    self.verSolidLinesLayer.path = verPath;
    self.horSolidLinesLayer.hidden = NO;
    self.verSolidLinesLayer.hidden = NO;
    
    CGPathRelease(horPath);
    CGPathRelease(verPath);
}

- (UILabel *)createMeasurementLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 3;
    label.layer.masksToBounds = YES;
    [label sizeToFit];
    return label;
}

- (void)hideAllLabels {
    for (UILabel *label in self.measureLabels) {
        [label removeFromSuperview];
    }
    [self.measureLabels removeAllObjects];
}

- (NSComparisonResult)compare:(CGFloat)a with:(CGFloat)b {
    const CGFloat epsilon = 0.1; // The portability margin value of the tolerance
    if (ABS(a - b) < epsilon) {
        return NSOrderedSame;
    } else if (a < b) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

@end