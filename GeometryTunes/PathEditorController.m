#import "PathEditorController.h"
#import "PathsView.h"
#import "PathListController.h"

@implementation PathEditorController

@synthesize pathName, pathNameField;
@synthesize pathList, pathsView;
@synthesize loopingSwitch;

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

- (IBAction)clearEvent
{
    [[[pathsView paths] objectForKey:pathName]removeAllNotes];
    [pathsView setNeedsDisplay];
}

- (IBAction)loopingChanged:(id)sender
{
    [pathsView setLooping:[sender isOn] pathName:pathName];
}

- (void)setPathName:(NSString *)_pathName
{
    pathName = _pathName;
    [pathNameField setText:pathName];
    [loopingSwitch setOn:[pathsView pathDoesLoop:pathName] animated:FALSE];
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
