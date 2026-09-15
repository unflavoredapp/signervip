//
//  UCClassSearchViewController.h
//  FLEX++
//
//  Class name search searching for class names and category head-searcher viewers in categories searches
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Searchs the search interface ' s use mode pattern
typedef NS_ENUM(NSInteger, UCClassSearchMode) {
    UCClassSearchModeClassDump = 0,  ///< First first-head file mode: Click a category name to show the headfile front filename display
    UCClassSearchModeDisassembler,   ///< Counter-compback compilation mode: Click a class name to show the list of methods method lists by clicking on an alias
};

@interface UCClassSearchViewController : UIViewController

/// Search pattern search mode, the default's Default is UCClassSearchModeClassDump
@property (nonatomic, assign) UCClassSearchMode searchMode;

/// To facilitate the facilitation of tect
+ (instancetype)searchViewControllerWithMode:(UCClassSearchMode)mode;

@end

NS_ASSUME_NONNULL_END
