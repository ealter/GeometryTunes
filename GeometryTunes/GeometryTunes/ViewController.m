#import "ViewController.h"

@implementation ViewController

@synthesize state;
@synthesize grid;
@synthesize editPathBtn;
@synthesize playPauseButton;

static NSString *playBtnText = @"Play";
static NSString *pauseBtnText = @"Pause";

- (IBAction)playPauseEvent:(id)sender
{
    if([playPauseButton.currentTitle compare:playBtnText]){
        NSLog(@"Time to pause");
        if(state == NORMAL_STATE)
            [grid pausePlayback];
        else
            [self changeStateToNormal:true];
        [self setPlayStateToStopped];
    }
    else{
        if(state != NORMAL_STATE)
            [self changeStateToNormal:true];
        [grid playPathWithSpeedFactor:1 reversed:false];
        
        [sender setTitle:pauseBtnText forState:UIControlStateNormal];
    }
}

- (IBAction)stopEvent:(id)sender
{
    if(state == NORMAL_STATE){
        [grid stopPlayback];
        [playPauseButton setTitle:playBtnText forState:UIControlStateNormal];
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

- (IBAction)editPathEvent:(id)sender
{
    if(state == PATH_EDIT_STATE)
        [self changeStateToNormal:true];
    else
    {
        [self changeStateToNormal:true];
        [editPathBtn setTitle:@"Stop Path" forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
    }
}

- (IBAction)clearPathEvent:(id)sender
{
    [grid resetPath];
}

- (void)changeStateToNormal:(bool)informGrid
{
    if(state == PATH_EDIT_STATE)
        [editPathBtn setTitle:@"Create Path" forState:UIControlStateNormal];
    if(informGrid)
        [grid changeToNormalState];
    state = NORMAL_STATE;
}

- (void)setPlayStateToStopped
{
    [playPauseButton setTitle:playBtnText forState:UIControlStateNormal];
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
    state = NORMAL_STATE;
    [grid setDelegate:self];
    [self addWoodBackground];
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
