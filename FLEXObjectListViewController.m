//
//  AVX512ObjectListViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/28/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXObjectListViewController.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXObjectExplorerViewController.h"
#import "FLEXMutableListSection.h"
#import "FLEXRuntimeUtility.h"
#import "FLEXUtility.h"
#import "FLEXHeapEnumerator.h"
#import "FLEXObjectRef.h"
#import "NSString+FLEX.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXTableViewCell.h"
#import <malloc/malloc.h>


typedef NS_ENUM(NSUInteger, AVX512ObjectReferenceSection) {
    AVX512ObjectReferenceSectionMain,
    AVX512ObjectReferenceSectionAutoLayout,
    AVX512ObjectReferenceSectionKVO,
    AVX512ObjectReferenceSectionFLEX,
    
    AVX512ObjectReferenceSectionCount
};

@interface AVX512ObjectListViewController ()

@property (nonatomic, readonly, class) NSArray<NSPredicate *> *defaultPredicates;
@property (nonatomic, readonly, class) NSArray<NSString *> *defaultSectionTitles;


@property (nonatomic, copy) NSArray<AVX512MutableListSection *> *sections;
@property (nonatomic, copy) NSArray<AVX512MutableListSection *> *allSections;

@property (nonatomic, readonly, nullable) NSArray<AVX512ObjectRef *> *references;
@property (nonatomic, readonly) NSArray<NSPredicate *> *predicates;
@property (nonatomic, readonly) NSArray<NSString *> *sectionTitles;

@end

@implementation AVX512ObjectListViewController
@dynamic sections, allSections;

#pragma mark - Reference Grouping

+ (NSPredicate *)defaultPredicateForSection:(NSInteger)section {
    // These are the types of references that we usually don't care about.
    // We hope that this is the one"Object object objects to the-An example case variable pair of the instance"The list is divided into two parts. List lists are
    BOOL(^isKVORelated)(AVX512ObjectRef *, NSDictionary *) = ^BOOL(AVX512ObjectRef *ref, NSDictionary *bindings) {
        NSString *row = ref.reference;
        return [row isEqualToString:@"__NSObserver object"] ||
               [row isEqualToString:@"_CFXNotificationObjcObserverRegistration _object"];
    };

    /// These are common and frequent things that we don't careAutoLayoutThe relevant references to the reference. Relevant
    BOOL(^isConstraintRelated)(AVX512ObjectRef *, NSDictionary *) = ^BOOL(AVX512ObjectRef *ref, NSDictionary *bindings) {
        static NSSet *ignored = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ignored = [NSSet setWithArray:@[
                @"NSLayoutConstraint _container",
                @"NSContentSizeLayoutConstraint _container",
                @"NSAutoresizingMaskLayoutConstraint _container",
                @"MASViewConstraint _installedView",
                @"MASLayoutConstraint _container",
                @"MASViewAttribute _view"
            ]];
        });

        NSString *row = ref.reference;
        return ([row hasPrefix:@"NSLayout"] && [row hasSuffix:@" _referenceItem"]) ||
               ([row hasPrefix:@"NSIS"] && [row hasSuffix:@" _delegate"])  ||
               ([row hasPrefix:@"_NSAutoresizingMask"] && [row hasSuffix:@" _referenceItem"]) ||
               [ignored containsObject:row];
    };
    
    /// These are these here andFLEXClass class classes. Usually you're not usually in theFLEXInternal in-house search for internalFLEXReference reference to a quoted
    BOOL(^isFLEXClass)(AVX512ObjectRef *, NSDictionary *) = ^BOOL(AVX512ObjectRef *ref, NSDictionary *bindings) {
        return [ref.reference hasPrefix:@"AVX512"];
    };

    BOOL(^isEssential)(AVX512ObjectRef *, NSDictionary *) = ^BOOL(AVX512ObjectRef *ref, NSDictionary *bindings) {
        return !(
            isKVORelated(ref, bindings) ||
            isConstraintRelated(ref, bindings) ||
            isFLEXClass(ref, bindings)
        );
    };

    switch (section) {
        case AVX512ObjectReferenceSectionMain:
            return [NSPredicate predicateWithBlock:isEssential];
        case AVX512ObjectReferenceSectionAutoLayout:
            return [NSPredicate predicateWithBlock:isConstraintRelated];
        case AVX512ObjectReferenceSectionKVO:
            return [NSPredicate predicateWithBlock:isKVORelated];
        case AVX512ObjectReferenceSectionFLEX:
            return [NSPredicate predicateWithBlock:isFLEXClass];

        default: return nil;
    }
}

