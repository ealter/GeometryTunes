#import "ProjectList.h"
#import "ViewController.h"
#import "GridProjects.h"

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

- (IBAction)newProject
{
    //TODO: Add warning about saving
    [viewController newGrid];
    [popover dismissPopoverAnimated:YES];
}

- (IBAction)saveProject
{
    //TODO: prevent empty names
    if([viewController saveGridToFile:[fileNameField text]]) {
        [popover dismissPopoverAnimated:YES];
        [self refresh];
    }
    else {
        //TODO: add some kind of alert
    }
}

- (IBAction)editProjects
{
    [fileList setEditing:![fileList isEditing]];
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
}

- (void)refresh
{
    [fileList reloadData];
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
    if([viewController currentFileName])
        [fileNameField setText:[viewController currentFileName]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
