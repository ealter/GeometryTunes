#import "ViewController.h"
#import "PathsView.h"
#import "GridView.h"
#import "PathListController.h"
#import "GridProjects.h"
#import "ProjectList.h"
#import "AppDelegate.h" //TODO: delete this
#import "MidiController.h" //TODO delete this

@interface ViewController ()

@property (nonatomic, copy) NSString *playImageFile;
@property (nonatomic, copy) NSString *pauseImageFile;
@property (nonatomic, copy) NSString *pathsImageFile;
@property (nonatomic, copy) NSString *doneImageFile;

@property (nonatomic, retain) IBOutlet UIButton *editPathBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel  *tempoTextField;
@property (nonatomic, retain) IBOutlet UISlider *tempoSlider;
@property (nonatomic, retain) IBOutlet UILabel  *fileNameLabel;

@property (strong, nonatomic) PathListController *pathList;
@property (strong, nonatomic) UIPopoverController *pathListPopover;
@property (strong, nonatomic) ProjectList *projectList;
@property (strong, nonatomic) UIPopoverController *projectListPopover;

@property (nonatomic, retain, readonly) GridProjects *gridProjects;

/* Event handlers */
- (IBAction)playPauseEvent:(id)sender;
- (IBAction)stopEvent:(id)sender; /* Fired by the view when the user clicks the stop button */
- (IBAction)tempoChanged:(id)sender;
- (IBAction)editPathEvent:(id)sender;

@end

@implementation ViewController

@synthesize state;
@synthesize grid, gridProjects, hasUnsavedChanges;
@synthesize editPathBtn, playPauseButton;
@synthesize tempoTextField, tempo, tempoSlider;
@synthesize fileNameLabel;
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

- (void)refreshFileName
{
    NSString *filename = [self currentFileName];
    const NSString *prefix = @"Editing ";
    if(filename)
        fileNameLabel.text = [prefix stringByAppendingString:filename];
    else
        fileNameLabel.text = [prefix stringByAppendingString:@"Untitled Project"];
}

- (void)loadGridFromFile:(NSString *)fileName
{
    [grid stopPlayback];
    GridView *_grid = [gridProjects loadGridFromFile:fileName viewController:self];
    if(_grid) {
        [grid changeToNormalState];
        [grid removeFromSuperview];
        [self.view addSubview:_grid];
        grid = _grid;
    }
    [grid setViewController:self];
    [grid setSpeed:tempo];
    [pathList setPathView:[grid pathView]];
    [self refreshFileName];
    hasUnsavedChanges = FALSE;
}

- (BOOL)saveGridToFile:(NSString *)fileName
{
    BOOL success = [gridProjects saveToFile:fileName grid:grid tempo:tempo];
    [self refreshFileName];
    if(success)
        hasUnsavedChanges = FALSE;
    return success;
}

- (IBAction)playPauseEvent:(id)sender
{
    if([grid.pathView isPlaying]) {
        if(state != NORMAL_STATE)
            [self changeStateToNormal:true];
        [grid pausePlayback];
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
    else {
        [self changeStateToNormal:true];
        UIImage *doneImage = [[UIImage alloc]initWithContentsOfFile:doneImageFile];
        [editPathBtn setBackgroundImage:doneImage forState:UIControlStateNormal];
        //[editPathBtn setTitle:pathEditBtnText forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
        if(!pathList) {
            pathList = [[PathListController alloc]initWithNibName:@"PathListController" bundle:nil];
            [pathList setPathView:[grid pathView]];
            [pathList setMainViewController:self];
            pathListPopover = [[UIPopoverController alloc]initWithContentViewController:pathList];
            [pathListPopover setDelegate:pathList];
        }
        CGSize popoverSize = CGSizeMake(240, 300);
        [pathList refresh];
        pathListPopover.popoverContentSize = popoverSize;
        [pathListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    }
}

- (void)pathHasBeenSelected
{
    if(pathListPopover)
        [pathListPopover dismissPopoverAnimated:true];
}

- (BOOL)pathEditStateIsAdding
{
    return [pathList pathEditStateIsAdding];
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
    if(!projectList) {
        projectList = [[ProjectList alloc]initWithNibName:@"ProjectList" bundle:nil];
        [projectList setViewController:self];
        projectListPopover = [[UIPopoverController alloc]initWithContentViewController:projectList];
        [projectList setPopover:projectListPopover];
    }
    CGSize popoverSize = CGSizeMake(220, 300);
    projectListPopover.popoverContentSize = popoverSize;
    [projectListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
}

- (void)newGrid
{
    [gridProjects newGrid];
    [grid reset];
    [self refreshFileName];
    hasUnsavedChanges = FALSE;
}

- (void)projectHasChanged
{
    hasUnsavedChanges = TRUE;
}

- (void)setPlayStateToStopped
{
    UIImage *playImage = [[UIImage alloc]initWithContentsOfFile:playImageFile];
    [playPauseButton setBackgroundImage:playImage forState:UIControlStateNormal];
    [grid playbackHasStopped];
}

- (void)setTempo:(NSTimeInterval)_tempo
{
    tempo = _tempo;
    float bpm = 60/tempo;
    tempoTextField.text = [NSString stringWithFormat:@"%d BPM", (int)bpm];
    [tempoSlider setValue:bpm];
    [grid setSpeed:tempo];
}

- (IBAction)tempoChanged:(UISlider *)sender {
    [self setTempo:60/[sender value]];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    
    // If object initialization fails, return immediately.
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tempo = 1;
    state = NORMAL_STATE;
    [grid setViewController:self];
    normalPathBtnText = [[editPathBtn titleLabel] text];
    pauseImageFile = [[NSBundle mainBundle]pathForResource:@"pauseButton2" ofType:@"png"];
    playImageFile =  [[NSBundle mainBundle]pathForResource:@"playButton2"  ofType:@"png"];
    doneImageFile =  [[NSBundle mainBundle]pathForResource:@"doneButton"   ofType:@"png"];
    pathsImageFile = [[NSBundle mainBundle]pathForResource:@"pathsButton"  ofType:@"png"];
    gridProjects = [[GridProjects alloc]init];
    [self refreshFileName];
    hasUnsavedChanges = FALSE;
    if(!MIDI_PIANO) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.midi initAfterViewLoad];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) return YES;
    return NO;
}

@end
