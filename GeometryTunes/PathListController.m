#import "PathListController.h"
#import "PathsView.h"
#import "ViewController.h"
#import "PathEditorController.h"
#import "GridView.h"

@interface PathListController ()

@property (nonatomic, retain) IBOutlet UITableView *pathPicker;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editPathBtn;
@property (nonatomic, retain) IBOutlet UISegmentedControl *pathModifyType;

@property (nonatomic) int selectedPath; //The row of the path being edited

- (IBAction)newPath;
- (IBAction)editPath;

- (void)setPathEditState:(BOOL)isAdding;
- (NSString *)nameForNthCell:(int)row;

@end

@implementation PathListController

@synthesize pathView, pathPicker, editPathBtn;
@synthesize pathModifyType;
@synthesize mainViewController;
@synthesize pathEditor, pathEditorPopover;
@synthesize selectedPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    assert(pathPicker);
    [pathPicker setAllowsSelectionDuringEditing:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)refresh
{
    [pathPicker reloadData];
    [pathPicker selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)setIsEditingPaths:(BOOL)isEditing
{
    [pathPicker setEditing:isEditing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    assert(pathView);
    return [pathView numPaths];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Path cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [pathView nthPathName:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *pathName = [pathView nthPathName:indexPath.row];
    [pathView deletePath:pathName];
    [pathPicker reloadData];
    if([pathName isEqualToString:[pathEditor pathName]])
        [pathEditorPopover dismissPopoverAnimated:TRUE];
    if([mainViewController pathLabel].text == pathName){
        [mainViewController pathLabel].text = @"";
    }
}

- (void)showPathEditor:(NSIndexPath *)location
{
    [pathPicker setEditing:true];
    if(!pathEditor)
    {
        pathEditor = [[PathEditorController alloc]initWithNibName:@"PathEditorController" bundle:nil];
        [pathEditor setPathList:self];
        [pathEditor setPathsView:[[mainViewController grid] pathView]];
        pathEditorPopover = [[UIPopoverController alloc]initWithContentViewController:pathEditor];
        [pathEditorPopover setDelegate:pathEditor];
        [pathEditorPopover setPassthroughViews:[NSArray arrayWithObject:pathPicker]];
    }
    [pathEditorPopover presentPopoverFromRect:[pathPicker convertRect:[pathPicker rectForRowAtIndexPath:location] toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:TRUE];
    [pathEditor setPathName:[self nameForNthCell:selectedPath]];
    
    CGSize popoverSize = CGSizeMake(300, 200);
    pathEditorPopover.popoverContentSize = popoverSize;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(pathView);
    if([tableView isEditing]) {
        [pathEditorPopover dismissPopoverAnimated:FALSE];
        [self setSelectedPath:indexPath.row];
        [self showPathEditor:indexPath];
    }
    else {
        [pathView setCurrentPathName:[pathView nthPathName:indexPath.row]];
        if(mainViewController)
            [mainViewController pathHasBeenSelected];
    }
    NSString *pathName = [[NSString alloc]initWithString:[self nameForNthCell:indexPath.row]];
    [mainViewController changePathLabel:pathName];
}

- (void)setPathView:(PathsView *)_pathView
{
    pathView = _pathView;
    [pathEditor setPathsView:pathView];
}

- (IBAction)newPath
{
    int pathNum = [pathView numPaths];
    NSString *pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum];
    for(; [pathView pathExists:pathName]; pathNum++, pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum]);
    [pathView addPath:pathName];
    [pathPicker reloadData];
    if(mainViewController) {
        [mainViewController pathHasBeenSelected];
        [self setPathEditState:TRUE];
    }
}

- (NSString *)nameForNthCell:(int)row
{
    return [[[pathPicker cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] textLabel] text];
}

- (IBAction)editPath
{
    if([pathView numPaths] == 0)
        return;
    [pathPicker setEditing:![pathPicker isEditing]];
    if(![pathPicker isEditing]) {
        [pathEditorPopover dismissPopoverAnimated:TRUE];
        return;
    }
    selectedPath = 0;
    NSIndexPath *index = [NSIndexPath indexPathForRow:selectedPath inSection:0];
    [pathPicker selectRowAtIndexPath:index animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    [self showPathEditor:index];
}

- (BOOL)pathEditStateIsAdding
{
    return [pathModifyType selectedSegmentIndex] == 0;
}

- (void)setPathEditState:(BOOL)isAdding
{
    [pathModifyType setSelectedSegmentIndex:(isAdding ? 0 : 1)];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(mainViewController && ![pathView currentPathName])
        [mainViewController changeStateToNormal:true];
}

@end
