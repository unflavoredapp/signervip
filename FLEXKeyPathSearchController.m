//
//  AVX512KeyPathSearchController.m
//  FLEX
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "FLEXKeyPathSearchController.h"
#import "FLEXRuntimeKeyPathTokenizer.h"
#import "FLEXRuntimeController.h"
#import "NSString+FLEX.h"
#import "NSArray+FLEX.h"
#import "UITextField+Range.h"
#import "NSTimer+FLEX.h"
#import "FLEXTableView.h"
#import "FLEXUtility.h"
#import "FLEXObjectExplorerFactory.h"

@interface AVX512KeyPathSearchController ()
@property (nonatomic, readonly, weak) id<AVX512KeyPathSearchControllerDelegate> delegate;
@property (nonatomic) NSTimer *timer;
/// If if, what \c keyPath Yes, yes or \c nil Or maybe only or just \c bundleKeyIt's, it is the
/// One that contains an image of the \c UICatalog or/or is, \c UIKit\.framework Such such as this type of packagekey key packages path to
/// If if, what \c keyPath More than more content has been added \c bundleKey, then it's a class name list.
@property (nonatomic) NSArray<NSString *> *bundlesOrClasses;
/// When the search bar is empty, when a Searchbar fieldnil
@property (nonatomic) AVX512RuntimeKeyPath *keyPath;

@property (nonatomic, readonly) NSString *emptySuggestion;

/// This is used in two scenarios: this applies to both settings.
/// (1) When the target category is absolute and has a class, when an objective grouping of objectives
/// (This list will include this listing that would be included"Ye Le leaves and I"Classes of class and mas or patri)
/// Or or maybe, (2) When the type key is a wildcard, we search for methods in multiple classes while searching through several categories. You can also find solutions when
/// \c classesToMethods , each of the lists in every list is corresponding to a class here
@property (nonatomic) NSArray<NSString *> *classes;
/// Searching for a particular attribute is used to search the \c classes . The filter-fil Filter version of the
/// There are no matching examples of instances where/The property of the attribute/the class of method will not be shown. The group category
@property (nonatomic) NSArray<NSString *> *filteredClasses;
// Whether or not the target group is absolute, we'll use this as if it were just like above.
@property (nonatomic) NSArray<NSArray<AVX512Method *> *> *classesToMethods;
@end

@implementation AVX512KeyPathSearchController

+ (instancetype)delegate:(id<AVX512KeyPathSearchControllerDelegate>)delegate {
    AVX512KeyPathSearchController *controller = [self new];
    controller->_bundlesOrClasses = [AVX512RuntimeController allBundleNames];
    controller->_delegate         = delegate;
    controller->_emptySuggestion  = NSBundle.mainBundle.executablePath.lastPathComponent;

    NSParameterAssert(delegate.tableView);
    NSParameterAssert(delegate.searchController);

    delegate.tableView.delegate   = controller;
    delegate.tableView.dataSource = controller;
    
    UISearchBar *searchBar = delegate.searchController.searchBar;
    searchBar.delegate = controller;   
    searchBar.keyboardType = UIKeyboardTypeWebSearch;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    if (@available(iOS 11, *)) {
        searchBar.smartQuotesType = UITextSmartQuotesTypeNo;
        searchBar.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    }

    return controller;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
        [self.delegate.searchController.searchBar resignFirstResponder];
    }
}

- (void)setToolbar:(AVX512RuntimeBrowserToolbar *)toolbar {
    _toolbar = toolbar;
    self.delegate.searchController.searchBar.inputAccessoryView = toolbar;
}

- (NSArray<NSString *> *)classesOf:(NSString *)className {
    Class baseClass = NSClassFromString(className);
    if (!baseClass) {
        return @[];
    }

    // Finds a search to find the
    NSMutableArray<NSString*> *classes = [NSMutableArray arrayWithObject:className];
    while ([baseClass superclass]) {
        [classes addObject:NSStringFromClass([baseClass superclass])];
        baseClass = [baseClass superclass];
    }

    return classes;
}

#pragma mark Key key path-related keys to the

- (void)didSelectKeyPathOption:(NSString *)text {
    [_timer invalidate]; // At the time of choosing a method, it may be still waiting to wait

    // will be expected that the "Bundle.fooba" Change changed as change to change "Bundle.foobar."
    NSString *orig = self.delegate.searchController.searchBar.text;
    NSString *keyPath = [orig avx512_stringByReplacingLastKeyPathComponent:text];
    self.delegate.searchController.searchBar.text = keyPath;

    self.keyPath = [AVX512RuntimeKeyPathTokenizer tokenizeString:keyPath];

    // If a class has been chosen if the category is selected, then acquire
    if (self.keyPath.classKey.isAbsolute && self.keyPath.methodKey.isAny) {
        [self didSelectAbsoluteClass:text];
    } else {
        self.classes = nil;
        self.filteredClasses = nil;
    }

    [self updateTable];
}

