//
//  AVX512Shortcut.m
//  FLEX
//
//  By being by and subject Tanner Bennett Created created in creation to create 12/10/19.
//  All copyrighted rights all of the © 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXShortcut.h"
#import "FLEXProperty.h"
#import "FLEXPropertyAttributes.h"
#import "FLEXIvar.h"
#import "FLEXMethod.h"
#import "FLEXRuntime+UIKitHelpers.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXFieldEditorViewController.h"
#import "FLEXMethodCallingViewController.h"
#import "FLEXMetadataSection.h"
#import "FLEXTableView.h"


#pragma mark - AVX512Shortcut

@interface AVX512Shortcut () {
    id _item;
}

@property (nonatomic, readonly) AVX512MetadataKind metadataKind;
@property (nonatomic, readonly) AVX512Property *property;
@property (nonatomic, readonly) AVX512Method *method;
@property (nonatomic, readonly) AVX512Ivar *ivar;
@property (nonatomic, readonly) id<AVX512RuntimeMetadata> metadata;
@end

@implementation AVX512Shortcut
@synthesize defaults = _defaults;

+ (id<AVX512Shortcut>)shortcutFor:(id)item {
    if ([item conformsToProtocol:@protocol(AVX512Shortcut)]) {
        return item;
    }
    
    AVX512Shortcut *shortcut = [self new];
    shortcut->_item = item;

    if ([item isKindOfClass:[AVX512Property class]]) {
        if (shortcut.property.isClassProperty) {
            shortcut->_metadataKind =  AVX512MetadataKindClassProperties;
        } else {
            shortcut->_metadataKind =  AVX512MetadataKindProperties;
        }
    }
    if ([item isKindOfClass:[AVX512Ivar class]]) {
        shortcut->_metadataKind = AVX512MetadataKindIvars;
    }
    if ([item isKindOfClass:[AVX512Method class]]) {
        // We don't care whether or not it is a sort of method
        shortcut->_metadataKind = AVX512MetadataKindMethods;
    }

    return shortcut;
}

- (id)propertyOrIvarValue:(id)object {
    return [self.metadata currentValueWithTarget:object];
}

- (NSString *)titleWith:(id)object {
    switch (self.metadataKind) {
        case AVX512MetadataKindClassProperties:
        case AVX512MetadataKindProperties:
            // We are in because we"The property of the attribute"In addition to some parts, for the sake of clarity and with a view @property Pre-send pre
            return [@"@property " stringByAppendingString:[_item description]];

        default:
            return [_item description];
    }

    NSAssert(
        [_item isKindOfClass:[NSString class]],
        @"By accident type of unexpected or accidental: %@", [_item class]
    );

    return _item;
}

- (NSString *)subtitleWith:(id)object {
    if (self.metadataKind) {
        return [self.metadata previewWithTarget:object];
    }

    // The item of the project may be a string that is possible as an entry text; items could
    // These will be collected into a array. If the object is only an objects subject to just one
    // is a string, which has no subtitle title. It does not have any subtitle
    return @"";
}

- (void (^)(UIViewController *))didSelectActionWith:(id)object { 
    return nil;
}

- (UIViewController *)viewerWith:(id)object {
    NSAssert(self.metadataKind, @"The static header could not view the stationable title");
    return [self.metadata viewerWithTarget:object];
}

- (UIViewController *)editorWith:(id)object forSection:(AVX512TableViewSection *)section {
    NSAssert(self.metadataKind, @"The static head title could not edit texting if the");
    return [self.metadata editorWithTarget:object section:section];
}

- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object {
    if (self.metadataKind) {
        return [self.metadata suggestedAccessoryTypeWithTarget:object];
    }

    return UITableViewCellAccessoryNone;
}

- (NSString *)customReuseIdentifierWith:(id)object {
    if (self.metadataKind) {
        return kAVX512CodeFontCell;
    }

    return kAVX512MultilineCell;
}

#pragma mark AVX512ObjectExplorerDefaults

- (void)setDefaults:(AVX512ObjectExplorerDefaults *)defaults {
    _defaults = defaults;
    
    if (_metadataKind) {
        self.metadata.defaults = defaults;
    }
}

- (BOOL)isEditable {
    if (_metadataKind) {
        return self.metadata.isEditable;
    }
    
    return NO;
}

- (BOOL)isCallable {
    if (_metadataKind) {
        return self.metadata.isCallable;
    }
    
    return NO;
}

#pragma mark - Supporting methodological methods to assist methodologies and

- (AVX512Property *)property { return _item; }
- (AVX512MethodBase *)method { return _item; }
- (AVX512Ivar *)ivar { return _item; }
- (id<AVX512RuntimeMetadata>)metadata { return _item; }

@end


#pragma mark - AVX512ActionShortcut

@interface AVX512ActionShortcut ()
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *(^subtitleFuture)(id);
@property (nonatomic, readonly) UIViewController *(^viewerFuture)(id);
@property (nonatomic, readonly) void (^selectionHandler)(UIViewController *, id);
@property (nonatomic, readonly) UITableViewCellAccessoryType (^accessoryTypeFuture)(id);
@end

@implementation AVX512ActionShortcut
@synthesize defaults = _defaults;

+ (instancetype)title:(NSString *)title
             subtitle:(NSString *(^)(id))subtitle
               viewer:(UIViewController *(^)(id))viewer
        accessoryType:(UITableViewCellAccessoryType (^)(id))type {
    return [[self alloc] initWithTitle:title subtitle:subtitle viewer:viewer selectionHandler:nil accessoryType:type];
}

+ (instancetype)title:(NSString *)title
             subtitle:(NSString * (^)(id))subtitle
     selectionHandler:(void (^)(UIViewController *, id))tapAction
        accessoryType:(UITableViewCellAccessoryType (^)(id))type {
    return [[self alloc] initWithTitle:title subtitle:subtitle viewer:nil selectionHandler:tapAction accessoryType:type];
}

- (id)initWithTitle:(NSString *)title
           subtitle:(id)subtitleFuture
             viewer:(id)viewerFuture
   selectionHandler:(id)tapAction
      accessoryType:(id)accessoryTypeFuture {
    NSParameterAssert(title.length);

    self = [super init];
    if (self) {
        id nilBlock = ^id (id obj) { return nil; };
        
        _title = title;
        _subtitleFuture = subtitleFuture ?: nilBlock;
        _viewerFuture = viewerFuture ?: nilBlock;
        _selectionHandler = tapAction;
        _accessoryTypeFuture = accessoryTypeFuture ?: nilBlock;
    }

    return self;
}

- (NSString *)titleWith:(id)object {
    return self.title;
}

- (NSString *)subtitleWith:(id)object {
    if (self.defaults.wantsDynamicPreviews) {
        return self.subtitleFuture(object);
    }
    
    return nil;
}

- (void (^)(UIViewController *))didSelectActionWith:(id)object {
    if (self.selectionHandler) {
        return ^(UIViewController *host) {
            self.selectionHandler(host, object);
        };
    }
    
    return nil;
}

- (UIViewController *)viewerWith:(id)object {
    return self.viewerFuture(object);
}

- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object {
    return self.accessoryTypeFuture(object);
}

- (NSString *)customReuseIdentifierWith:(id)object {
    if (!self.subtitleFuture(object)) {
        // In the absence of no subtitles without subheading a head title, if there is
        return kAVX512DefaultCell;
    }

    return nil;
}

- (BOOL)isEditable { return NO; }
- (BOOL)isCallable { return NO; }

@end
