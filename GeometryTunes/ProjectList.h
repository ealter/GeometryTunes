#import <UIKit/UIKit.h>

@class ViewController;

@interface ProjectList : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UITextField *fileNameField;
@property (nonatomic, retain) IBOutlet UITableView *fileList;

- (IBAction)newProject:(id)sender;
- (IBAction)saveProject:(id)sender;
- (IBAction)editProjects;
- (void)refresh;

@end
