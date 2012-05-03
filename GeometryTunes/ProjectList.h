#import <UIKit/UIKit.h>

/* This module controls a project editor. The editor lists the files and allows users to save/load, create new projects, and delete projects. */
@class ViewController;

@interface ProjectList : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain) UIPopoverController *popover; /* The popover that this view is displayed in */

- (void)refresh;

@end
