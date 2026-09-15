//
//  AVX512ObjectExplorerViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXObjectExplorerViewController.h"
#import "FLEXUtility.h"
#import "FLEXRuntimeUtility.h"
#import "UIBarButtonItem+FLEX.h"
#import "FLEXMultilineTableViewCell.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXFieldEditorViewController.h"
#import "FLEXMethodCallingViewController.h"
#import "FLEXObjectListViewController.h"
#import "FLEXTabsViewController.h"
#import "FLEXBookmarkManager.h"
#import "FLEXTableView.h"
#import "FLEXResources.h"
#import "FLEXTableViewCell.h"
#import "FLEXScopeCarousel.h"
#import "FLEXMetadataSection.h"
#import "FLEXSingleRowSection.h"
#import "FLEXShortcutsSection.h"
#import "NSUserDefaults+FLEX.h"
#import "x/ClassDump/UCClassHeaderDetailViewController.h"
#import <objc/runtime.h>

#pragma mark - Home Private Properties property private-private
@interface AVX512ObjectExplorerViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) AVX512SingleRowSection *descriptionSection;
@property (nonatomic, readonly) NSArray<AVX512TableViewSection *> *customSections;
@property (nonatomic) NSIndexSet *customSectionVisibleIndexes;

@property (nonatomic, readonly) NSArray<NSString *> *observedNotifications;

@end

@implementation AVX512ObjectExplorerViewController

#pragma mark - Initial initialisation to start-in

+ (instancetype)exploringObject:(id)target {
    return [self exploringObject:target customSection:[AVX512ShortcutsSection forObject:target]];
}

+ (instancetype)exploringObject:(id)target customSection:(AVX512TableViewSection *)section {
    return [self exploringObject:target customSections:@[section]];
}

+ (instancetype)exploringObject:(id)target customSections:(NSArray *)customSections {
    return [[self alloc]
        initWithObject:target
        explorer:[AVX512ObjectExplorer forObject:target]
        customSections:customSections
    ];
}

- (id)initWithObject:(id)target
            explorer:(__kindof AVX512ObjectExplorer *)explorer
       customSections:(NSArray<AVX512TableViewSection *> *)customSections {
    NSParameterAssert(target);
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _object = target;
        _explorer = explorer;
        _customSections = customSections;
    }

    return self;
}

- (NSArray<NSString *> *)observedNotifications {
    return @[
        kAVX512DefaultsHidePropertyIvarsKey,
        kAVX512DefaultsHidePropertyMethodsKey,
        kAVX512DefaultsHidePrivateMethodsKey,
        kAVX512DefaultsShowMethodOverridesKey,
        kAVX512DefaultsHideVariablePreviewsKey,
    ];
}

#pragma mark - View controller view handler 's life-life

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsShareToolbarItem = YES;
    self.wantsSectionIndexTitles = YES;

    // Here use is used here[object class]not and instead rather thanobject_getClass
    // In order to avoid avoiding the viewed object from beingKVOPre-send pre
    self.title = [AVX512RuntimeUtility safeClassNameForObject:self.object];

    // Search search and searching for
    self.showsSearchBar = YES;
    self.searchBarDebounceInterval = kAVX512DebounceInstant;
    self.showsCarousel = YES;

    // Round-wide scope area of play range barbar
    [self.explorer reloadClassHierarchy];
    self.carousel.items = [self.explorer.classHierarchyClasses avx512_mapped:^id(Class cls, NSUInteger idx) {
        return NSStringFromClass(cls);
    }];
    
    // The extra options to use for the additional option that...But button to the press
    [self addToolbarItems:@[[UIBarButtonItem
        avx512_itemWithImage:AVX512Resources.moreIcon target:self action:@selector(moreButtonPressed:)
    ]]];

    // Slides of the moving hand-mo gesture that slip slide between classes in a hierarchy structure
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleSwipeGesture:)
    ];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleSwipeGesture:)
    ];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    leftSwipe.delegate = self;
    rightSwipe.delegate = self;
    [self.tableView addGestureRecognizer:leftSwipe];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    // Observing preferences options that may be changed on other screens to observe the preference option
    //
    // "If your application is specific to you ifiOS 9.0and above or more, versions of the version(macOS 10.11and higher or more, versions of the /
    // , otherwise there is no need todeallocis the method in which observers are written off."
    for (NSString *pref in self.observedNotifications) {
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(fullyReloadData)
            name:pref
            object:nil
        ];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.navigationController setToolbarHidden:NO animated:YES];
    return YES;
}