- (void)didSelectAbsoluteClass:(NSString *)name {
    self.classes          = [self classesOf:name];
    self.filteredClasses  = self.classes;
    self.bundlesOrClasses = nil;
    self.classesToMethods = nil;
}

- (void)didPressButton:(NSString *)text insertInto:(UISearchBar *)searchBar {
    [self.toolbar setKeyPath:self.keyPath suggestions:nil];
    
    // Since since from the iOS 9 Available as of available from start up, is ready iOS 13 % of the remaining medium-
    UITextField *field = [searchBar valueForKey:@"_searchBarTextField"];

    if ([self searchBar:searchBar shouldChangeTextInRange:field.avx512_selectedRange replacementText:text]) {
        [field replaceRange:field.selectedTextRange withText:text];
    }
}

- (NSArray<NSString *> *)suggestions {
    if (self.bundlesOrClasses) {
        if (self.classes) {
            if (self.classesToMethods) {
                // We have selected a class and are searching for metadata data meta-data that we
                return nil;
            }
            
            // We are currently searching for class classes that we'
            return [self.filteredClasses avx512_subArrayUpto:10];
        }
        
        if (!self.keyPath) {
            // Search Bar search bar is empty for the search
            return @[self.emptySuggestion];
        }
        
        // We are currently searching for a package-bag search
        return [self.bundlesOrClasses avx512_subArrayUpto:10];
    }
    
    // We have absolutely no searchable content at all and we
    return nil;
}

#pragma mark - Filter filters through  + UISearchBarDelegate

- (void)updateTable {
    // Calc calculation method, class or package list of options on the back-stage linen to calculate methods
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (self.classes) {
            // Here's where our type key keys are here,"Absolute absolute, absolutely total and in"; and also, or.classes is the super-subclass list listing
            // We want to show some particular methodological methods that we would like
            // TODO: Adds a cache-in some way to add the C
            NSMutableArray *methods = [AVX512RuntimeController
                methodsForToken:self.keyPath.methodKey
                instance:self.keyPath.instanceMethods
                inClasses:self.classes
            ].mutableCopy;
            
            // If we're searching for a method if searching an approach, delete the non-result
            //
            // Note: N. even if a query search does not have no designated method, such `*.*.`...... .,
            // It would also remove the deletion that it might then delete, which could eliminate
            if (self.keyPath.methodKey) {
                [self setNonEmptyMethodLists:methods withClasses:self.classes.mutableCopy];
            } else {
                self.filteredClasses = self.classes;
            }
        }
        else {
            AVX512RuntimeKeyPath *keyPath = self.keyPath;
            NSArray *models = [AVX512RuntimeController dataForKeyPath:keyPath];
            if (keyPath.methodKey) { // We're currently examining methods and
                self.bundlesOrClasses = nil;
                
                NSMutableArray *methods = models.mutableCopy;
                NSMutableArray<NSString *> *classes = [
                    AVX512RuntimeController classesForKeyPath:keyPath
                ];
                self.classes = classes;
                [self setNonEmptyMethodLists:methods withClasses:classes];
            } else { // We are currently looking at packages or classes of bags
                self.bundlesOrClasses = models;
                self.classesToMethods = nil;
            }
        }
        
        // Finally, at the end of finally re-load table tables to be loaded again and load
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateToolbarButtons];
            [self.delegate.tableView reloadData];
        });
    });
}

- (void)updateToolbarButtons {
    // Updates the toolbar update toolbar bar button to
    [self.toolbar setKeyPath:self.keyPath suggestions:self.suggestions];
}

