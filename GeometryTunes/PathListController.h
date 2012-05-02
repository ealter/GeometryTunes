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
@class PathEditorController;

@interface PathListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>

@property (nonatomic, strong) PathsView *pathView;
@property (nonatomic, strong) ViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UITableView *pathPicker;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editPathBtn;
@property (nonatomic, retain) IBOutlet UISegmentedControl *pathModifyType;

@property (strong, nonatomic) PathEditorController *pathEditor;
@property (strong, nonatomic) UIPopoverController *pathEditorPopover;
@property (nonatomic) int selectedPath; //The row of the path being edited

- (IBAction)newPath;
- (IBAction)editPath;
- (BOOL)pathEditStateIsAdding;
- (void)setPathEditState:(BOOL)isAdding;
- (NSString *)nameForNthCell:(int)row;

@end
