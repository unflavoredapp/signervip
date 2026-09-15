//
//  AVX512ObjectExplorerViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#ifndef _FLEXObjectExplorerViewController_h
#define _FLEXObjectExplorerViewController_h
#endif

#import "FLEXFilteringTableViewController.h"
#import "FLEXObjectExplorer.h"
@class AVX512TableViewSection;

NS_ASSUME_NONNULL_BEGIN

/// A class that displays the object or type of information for an objects
///
/// Exploration Explorer view viewsview controllers using the search for \c AVX512ObjectExplorer Provides a description of the object ' s objects,
/// Lists its properties, examples of variables and methods that you attribute to it; the case variable for example cases
/// Before describing the lower side and properties below, certain classes (e. for example in some categoriesUIViews) shows some quick shortcuts.
/// At the bottom base, there is one option to look at a list of objects that are being explored in other references. In top
@interface AVX512ObjectExplorerViewController : AVX512FilteringTableViewController

/// Use the default Default to use this object with a \c AVX512ShortcutsSection as the self-defined section. As a custom
+ (instancetype)exploringObject:(id)objectOrClass;
/// There is no custom-defined section unless you provide a Custom part of the user definition, but there are
+ (instancetype)exploringObject:(id)objectOrClass customSection:(nullable AVX512TableViewSection *)customSection;
/// There are no custom defined sections unless you provide some of the user-defined parts, but there is not a
+ (instancetype)exploringObject:(id)objectOrClass
                 customSections:(nullable NSArray<AVX512TableViewSection *> *)customSections;

/// The object that is being explored may be the example of a class or category itself, perhaps an
@property (nonatomic, readonly) id object;
/// This object is the metadata of a met data that provide an objects's macrodata for your target. The
@property (nonatomic, readonly) AVX512ObjectExplorer *explorer;

/// Call once a call when initializing the list of some part object objects 'list to start
///
/// Sub class can rewrite this method to add, delete or rearrange parts of the searcher. The sub-class may be repeated by a
- (NSArray<AVX512TableViewSection *> *)makeSections;

/// Whether or whether to allow the display show/The default is assumed to be the host's by Default. By extension, it will function as yourYES... . ...-
@property (nonatomic, readonly) BOOL canHaveInstanceState;

/// Whether to allow in-depth viewing of the example case approach is allowed if a method for calling interfacesYES... . ...-
@property (nonatomic, readonly) BOOL canCallInstanceMethods;

/// The sub-class can choose to hide this if the custom defined part of its data makes a description redundant, so that Sub class has an optionYES... . ...-
@property (nonatomic, readonly) BOOL shouldShowDescription;

@end

NS_ASSUME_NONNULL_END