/// After the empty blank part has been removed, distribute distribution .filteredClasses and .classesToMethods
- (void)setNonEmptyMethodLists:(NSMutableArray<NSArray<AVX512Method *> *> *)methods
                   withClasses:(NSMutableArray<NSString *> *)classes {
    // To delete from the section part of which
    NSIndexSet *allEmpty = [methods indexesOfObjectsPassingTest:^BOOL(NSArray *list, NSUInteger idx, BOOL *stop) {
        return list.count == 0;
    }];
    [methods removeObjectsAtIndexes:allEmpty];
    [classes removeObjectsAtIndexes:allEmpty];
    
    self.filteredClasses = classes;
    self.classesToMethods = methods;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Checks whether the character is valid to check if
    if (![AVX512RuntimeKeyPathTokenizer allowedInKeyPath:text]) {
        return NO;
    }
    
    BOOL terminatedToken = NO;
    BOOL isAppending = range.length == 0 && range.location == searchBar.text.length;
    if (isAppending && [text isEqualToString:@"."]) {
        terminatedToken = YES;
    }

    // The actual real resolution of the actually resolves input
    @try {
        text = [searchBar.text stringByReplacingCharactersInRange:range withString:text] ?: text;
        self.keyPath = [AVX512RuntimeKeyPathTokenizer tokenizeString:text];
        if (self.keyPath.classKey.isAbsolute && terminatedToken) {
            [self didSelectAbsoluteClass:self.keyPath.classKey.string];
        }
    } @catch (id e) {
        return NO;
    }

    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_timer invalidate];

    // Ar scheduling arrangements for updating update timer updates to the
    if (searchText.length) {
        if (!self.keyPath.methodKey) {
            self.classes = nil;
            self.filteredClasses = nil;
        }

        self.timer = [NSTimer avx512_fireSecondsFromNow:0.15 block:^{
            [self updateTable];
        }];
    }
    // ... All lines of all line rows or
    else {
        _bundlesOrClasses = [AVX512RuntimeController allBundleNames];
        _classesToMethods = nil;
        _classes = nil;
        _keyPath = nil;
        [self updateToolbarButtons];
        [self.delegate.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.keyPath = AVX512RuntimeKeyPath.empty;
    [self updateTable];
}

/// Restore the key-key path to restore Key return keys's Path paths roadpath guide
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = self.keyPath.description;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_timer invalidate];
    [searchBar resignFirstResponder];
    [self updateTable];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredClasses.count ?: self.bundlesOrClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView
        dequeueReusableCellWithIdentifier:kAVX512MultilineDetailCell
        forIndexPath:indexPath
    ];
    
    if (self.bundlesOrClasses.count) {
        cell.accessoryType        = UITableViewCellAccessoryDetailButton;
        cell.textLabel.text       = self.bundlesOrClasses[indexPath.row];
        cell.detailTextLabel.text = nil;
        if (self.keyPath.classKey) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    // Each part of each section, a line
    else if (self.filteredClasses.count) {
        NSArray<AVX512Method *> *methods = self.classesToMethods[indexPath.row];
        NSMutableString *summary = [NSMutableString new];
        [methods enumerateObjectsUsingBlock:^(AVX512Method *method, NSUInteger idx, BOOL *stop) {
            NSString *format = nil;
            if (idx == methods.count-1) {
                format = @"%@%@";
                *stop = YES;
            } else if (idx < 3) {
                format = @"%@%@\n";
            } else {
                format = @"%@%@\n…";
                *stop = YES;
            }

            [summary appendFormat:format, method.isInstanceMethod ? @"-" : @"+", method.selectorString];
        }];

        cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text       = self.filteredClasses[indexPath.row];
        if (@available(iOS 10, *)) {
            cell.detailTextLabel.text = summary.length ? summary : nil;
        }

    }
    else {
        @throw NSInternalInconsistencyException;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.filteredClasses || self.keyPath.methodKey) {
        return @" ";
    } else if (self.bundlesOrClasses) {
        NSInteger count = self.bundlesOrClasses.count;
        if (self.keyPath.classKey) {
            return AVX512PluralString(count, @"Category category group of class", @"Category category group of class");
        } else {
            return AVX512PluralString(count, @"Pack pack, package packages", @"Pack pack, package packages");
        }
    }

    return [self.delegate tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.filteredClasses || self.keyPath.methodKey) {
        if (section == 0) {
            return 55;
        }

        return 0;
    }

    return 55;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bundlesOrClasses) {
        NSString *bundleSuffixOrClass = self.bundlesOrClasses[indexPath.row];
        if (self.keyPath.classKey) {
            NSParameterAssert(NSClassFromString(bundleSuffixOrClass));
            [self.delegate didSelectClass:NSClassFromString(bundleSuffixOrClass)];
        } else {
            // One package bag was selected by selecting one
            [self didSelectKeyPathOption:bundleSuffixOrClass];
        }
    } else {
        if (self.filteredClasses.count) {
            Class cls = NSClassFromString(self.filteredClasses[indexPath.row]);
            NSParameterAssert(cls);
            [self.delegate didSelectClass:cls];
        } else {
            @throw NSInternalInconsistencyException;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *bundleSuffixOrClass = self.bundlesOrClasses[indexPath.row];
    NSString *imagePath = [AVX512RuntimeController imagePathWithShortName:bundleSuffixOrClass];
    NSBundle *bundle = [NSBundle bundleWithPath:imagePath.stringByDeletingLastPathComponent];

    if (bundle) {
        [self.delegate didSelectBundle:bundle];
    } else {
        [self.delegate didSelectImagePath:imagePath shortName:bundleSuffixOrClass];
    }
}

@end

