#import "PathEditorController.h"
#import "PathsView.h"
#import "PathListController.h"

@interface PathEditorController ()

@property (nonatomic, retain) IBOutlet UITextField *pathNameField;
@property (nonatomic, retain) IBOutlet UISwitch *loopingSwitch;

- (IBAction)renameEvent:(id)sender;
- (IBAction)clearEvent;
- (IBAction)loopingChanged:(id)sender;

@end

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
    NSString *oldName = pathName;
    NSString *newName = [[sender text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([newName length] == 0)
        return;
    [self setPathName:newName];
    if(oldName) {
        [pathsView renamePathFrom:oldName to:pathName];
        [pathList refresh];
    }
}

- (IBAction)clearEvent
{
    [pathsView removeAllNotes];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [pathList setIsEditingPaths:FALSE];
}

@end
