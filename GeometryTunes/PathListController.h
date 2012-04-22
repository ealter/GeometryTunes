//
//  PathListController.h
//  GeometryTunes
//
//  Created by Music2 on 4/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PathsView;
@class ViewController;

@interface PathListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>

@property (strong) PathsView *pathView;
@property (nonatomic, strong) ViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UITableView *pathPicker;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editPathBtn;

- (IBAction)newPath;
- (IBAction)editPath;

@end
