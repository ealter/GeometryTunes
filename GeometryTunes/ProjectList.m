#import "ProjectList.h"
#import "ViewController.h"
#import "GridProjects.h"

@interface ProjectList ()

@property (nonatomic, retain) IBOutlet UITextField *fileNameField;
@property (nonatomic, retain) IBOutlet UITableView *fileList;

- (IBAction)newProject:(id)sender;
- (IBAction)saveProject:(id)sender;

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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Any unsaved changes will be lost" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"New Project", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView firstOtherButtonIndex]) { //new project
        [viewController newGrid];
        [popover dismissPopoverAnimated:YES];
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
        alert.frame = [sender frame];
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
    if([cell.textLabel.text compare:[viewController currentFileName]] == NSOrderedSame) //TODO: this doesn't work yet
    {
        [cell.backgroundView setBackgroundColor:[UIColor yellowColor]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [viewController loadGridFromFile:[GridProjects nthFileName:indexPath.row]];
    [popover dismissPopoverAnimated:YES];
    if([viewController currentFileName])
        [fileNameField setText:[viewController currentFileName]];
}

- (void)refresh
{
    [fileList reloadData];
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
