#import "ViewController.h"

@implementation ViewController

@synthesize state;
@synthesize grid;
@synthesize editPathBtn;
@synthesize playPauseButton;
@synthesize tempoTextField;
@synthesize tempo;
@synthesize pathList, pathListPopover;
@synthesize helpMenu;
//@synthesize document;

static NSString *playBtnText = @"Play";
static NSString *pauseBtnText = @"Pause";

- (IBAction)playPauseEvent:(id)sender
{
    if([playPauseButton.currentTitle compare:playBtnText]){
        if(state == NORMAL_STATE)
            [grid pausePlayback];
        else
            [self changeStateToNormal:true];
        [self setPlayStateToStopped];
    }
    else{
        if(state != NORMAL_STATE)
            [self changeStateToNormal:true];
        [grid playPathWithSpeedFactor:tempo reversed:false];
        
        [playPauseButton setTitle:pauseBtnText forState:UIControlStateNormal];
    }
}

- (IBAction)stopEvent:(id)sender
{
    if(state == NORMAL_STATE){
        [grid stopPlayback];
        [self setPlayStateToStopped];
    }
    else
        [self changeStateToNormal:true];
}

- (IBAction)rewindEvent:(id)sender
{
    if(state != NORMAL_STATE)
        [self changeStateToNormal:true];
    [grid pausePlayback];
    [grid playPathWithSpeedFactor:0.5 reversed:true];
}

- (IBAction)fastForwardEvent:(id)sender
{
    if(state != NORMAL_STATE)
        [self changeStateToNormal:true];
    [grid pausePlayback];
    [grid playPathWithSpeedFactor:0.5 reversed:false];
}

- (IBAction)newPathEvent:(id)sender
{
    [self changeStateToNormal:true];
    [editPathBtn setTitle:@"Stop Path" forState:UIControlStateNormal];
    state = PATH_EDIT_STATE;
    if(!pathList)
    {
        pathList = [[PathListController alloc]initWithNibName:@"PathListController" bundle:nil];
        [pathList setPathView:[grid pathView]];
        [pathList setMainViewController:self];
        pathListPopover = [[UIPopoverController alloc]initWithContentViewController:pathList];
    }
    [pathList newPath];
    if(editPathBtn.hidden == true)
        [editPathBtn setHidden:false];
}

- (IBAction)editPathEvent:(id)sender
{
    if(state == PATH_EDIT_STATE)
        [self changeStateToNormal:true];
    else
    {
        [self changeStateToNormal:true];
        [editPathBtn setTitle:@"Stop Path" forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
        if(!pathList)
        {
            pathList = [[PathListController alloc]initWithNibName:@"PathListController" bundle:nil];
            [pathList setPathView:[grid pathView]];
            [pathList setMainViewController:self];
            pathListPopover = [[UIPopoverController alloc]initWithContentViewController:pathList];
            [pathListPopover setDelegate:pathList];
        }
        [pathListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
        
        //TODO change height when many paths
        //CGSize popoverSize = CGSizeMake(200, 300);
        //pathListPopover.popoverContentSize = popoverSize;
    }
}

- (void)pathHasBeenSelected
{
    if(pathListPopover)
        [pathListPopover dismissPopoverAnimated:true];
}

- (IBAction)clearPathEvent:(id)sender
{
    [grid resetPath];
}

- (void)changeStateToNormal:(bool)informGrid
{
    if(state == PATH_EDIT_STATE)
        [editPathBtn setTitle:@"Edit Path" forState:UIControlStateNormal];
    if(informGrid)
        [grid changeToNormalState];
    state = NORMAL_STATE;
}

- (void)setPlayStateToStopped
{
    [playPauseButton setTitle:playBtnText forState:UIControlStateNormal];
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    //NSLog(@"%.1f BPM", ([sender value])*60);
    tempoTextField.text = [NSString stringWithFormat:@"%.1f BPM", ([sender value])*60]; 
    tempo = 1 / [sender value];
    
    if([playPauseButton.currentTitle compare:playBtnText]){ //If playing
        [grid setSpeedFactor:tempo];
    }
}

- (void)addWoodBackground
{
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"woodBackground.jpg"]];
    self.view.backgroundColor = background;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    tempo = 1;
    state = NORMAL_STATE;
    [grid setDelegate:self];
    [self addWoodBackground];
    [editPathBtn setHidden:true];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    return NO;
}

@end
