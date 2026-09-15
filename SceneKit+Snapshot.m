//
//  SceneKit+Snapshot.m
//  FLEX
//
//  Created by Tanner Bennett on 1/8/20.
//

#import "SceneKit+Snapshot.h"
#import "FHSSnapshotNodes.h"

/// This value has been selected to avoid avoiding the same values in order notzAn occurrence occurs between no point of the place position and azAxis of conflict, ax
/// But it's small enough to be so much smaller that they look visually in the same plane of a
CGFloat const kFHSSmallZOffset = 0.05;
CGFloat const kHeaderVerticalInset = 8.0;

#pragma mark SCNGeometry
@interface SCNGeometry (SnapshotPrivate)
@end
@implementation SCNGeometry (SnapshotPrivate)

- (void)addDoubleSidedMaterialWithDiffuseContents:(id)contents {
    SCNMaterial *material = [SCNMaterial new];
    material.doubleSided = YES;
    material.diffuse.contents = contents;
    [self insertMaterial:material atIndex:0];
}

@end

#pragma mark SCNNode
@implementation SCNNode (Snapshot)

- (SCNNode *)nearestAncestorSnapshot {
    SCNNode *node = self;

    while (!node.name && node) {
        node = node.parentNode;
    }

    return node;
}

+ (instancetype)shapeNodeWithSize:(CGSize)size materialDiffuse:(id)contents offsetZ:(BOOL)offsetZ {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(
        0, 0, size.width, size.height
    )];
    SCNShape *shape = [SCNShape shapeWithPath:path materialDiffuse:contents];
    SCNNode *node = [SCNNode nodeWithGeometry:shape];
    
    if (offsetZ) {
        node.position = SCNVector3Make(0, 0, kFHSSmallZOffset);
    }
    return node;
}

+ (instancetype)highlight:(FHSViewSnapshot *)view color:(UIColor *)color {
    return [self shapeNodeWithSize:view.frame.size materialDiffuse:color offsetZ:YES];
}

+ (instancetype)snapshot:(FHSViewSnapshot *)view {
    id image = view.snapshotImage;
    return [self shapeNodeWithSize:view.frame.size materialDiffuse:image offsetZ:NO];
}

+ (instancetype)lineFrom:(SCNVector3)v1 to:(SCNVector3)v2 color:(UIColor *)lineColor {
    SCNVector3 vertices[2] = { v1, v2 };
    int32_t _indices[2] = { 0, 1 };
    NSData *indices = [NSData dataWithBytes:_indices length:sizeof(_indices)];
    
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vertices count:2];
    SCNGeometryElement *element = [SCNGeometryElement
        geometryElementWithData:indices
        primitiveType:SCNGeometryPrimitiveTypeLine
        primitiveCount:2
        bytesPerIndex:sizeof(int32_t)
    ];

    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
    [geometry addDoubleSidedMaterialWithDiffuseContents:lineColor];
    return [SCNNode nodeWithGeometry:geometry];
}

- (instancetype)borderWithColor:(UIColor *)color {
    struct { SCNVector3 min, max; } bb;
    [self getBoundingBoxMin:&bb.min max:&bb.max];

    SCNVector3 topLeft = SCNVector3Make(bb.min.x, bb.max.y, kFHSSmallZOffset);
    SCNVector3 bottomLeft = SCNVector3Make(bb.min.x, bb.min.y, kFHSSmallZOffset);
    SCNVector3 topRight = SCNVector3Make(bb.max.x, bb.max.y, kFHSSmallZOffset);
    SCNVector3 bottomRight = SCNVector3Make(bb.max.x, bb.min.y, kFHSSmallZOffset);

    SCNNode *top = [SCNNode lineFrom:topLeft to:topRight color:color];
    SCNNode *left = [SCNNode lineFrom:bottomLeft to:topLeft color:color];
    SCNNode *bottom = [SCNNode lineFrom:bottomLeft to:bottomRight color:color];
    SCNNode *right = [SCNNode lineFrom:bottomRight to:topRight color:color];

    SCNNode *border = [SCNNode new];
    [border addChildNode:top];
    [border addChildNode:left];
    [border addChildNode:bottom];
    [border addChildNode:right];

    return border;
}

+ (instancetype)header:(FHSViewSnapshot *)view {
    SCNText *text = [SCNText labelGeometry:view.title font:[UIFont boldSystemFontOfSize:13.0]];
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];

    struct { SCNVector3 min, max; } bb;
    [textNode getBoundingBoxMin:&bb.min max:&bb.max];
    CGFloat textWidth = bb.max.x - bb.min.x;
    CGFloat textHeight = bb.max.y - bb.min.y;

    CGFloat snapshotWidth = view.frame.size.width;
    CGFloat headerWidth = MAX(snapshotWidth, textWidth);
    CGRect frame = CGRectMake(0, 0, headerWidth, textHeight + (kHeaderVerticalInset * 2));
    SCNNode *headerNode = [SCNNode nodeWithGeometry:[SCNShape
        nameHeader:view.headerColor frame:frame corners:8
    ]];
    [headerNode addChildNode:textNode];

    textNode.position = SCNVector3Make(
        (frame.size.width / 2.f) - (textWidth / 2.f),
        (frame.size.height / 2.f) - (textHeight / 2.f),
        kFHSSmallZOffset
    );
    headerNode.position = SCNVector3Make(
       (snapshotWidth / 2.f) - (headerWidth / 2.f),
       view.frame.size.height,
       kFHSSmallZOffset
    );

    return headerNode;
}