#pragma mark - Re-rewn rewritten

/// Rewu rewritten to hide the description part of a described narrative section hidden in
- (NSArray<AVX512TableViewSection *> *)nonemptySections {
    if (self.shouldShowDescription) {
        return super.nonemptySections;
    }
    
    return [super.nonemptySections avx512_filtered:^BOOL(AVX512TableViewSection *section, NSUInteger idx) {
        return section != self.descriptionSection;
    }];
}

- (NSArray<AVX512TableViewSection *> *)makeSections {
    AVX512ObjectExplorer *explorer = self.explorer;
    
    // The descriptive part of the description is described in a
    if (self.explorer.objectIsInstance) {
        _descriptionSection = [AVX512SingleRowSection
            title:@"Description describes the description" reuse:kAVX512MultilineCell cell:^(AVX512TableViewCell *cell) {
                cell.titleLabel.font = UIFont.avx512_defaultTableCellFont;
                cell.titleLabel.text = explorer.objectDescription;
            }
        ];
        self.descriptionSection.filterMatcher = ^BOOL(NSString *filterText) {
            return [explorer.objectDescription localizedCaseInsensitiveContainsString:filterText];
        };
    }

    // Part part of the chart section in a
    AVX512SingleRowSection *referencesSection = [AVX512SingleRowSection
        title:@"A chart of the object to an" reuse:kAVX512DefaultCell cell:^(AVX512TableViewCell *cell) {
            cell.titleLabel.text = @"Views view the object to which objects that have been";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    ];
    referencesSection.selectionAction = ^(UIViewController *host) {
        UIViewController *references = [AVX512ObjectListViewController
            objectsWithReferencesToObject:explorer.object
            retained:NO
        ];
        [host.navigationController pushViewController:references animated:YES];
    };

    NSMutableArray *sections = [NSMutableArray arrayWithArray:@[
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindProperties],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindClassProperties],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindIvars],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindMethods],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindClassMethods],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindClassHierarchy],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindProtocols],
        [AVX512MetadataSection explorer:self.explorer kind:AVX512MetadataKindOther],
        referencesSection
    ]];

    if (self.customSections) {
        [sections insertObjects:self.customSections atIndexes:[NSIndexSet
            indexSetWithIndexesInRange:NSMakeRange(0, self.customSections.count)
        ]];
    }
    if (self.descriptionSection) {
        [sections insertObject:self.descriptionSection atIndex:0];
    }

    return sections.copy;
}

/// In our case as we are, in the circumstances of us where this is just re
/// Or if we change the position in a class hierarchy at level-level structure, reload part of your data. If you have changed its
/// The new and updated version is not \c self.explorer
- (void)reloadData {
    // Checks if any changes have been made to the category area of function fields and updates
    if (self.explorer.classScope != self.selectedScope) {
        self.explorer.classScope = self.selectedScope;
        [self reloadSections];
    }
    
    [super reloadData];
}

