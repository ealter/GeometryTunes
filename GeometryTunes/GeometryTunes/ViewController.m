#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation ViewController

@synthesize state;
@synthesize grid;
@synthesize editPathBtn;
@synthesize playPauseButton;
@synthesize speedSlider;
@synthesize speedTextField;

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


- (IBAction) sliderValueChanged:(id)sender
{
    //NSString *speed = [sender value];
    //speedTextField.text = [NSString stringWithFormat:@"%.1f", [sender value]];
    
    NSString *textValue = [speedTextField text];  
    float value = [textValue floatValue];  
    if (value < -20) value = -20;  
    if (value > 20) value = 20;  
    //speedSlider.value = value;  
    speedTextField.text = [NSString stringWithFormat:@"%.1f", value];  
    //if ([speedTextField canResignFirstResponder]) [speedTextField resignFirstResponder]; 
}

- (IBAction)editPathEvent:(id)sender
{
    //if(!clearPathBtnPresent)
    //    [self.view addSubview:clearPathBtn];
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
    //[clearPathBtn removeFromSuperview];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)changeButtonBackgroundColor:(id)sender
{
    [sender setBackgroundColor:[UIColor cyanColor]];
}

-(IBAction)resetButtonBackroundColor:(id)sender
{
    [sender setBackgroundColor:[UIColor whiteColor]];
}

- (void)addGradientToRect:(CGRect)rect 
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
        1.0, 1.0, 1.0, 0.06 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.view.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace); 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    state = NORMAL_STATE;
    [grid setDelegate:self];
    
    //Fix slowdown when loading the first sound
    NSURL *sound1 = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"A5" ofType:@"mp3"]];
    assert(sound1);
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:sound1 error:nil];
    
    [player prepareToPlay];
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
    return YES;
}

@end
