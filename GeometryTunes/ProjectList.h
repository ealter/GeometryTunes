#import <UIKit/UIKit.h>

@class ViewController;

@interface ProjectList : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain) UIPopoverController *popover;

-(IBAction)newProject;
-(IBAction)saveProject;

@end
