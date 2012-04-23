#import "PathEditorController.h"
#import "PathsView.h"
#import "PathListController.h"

@implementation PathEditorController

@synthesize pathName, pathNameField;
@synthesize pathList, pathsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        pathName = nil;
    }
    return self;
}

- (IBAction)renameEvent:(id)sender
{
    //TODO: Make sure that there is at least 1 nonspace character
    NSString *oldName = pathName;
    [self setPathName:[sender text]];
    if(oldName)
    {
        [pathsView renamePathFrom:oldName to:pathName];
        [[pathList pathPicker] reloadData];
    }
}

- (void)setPathName:(NSString *)_pathName
{
    pathName = _pathName;
    [pathNameField setText:pathName];
}

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
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[pathList pathPicker] setEditing:false];
}

@end
