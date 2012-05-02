#import <UIKit/UIKit.h>

@class ViewController;

@interface ProjectList : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UITextField *fileNameField;
@property (nonatomic, retain) IBOutlet UITableView *fileList;

-(IBAction)newProject;
-(IBAction)saveProject;
-(void)refresh;

@end
