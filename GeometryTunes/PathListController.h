#import <UIKit/UIKit.h>

@class PathsView;
@class ViewController;
@class PathEditorController;

@interface PathListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>

@property (nonatomic, strong) PathsView *pathView;
@property (nonatomic, strong) ViewController *mainViewController;

@property (strong, nonatomic) PathEditorController *pathEditor;
@property (strong, nonatomic) UIPopoverController *pathEditorPopover;

- (BOOL)pathEditStateIsAdding;
- (void)refresh;
- (void)setIsEditingPaths:(BOOL)isEditing;

@end
