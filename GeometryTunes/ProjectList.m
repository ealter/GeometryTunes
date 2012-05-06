#import "ProjectList.h"
#import "ViewController.h"
#import "GridProjects.h"

@interface ProjectList ()

typedef enum AlertType {
    ALERT_NEW_PROJECT,
    ALERT_LOAD_PROJECT
} AlertType;

@property (nonatomic, retain) IBOutlet UITextField *fileNameField;
@property (nonatomic, retain) IBOutlet UITableView *fileList;

- (IBAction)newProject:(id)sender;
- (IBAction)saveProject:(id)sender;
- (void)newProject;
- (void)loadProject;
- (int)rowForProjectName:(NSString *)name;

@end

@implementation ProjectList

@synthesize viewController, popover;
@synthesize fileNameField, fileList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)newProject:(id)sender
{
    if([viewController hasUnsavedChanges]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Any unsaved changes will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"New Project", nil];
        alert.tag = ALERT_NEW_PROJECT;
        [alert show];
    }
    else {
        [self newProject];
    }
}

- (void)loadProject
{
    NSString * projectName = [fileList cellForRowAtIndexPath:[fileList indexPathForSelectedRow]].textLabel.text;
    [viewController loadGridFromFile:projectName];
    [popover dismissPopoverAnimated:YES];
    if([viewController currentFileName])
        [fileNameField setText:[viewController currentFileName]];
}

- (void)newProject
{
    [viewController newGrid];
    [popover dismissPopoverAnimated:YES];
    if([viewController currentFileName])
        [fileNameField setText:@""];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertType type = alertView.tag;
    if(buttonIndex == [alertView firstOtherButtonIndex]) {
        if(type == ALERT_NEW_PROJECT) {
            [self newProject];
        }
        else if(type == ALERT_LOAD_PROJECT) {
            [self loadProject];
        }
    }
}

- (IBAction)saveProject:(id)sender
{
    if([viewController saveGridToFile:[fileNameField text]]) {
        [popover dismissPopoverAnimated:YES];
        [self refresh];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Bad project name" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle != UITableViewCellEditingStyleDelete)
        return;
    [GridProjects deleteProject:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GridProjects gridNameList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Filename Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [GridProjects nthFileName:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([viewController hasUnsavedChanges]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Any unsaved changes will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Load Project", nil];
        alert.tag = ALERT_LOAD_PROJECT;
        [alert show];
    }
    else {
        [self loadProject];
    }
}

- (void)refresh
{
    [fileList reloadData];
    NSString *currentFileName = [viewController currentFileName];
    if(currentFileName) {
        int row = [self rowForProjectName:currentFileName];
        [fileList selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:FALSE scrollPosition:UITableViewScrollPositionNone];
        [fileNameField setText:currentFileName];
    }
}

- (int)rowForProjectName:(NSString *)name
{
    NSMutableArray *names = [GridProjects gridNameList];
    return [names indexOfObject:name];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([viewController currentFileName])
        [fileNameField setText:[viewController currentFileName]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