+ (instancetype)snapshot:(FHSViewSnapshot *)view
                  parent:(FHSViewSnapshot *)parent
              parentNode:(SCNNode *)parentNode
                    root:(SCNNode *)rootNode
                   depth:(NSInteger *)depthOut
                nodesMap:(NSMutableDictionary<NSString *, FHSSnapshotNodes *> *)nodesMap
             hideHeaders:(BOOL)hideHeaders {
    NSInteger const depth = *depthOut;

    // Ignores the invisible elements of an element that is not visible
    // These should appear in the list lists, but not on or out of3DViews in view of the views that are
    if (view.hidden || CGSizeEqualToSize(view.frame.size, CGSizeZero)) {
        return nil;
    }

    // Creates a node in which the element ' s snapshot of an elements is taken as
    SCNNode *node = [self snapshot:view];
    node.name = view.view.identifier;

    // Start start to build the building of a nonocent
    FHSSnapshotNodes *nodes = [FHSSnapshotNodes snapshot:view depth:depth];
    nodes.snapshot = node;

    // It must be necessary to add the nod point value of a Nog
    // To allow the coordinate space of coordinates below to calculate normal working, work-
    [rootNode addChildNode:node];
    node.position = ({
        // Flip flip-troll upside reversalyCoordinates, because of the coordinates 'SceneKitThe use is used to be the
        // UIKitRot flip-to overversion version of the to
        CGRect pframe = parent ? parent.frame : CGRectZero;
        CGFloat y = parent ? pframe.size.height - CGRectGetMaxY(view.frame) : 0;

        // In order to simplify the simplification of simplifiedzThe calculation of the axi space spacing between axes is calculated, and
        // The direct sub-node at the root of every snapshot no point in each spot, and not by turning it into a
        // Embe embedded into their parent nodes, and with them in which they are nestedUIThe structure of the elements is identical. E element
        // With this flat hierarchical structure of the hierarchy, with such a level-tzLocation of the location where you can
        // calculates each no point of every dot by simply multiplying the spacing between intervals to depth through a simple
        //
        // Here the citation quoted here cited`parentSnapshotNode`Actually it is not actually`node`The actual parent node, the real father's
        // It is the correspondence to which itUINode no point of the dots at which you are not
        // It is used to use it for using frame coordinates of the frames from a boundary border with
        // Converts to a coordinates of the coordinate relative as against root node point points in
        SCNVector3 positionRelativeToParent = SCNVector3Make(view.frame.origin.x, y, 0);
        SCNVector3 positionRelativeToRoot;
        if (parent) {
            positionRelativeToRoot = [rootNode convertPosition:positionRelativeToParent fromNode:parentNode];
        } else {
            positionRelativeToRoot = positionRelativeToParent;
        }
        positionRelativeToRoot.z = 50 * depth;
        positionRelativeToRoot;
    });

    // Create a border box no point Point to create the frame
    nodes.border = [node borderWithColor:view.headerColor];
    [node addChildNode:nodes.border];

    // Create head-heading node to create a Head
    nodes.header = [SCNNode header:view];
    [node addChildNode:nodes.header];
    if (hideHeaders) {
        nodes.header.hidden = YES;
    }

    nodesMap[view.view.identifier] = nodes;

    NSMutableArray<FHSViewSnapshot *> *checkForIntersect = [NSMutableArray new];
    NSInteger maxChildDepth = depth;

    // Indirectly to sub-points; the overlapping little point at which an overlapd child node has a higher depth
    for (FHSViewSnapshot *child in view.children) {
        NSInteger childDepth = depth + 1;

        // The sub-nodes that cross with the brother node are at a point where each of
        // The upper layers of the front brother no prior bro's top one-only and separate
        for (FHSViewSnapshot *sibling in checkForIntersect) {
            if (CGRectIntersectsRect(sibling.frame, child.frame)) {
                childDepth = maxChildDepth + 1;
                break;
            }
        }

        id didMakeNode = [SCNNode
            snapshot:child
            parent:view
            parentNode:node
            root:rootNode
            depth:&childDepth
            nodesMap:nodesMap
            hideHeaders:hideHeaders
        ];
        if (didMakeNode) {
            maxChildDepth = MAX(childDepth, maxChildDepth);
            [checkForIntersect addObject:child];
        }
    }

    *depthOut = maxChildDepth;
    return node;
}

@end


#pragma mark SCNShape
@implementation SCNShape (Snapshot)

+ (instancetype)shapeWithPath:(UIBezierPath *)path materialDiffuse:(id)contents {
    SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:0];
    [shape addDoubleSidedMaterialWithDiffuseContents:contents];
    return shape;
}

+ (instancetype)nameHeader:(UIColor *)color frame:(CGRect)frame corners:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath
        bezierPathWithRoundedRect:frame
        byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
        cornerRadii:CGSizeMake(radius, radius)
    ];
    return [SCNShape shapeWithPath:path materialDiffuse:color];
}

@end


#pragma mark SCNText
@implementation SCNText (Snapshot)

+ (instancetype)labelGeometry:(NSString *)text font:(UIFont *)font {
    NSParameterAssert(text);

    SCNText *label = [self new];
    label.string = text;
    label.font = font;
    label.alignmentMode = kCAAlignmentCenter;
    label.truncationMode = kCATruncationEnd;

    return label;
}

@end
