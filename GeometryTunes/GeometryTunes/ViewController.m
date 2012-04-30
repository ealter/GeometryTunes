#import "ViewController.h"
#import "PathsView.h"
#import "PathListController.h"

#define PLAY 0
#define PAUSE 1

@interface ViewController ()

+ (NSString *)getSavedGridsDirectory;
+ (NSString *)getFilePath:(NSString *)filename;

@end

@implementation ViewController

@synthesize state;
@synthesize grid;
@synthesize editPathBtn, playPauseButton, pathModifyType;
@synthesize tempoTextField, tempo;
@synthesize pathList, pathListPopover;
@synthesize projectList, projectListPopover;

//static NSString *playBtnText = @"Play";
//static NSString *pauseBtnText = @"Pause";
static NSString *normalPathBtnText;
static NSString *pathEditBtnText = @"Done";

+ (NSString *)getSavedGridsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Grids"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    return documentsDirectory;
}

#define FILE_EXTENSION @"geotunes"
#define GRID_NAME_KEY  @"filename"
#define GRID_KEY       @"grid"

+ (NSString *)getFilePath:(NSString *)filename
{
    return [[[ViewController getSavedGridsDirectory] stringByAppendingPathComponent:filename] stringByAppendingPathExtension:FILE_EXTENSION];
}

- (void)loadGridFromFile:(NSString *)fileName
{
    NSString *dataPath = [ViewController getFilePath:fileName];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    NSString *gridName = [unarchiver decodeObjectForKey:GRID_NAME_KEY];
    if(gridName == nil) return;
    GridView *_grid = [unarchiver decodeObjectForKey:GRID_KEY];
    if(_grid) {
        [grid removeFromSuperview];
        [self.view addSubview:_grid];
        grid = _grid;
    }
    [unarchiver finishDecoding];
    [grid setDelegate:self];
}

- (void)saveGridToFile:(NSString *)fileName
{
    NSString *dataPath = [ViewController getFilePath:fileName];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:fileName forKey:GRID_NAME_KEY];
    [archiver encodeObject:grid forKey:GRID_KEY];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
}

+ (NSMutableArray *)gridNameList
{
    NSString *documentsDirectory = [self getSavedGridsDirectory];
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableArray *gridNames = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:FILE_EXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [gridNames addObject:[file stringByDeletingPathExtension]];
        }
    }
    
    return gridNames;
}

- (IBAction)playPauseEvent:(id)sender
{
    if(playPauseButton.tag == PLAY){ //]compare:playBtnText]){
        if(state == NORMAL_STATE)
            [grid pausePlayback];
        else
            [self changeStateToNormal:true];
        [self setPlayStateToStopped];
        NSString *playImageFile = [[NSBundle mainBundle]pathForResource:@"playButton" ofType:@"png"];
        UIImage *playImage = [[UIImage alloc]initWithContentsOfFile:playImageFile];
        [playPauseButton setBackgroundImage:playImage forState:UIControlStateNormal];
        [playPauseButton setTag:PAUSE];
    }
    else{
        if(state != NORMAL_STATE)
            [self changeStateToNormal:true];
        [grid play];
        NSString *pauseImageFile = [[NSBundle mainBundle]pathForResource:@"pauseButton" ofType:@"png"];
        UIImage *pauseImage = [[UIImage alloc]initWithContentsOfFile:pauseImageFile];
        [playPauseButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [playPauseButton setTag:PLAY];
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
        [editPathBtn setTitle:pathEditBtnText forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
        if(!pathList)
        {
            pathList = [[PathListController alloc]initWithNibName:@"PathListController" bundle:nil];
            [pathList setPathView:[grid pathView]];
            [pathList setMainViewController:self];
            pathListPopover = [[UIPopoverController alloc]initWithContentViewController:pathList];
            [pathListPopover setDelegate:pathList];
        }
        CGSize popoverSize = CGSizeMake(200, 300);
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
    if(state == PATH_EDIT_STATE)
        [editPathBtn setTitle:normalPathBtnText forState:UIControlStateNormal];
    if(informGrid)
        [grid changeToNormalState];
    state = NORMAL_STATE;
}

- (void)saveLoadEvent:(id)sender
{
    if(!projectList)
    {
        projectList = [[ProjectList alloc]initWithNibName:@"ProjectList" bundle:nil];
        projectListPopover = [[UIPopoverController alloc]initWithContentViewController:projectList];
        //[projectListPopover setDelegate:projectList];
        
    }
    CGSize popoverSize = CGSizeMake(200, 300);
    projectListPopover.popoverContentSize = popoverSize;
    [projectListPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    
}

- (void)setPlayStateToStopped
{
    NSString *playImageFile = [[NSBundle mainBundle]pathForResource:@"playButton" ofType:@"png"];
    UIImage *playImage = [[UIImage alloc]initWithContentsOfFile:playImageFile];
    [playPauseButton setBackgroundImage:playImage forState:UIControlStateNormal];
    [playPauseButton setTag:PAUSE];
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    tempoTextField.text = [NSString stringWithFormat:@"%.1f BPM", [sender value]]; 
    tempo = 60/[sender value];
    
    if(playPauseButton.tag == PLAY){ //If playing
        [grid setSpeed:tempo];
    }
}

- (BOOL)pathEditStateIsAdding
{
    return [pathModifyType selectedSegmentIndex] == 0;
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