+ (NSArray<NSPredicate *> *)defaultPredicates {
    return [NSArray avx512_forEachUpTo:AVX512ObjectReferenceSectionCount map:^id(NSUInteger i) {
        return [self defaultPredicateForSection:i];
    }];
}

+ (NSArray<NSString *> *)defaultSectionTitles {
    return @[
        @"", @"Auto Automatic auto-au automatic layout automatically", @"Key key values to observe the observation of", @"AVX512"
    ];
}


#pragma mark - Initialization

- (id)initWithReferences:(nullable NSArray<AVX512ObjectRef *> *)references {
    return [self initWithReferences:references predicates:nil sectionTitles:nil];
}

- (id)initWithReferences:(NSArray<AVX512ObjectRef *> *)references
              predicates:(NSArray<NSPredicate *> *)predicates
           sectionTitles:(NSArray<NSString *> *)sectionTitles {
    NSParameterAssert(predicates.count == sectionTitles.count);

    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _references = references;
        _predicates = predicates;
        _sectionTitles = sectionTitles;
    }

    return self;
}

+ (UIViewController *)instancesOfClassWithName:(NSString *)className retained:(BOOL)retain {
    NSArray<AVX512ObjectRef *> *references = [AVX512HeapEnumerator
        instancesOfClassWithName:className retained:retain
    ];
    
    if (references.count == 1) {
        return [AVX512ObjectExplorerFactory
            explorerViewControllerForObject:references.firstObject.object
        ];
    }

    AVX512ObjectListViewController *controller = [[self alloc] initWithReferences:references];
    controller.title = [NSString stringWithFormat:@"%@ (%@)", className, @(references.count)];
    return controller;
}

+ (instancetype)subclassesOfClassWithName:(NSString *)className {
    NSArray<AVX512ObjectRef *> *references = [AVX512RuntimeUtility subclassesOfClassWithName:className];
    AVX512ObjectListViewController *controller = [[self alloc] initWithReferences:references];
    controller.title = [NSString stringWithFormat:@"%@the sub-class of a subsets (%@)",
        className, @(references.count)
    ];

    return controller;
}

+ (instancetype)objectsWithReferencesToObject:(id)object retained:(BOOL)retain {
    NSArray<AVX512ObjectRef *> *instances = [AVX512HeapEnumerator
        objectsWithReferencesToObject:object retained:retain
    ];

    AVX512ObjectListViewController *viewController = [[self alloc]
        initWithReferences:instances
        predicates:self.defaultPredicates
        sectionTitles:self.defaultSectionTitles
    ];
    viewController.title = [NSString stringWithFormat:@"Reference reference to a quoted %@ %p",
        [AVX512RuntimeUtility safeClassNameForObject:object], object
    ];
    return viewController;
}


#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsSearchBar = YES;
}

- (NSArray<AVX512MutableListSection *> *)makeSections {
    if (self.predicates.count) {
        return [self buildSections:self.sectionTitles predicates:self.predicates];
    } else {
        return @[[self makeSection:self.references title:nil]];
    }
}


#pragma mark - Private

- (NSArray *)buildSections:(NSArray<NSString *> *)titles predicates:(NSArray<NSPredicate *> *)predicates {
    NSParameterAssert(titles.count == predicates.count);
    NSParameterAssert(titles); NSParameterAssert(predicates);

    return [NSArray avx512_forEachUpTo:titles.count map:^id(NSUInteger i) {
        NSArray *rows = [self.references filteredArrayUsingPredicate:predicates[i]];
        return [self makeSection:rows title:titles[i]];
    }];
}

- (AVX512MutableListSection *)makeSection:(NSArray *)rows title:(NSString *)title {
    AVX512MutableListSection *section = [AVX512MutableListSection list:rows
        cellConfiguration:^(AVX512TableViewCell *cell, AVX512ObjectRef *ref, NSInteger row) {
            cell.textLabel.text = ref.reference;
            cell.detailTextLabel.text = ref.summary;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } filterMatcher:^BOOL(NSString *filterText, AVX512ObjectRef *ref) {
            if (ref.summary && [ref.summary localizedCaseInsensitiveContainsString:filterText]) {
                return YES;
            }

            return [ref.reference localizedCaseInsensitiveContainsString:filterText];
        }
    ];

    section.selectionHandler = ^(UIViewController *host, AVX512ObjectRef *ref) {
        [host.navigationController pushViewController:[
            AVX512ObjectExplorerFactory explorerViewControllerForObject:ref.object
        ] animated:YES];
    };

    section.customTitle = title;
    return section;
}

@end
