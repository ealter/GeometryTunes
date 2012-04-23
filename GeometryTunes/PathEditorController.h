#import <UIKit/UIKit.h>

@class PathsView;
@class PathListController;

@interface PathEditorController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic) IBOutlet UITextField *pathNameField;
@property (nonatomic, copy) NSString *pathName;
@property (nonatomic) PathsView *pathsView;
@property (nonatomic) PathListController *pathList;

- (IBAction)renameEvent:(id)sender;

@end
