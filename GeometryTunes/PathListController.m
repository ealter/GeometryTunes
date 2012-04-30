#import "PathListController.h"
#import "PathsView.h"
#import "ViewController.h"
#import "PathEditorController.h"

@implementation PathListController

@synthesize pathView, pathPicker, editPathBtn;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    assert(pathPicker);
    [pathPicker setAllowsSelectionDuringEditing:true];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    assert(pathView);
    return [[pathView paths] count];
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
}

- (IBAction)newPath
{
    int pathNum = [[pathView paths] count];
    NSString *pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum];
    for(; [[pathView paths] objectForKey:pathName] != nil; pathNum++, pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum]);
    [pathView addPath:pathName];
    [pathPicker reloadData];
    if(mainViewController) {
        [mainViewController pathHasBeenSelected];
        [mainViewController setPathEditState:TRUE];
    }
}

- (NSString *)nameForNthCell:(int)row
{
    return [[[pathPicker cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] textLabel] text];
}

- (IBAction)editPath
{
    if([[pathView paths] count] == 0)
        return;
    [pathPicker setEditing:![pathPicker isEditing]];
    if(![pathPicker isEditing])
    {
        [pathEditorPopover dismissPopoverAnimated:TRUE];
        return;
    }
    selectedPath = 0;
    [self showPathEditor:[NSIndexPath indexPathForRow:selectedPath inSection:0]];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(mainViewController && ![pathView currentPathName])
        [mainViewController changeStateToNormal:true];
}

@end
