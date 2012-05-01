#import "ProjectList.h"
#import "ViewController.h"

@implementation ProjectList

@synthesize viewController, popover;

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
    if([viewController currentFileName])
        [viewController saveGridToFile:[viewController currentFileName]];
    else
        [viewController saveGridToFile:@"Test me bro"];
    [popover dismissPopoverAnimated:YES];
    //TODO: Ask for a name if there is none
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[ViewController gridNameList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Filename Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [ViewController nthFileName:indexPath.row];
    if([cell.textLabel.text compare:[viewController currentFileName]] == NSOrderedSame) //TODO: this doesn't work yet
        [cell setBackgroundColor:[UIColor yellowColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [viewController loadGridFromFile:[ViewController nthFileName:indexPath.row]];
    [popover dismissPopoverAnimated:YES];
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
    // Do any additional setup after loading the view from its nib.
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
