#import <UIKit/UIKit.h>

@class PathsView;
@class PathListController;

@interface PathEditorController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic, retain) IBOutlet UITextField *pathNameField;
@property (nonatomic, copy) NSString *pathName;
@property (nonatomic, retain) PathsView *pathsView;
@property (nonatomic, retain) PathListController *pathList;

- (IBAction)renameEvent:(id)sender;
- (IBAction)clearEvent;

@end
