#import "ViewController.h"
#import "PathsView.h"
#import "GridView.h"
#import "PathListController.h"
#import "GridProjects.h"
#import "ProjectList.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *playImageFile;
@property (nonatomic, copy) NSString *pauseImageFile;
@property (nonatomic, copy) NSString *pathsImageFile;
@property (nonatomic, copy) NSString *doneImageFile;

@end

@implementation ViewController

@synthesize state;
@synthesize grid, gridProjects;
@synthesize editPathBtn, playPauseButton;
@synthesize tempoTextField, tempo;
@synthesize pathList, pathListPopover;
@synthesize projectList, projectListPopover;
@synthesize playImageFile, pauseImageFile, doneImageFile, pathsImageFile;

//static NSString *playBtnText = @"Play";
//static NSString *pauseBtnText = @"Pause";
static NSString *normalPathBtnText;
static NSString *pathEditBtnText = @"               Done"; //TODO: OMG THIS IS HACKY CODE

- (NSString *)currentFileName
{
    return [gridProjects currentFileName];
}

- (void)loadGridFromFile:(NSString *)fileName
{
    GridView *_grid = [gridProjects loadGridFromFile:fileName];
    if(_grid) {
        [grid removeFromSuperview];
        [self.view addSubview:_grid];
        grid = _grid;
    }
    [grid setDelegate:self];
    [pathList setPathView:[grid pathView]];
}

- (void)saveGridToFile:(NSString *)fileName
{
    [gridProjects saveToFile:fileName grid:grid];
}

- (IBAction)playPauseEvent:(id)sender
{
    if([grid.pathView isPlaying]){ //]compare:playBtnText]){
        if(state == NORMAL_STATE)
            [grid pausePlayback];
        else
            [self changeStateToNormal:true];
        [self setPlayStateToStopped];
        
        UIImage *playImage = [[UIImage alloc]initWithContentsOfFile:playImageFile];
        [playPauseButton setBackgroundImage:playImage forState:UIControlStateNormal];
    }
    else{
        if(state != NORMAL_STATE)
            [self changeStateToNormal:true];
        [grid play];
        UIImage *pauseImage = [[UIImage alloc]initWithContentsOfFile:pauseImageFile];
        [playPauseButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
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

- (IBAction)editPathEvent:(id)sender
{
    if(state == PATH_EDIT_STATE)
        [self changeStateToNormal:true];
    else
    {
        [self changeStateToNormal:true];
        UIImage *doneImage = [[UIImage alloc]initWithContentsOfFile:doneImageFile];
        [editPathBtn setBackgroundImage:doneImage forState:UIControlStateNormal];
        //[editPathBtn setTitle:pathEditBtnText forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
        if(!pathList)
        {
            pathList = [[PathListController alloc]initWithNibName:@"PathListController" bundle:nil];
            [pathList setPathView:[grid pathView]];
            [pathList setMainViewController:self];
            pathListPopover = [[UIPopoverController alloc]initWithContentViewController:pathList];
            [pathListPopover setDelegate:pathList];
        }
        CGSize popoverSize = CGSizeMake(240, 300);
        [pathList.pathPicker reloadData];
        pathListPopover.popoverContentSize = popoverSize;
        [pathListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    }
}

- (void)pathHasBeenSelected
{
    if(pathListPopover)
        [pathListPopover dismissPopoverAnimated:true];
}

- (void)changeStateToNormal:(bool)informGrid
{
    if(state == PATH_EDIT_STATE){
        //[editPathBtn setTitle:normalPathBtnText forState:UIControlStateNormal];
        UIImage *pathsImage = [[UIImage alloc]initWithContentsOfFile:pathsImageFile];
        [editPathBtn setBackgroundImage:pathsImage forState:UIControlStateNormal];
    }
    if(informGrid)
        [grid changeToNormalState];
    state = NORMAL_STATE;
}

- (IBAction)saveLoadEvent:(id)sender
{
    if(!projectList)
    {
        projectList = [[ProjectList alloc]initWithNibName:@"ProjectList" bundle:nil];
        [projectList setViewController:self];
        projectListPopover = [[UIPopoverController alloc]initWithContentViewController:projectList];
        [projectList setPopover:projectListPopover];
        //[projectListPopover setDelegate:projectList];
    }
    CGSize popoverSize = CGSizeMake(220, 300);
    projectListPopover.popoverContentSize = popoverSize;
    [projectListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
}

- (void)newGrid
{
    [gridProjects newGrid];
    [grid reset];
}

- (void)setPlayStateToStopped
{
    UIImage *playImage = [[UIImage alloc]initWithContentsOfFile:playImageFile];
    [playPauseButton setBackgroundImage:playImage forState:UIControlStateNormal];
    [grid playbackHasStopped];
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    tempoTextField.text = [NSString stringWithFormat:@"%d BPM", (int)[sender value]]; 
    tempo = 60/[sender value];
    
    [grid setSpeed:tempo];
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
    normalPathBtnText = [[editPathBtn titleLabel] text];
    pauseImageFile = [[NSBundle mainBundle]pathForResource:@"pauseButton2" ofType:@"png"];
    playImageFile = [[NSBundle mainBundle]pathForResource:@"playButton2" ofType:@"png"];
    doneImageFile = [[NSBundle mainBundle]pathForResource:@"doneButton" ofType:@"png"];
    pathsImageFile = [[NSBundle mainBundle]pathForResource:@"pathsButton" ofType:@"png"];
    gridProjects = [[GridProjects alloc]init];
    //[self loadGridFromFile:@"goodGrid"]; //TODO: delete this
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
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) return YES;
    return NO;
}

@end