- (void)shareButtonPressed:(UIBarButtonItem *)sender {
    [AVX512Alert makeSheet:^(AVX512Alert *make) {
        make.button(@"Add added to bookmarking for Book-to").handler(^(NSArray<NSString *> *strings) {
            [AVX512BookmarkManager addBookmark:self.object];
        });
        make.button(@"Copy copy ex-copy description to").handler(^(NSArray<NSString *> *strings) {
            UIPasteboard.generalPasteboard.string = self.explorer.objectDescription;
        });
        make.button(@"Organisation copy ur copied address URL").handler(^(NSArray<NSString *> *strings) {
            UIPasteboard.generalPasteboard.string = [AVX512Utility addressOfObject:self.object];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self source:sender];
}


#pragma mark - Private private methods and privately-private

/// And with the coming and \c -reloadData Differently, this will refresh all the contents of everything that you want to update -- including search probes
- (void)fullyReloadData {
    [self.explorer reloadMetadata];
    [self reloadSections];
    [self reloadData];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        switch (gesture.direction) {
            case UISwipeGestureRecognizerDirectionRight:
                if (self.selectedScope > 0) {
                    self.selectedScope -= 1;
                }
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                if (self.selectedScope != self.explorer.classHierarchy.count - 1) {
                    self.selectedScope += 1;
                }
                break;

            default:
                break;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)g1 shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)g2 {
    // Priority priority is given to the important and significant movement gestures, rather than our sliding
    if ([g2 isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (g2 == self.navigationController.interactivePopGestureRecognizer) {
            return NO;
        }
        
        if (g2 == self.tableView.panGestureRecognizer) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UISwipeGestureRecognizer *)gesture {
    // No slide-sliding from the wheeler is not allowed to
    CGPoint location = [gesture locationInView:self.tableView];
    if ([self.carousel hitTest:location withEvent:nil]) {
        return NO;
    }
    
    return YES;
}
    
- (void)moreButtonPressed:(UIBarButtonItem *)sender {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    // Maps the preferences option key to a description of content descriptions that map preference options button keys into
    NSDictionary<NSString *, NSString *> *explorerToggles = @{
        kAVX512DefaultsHidePropertyIvarsKey:    @"The property of the attribute-Supports the example instance case variable to",
        kAVX512DefaultsHidePropertyMethodsKey:  @"The property of the attribute-Support to methodological approach support for supporting",
        kAVX512DefaultsHidePrivateMethodsKey:   @"Possible private and possible privately-private methods",
        kAVX512DefaultsShowMethodOverridesKey:  @"The methodological coverage of approach over method",
        kAVX512DefaultsHideVariablePreviewsKey: @"The variable preview of the variables for a"
    };
    
    // Maps the key of an operation itself to a map that maps keys from which it is operating per its own
    // the operation (operations of )"Hide hide-hi hiddenX"( ) The map is designed to the current state.
    //
    // So the default Default's hiding hidden key keys areNOMapSmAMap to map"Shows the display of"
    NSDictionary<NSString *, NSDictionary *> *nextStateDescriptions = @{
        kAVX512DefaultsHidePropertyIvarsKey:    @{ @NO: @"Hide hide-hi hidden ", @YES: @"Shows the display of " },
        kAVX512DefaultsHidePropertyMethodsKey:  @{ @NO: @"Hide hide-hi hidden ", @YES: @"Shows the display of " },
        kAVX512DefaultsHidePrivateMethodsKey:   @{ @NO: @"Hide hide-hi hidden ", @YES: @"Shows the display of " },
        kAVX512DefaultsShowMethodOverridesKey:  @{ @NO: @"Hide hide-hi hidden ", @YES: @"Shows the display of " },
        kAVX512DefaultsHideVariablePreviewsKey: @{ @NO: @"Hide hide-hi hidden ", @YES: @"Shows the display of " },
    };
    
    [AVX512Alert makeSheet:^(AVX512Alert *make) {
        make.title(@"Options options to the option");
        
        for (NSString *option in explorerToggles.allKeys) {
            BOOL current = [defaults boolForKey:option];
            NSString *title = [nextStateDescriptions[option][@(current)]
                stringByAppendingString:explorerToggles[option]
            ];
            make.button(title).handler(^(NSArray<NSString *> *strings) {
                [NSUserDefaults.standardUserDefaults avx512_toggleBoolForKey:option];
                [self fullyReloadData];
            });
        }
        
        make.button(@"Cancel").cancelStyle();
    } showFrom:self source:sender];
}

#pragma mark - Description describes the description

- (BOOL)shouldShowDescription {
    // If we have filter text if there is a Filtered Text, hide it hidden;
    // It's rarely useful to see that the description is seldom used because it has seen
    if (self.filterText.length) {
        return NO;
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // For the descriptive part of that description, we would like to hope for a/Line line that closes up. Row lines of the
    // Other rows use automatic size automatically. The other line
    AVX512TableViewSection *section = self.filterDelegate.sections[indexPath.section];
    
    if (section == self.descriptionSection) {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
            initWithString:self.explorer.objectDescription
            attributes:@{ NSFontAttributeName : UIFont.avx512_defaultTableCellFont }
        ];
        
        return [AVX512MultilineTableViewCell
            preferredHeightWithAttributedText:attributedText
            maxWidth:tableView.frame.size.width - tableView.separatorInset.right
            style:tableView.style
            showsAccessory:NO
        ];
    }

    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.filterDelegate.sections[indexPath.section] == self.descriptionSection;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // Only in the descriptive part of only a"Operation of the operation operations"
    if (self.filterDelegate.sections[indexPath.section] == self.descriptionSection) {
        return action == @selector(copy:);
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UIPasteboard.generalPasteboard.string = self.explorer.objectDescription;
    }
}

@end
