#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "ViewController.h"
#import "PathsView.h"
#import <QuartzCore/QuartzCore.h>

#define NUM_BOXES_X_INITIAL 8
#define NUM_BOXES_Y_INITIAL 10

@implementation GridView

@synthesize numBoxes;

@synthesize currentCell;

@synthesize tapGestureRecognizer;
@synthesize tapButtonRecognizer;
@synthesize swipeGestureRecognizer;

@synthesize pianoOctave;
@synthesize delegate;

- (GridCell*)cellAtPos:(CellPos)cellPos
{
    return [[cells objectAtIndex:cellPos.x] objectAtIndex:cellPos.y];
}

- (STATE)state
{
    assert(delegate);
    return [delegate state];
}

- (void)setState:(STATE)state
{
    if(delegate)
        [delegate setState:state];
}

- (void)changeCell:(GridCell *)cell isBold:(bool)isBold
{
    assert(cell);
    float borderWidth;
    if(isBold)
        borderWidth = 8;
    else
        borderWidth = 2;
    [[cell layer] setBorderWidth:borderWidth];
}

- (void)changeToNormalState
{
    if([self state] == PIANO_STATE)
        [piano removeFromSuperview];
    [self setState:NORMAL_STATE];
    [self changeCell:[self cellAtPos:currentCell] isBold:false];
    [delegate changeStateToNormal:false];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

-(void)sharedInit
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    numBoxes = CGPointMake(NUM_BOXES_X_INITIAL, NUM_BOXES_Y_INITIAL);
    
    pianoOctave = INITIAL_PIANO_OCTAVE;
    assert(pianoOctave >= MIN_OCTAVE && pianoOctave <= MAX_OCTAVE);
    [self setState:NORMAL_STATE];
    piano = NULL;
    
    cells = [[NSMutableArray alloc] initWithCapacity:numBoxes.y];
    NSMutableArray *row;
    
    float boxWidth = [self boxWidth];
    float boxHeight = [self boxHeight];
    for(int i=0; i<numBoxes.x; i++)
    {
        row = [[NSMutableArray alloc] initWithCapacity:numBoxes.x];
        for(int j=0; j<numBoxes.y; j++)
        {
            CGRect cellBounds = CGRectMake(i * boxWidth, j * boxHeight, boxWidth, boxHeight);
            GridCell *cell = [[GridCell alloc]initWithFrame:cellBounds];
            [[cell layer] setBorderColor:[[UIColor blackColor] CGColor]];
            [self changeCell:cell isBold:false];
            [row addObject:cell];
        }
        [cells addObject:row];
    }
    
    pathView = [[PathsView alloc]initWithFrame:[self bounds]];
    
    // Initialize tap gesture recognizer
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]; 
    
    // The number of taps in order for gesture to be recognized
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizer.numberOfTouchesRequired = 1; //TODO: maybe change to 2?
    
    // Add gesture recognizer to the view
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addGestureRecognizer:swipeGestureRecognizer];
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    CellPos box = [self getBoxFromCoords:pos];
    assert(box.x >= 0 && box.x < numBoxes.x);
    assert(box.y >= 0 && box.y < numBoxes.y);
    switch([self state])
    {
        case NORMAL_STATE:
            [self setState:PIANO_STATE];
             box = [self getBoxFromCoords:pos];
            
            currentCell = box;
            
            [self changeCell:[self cellAtPos:currentCell] isBold:true];
            int pianoHeight = 200; //TODO change to const
            int pianoY = [self bounds].size.height - pianoHeight;
            if((box.y+1) * [self boxHeight] > pianoY) {
                pianoY = 0;
            }
            
            CGRect pianoRect = CGRectMake(0, pianoY, [self bounds].size.width, pianoHeight);
            if (piano)
                piano = [piano initWithFrame:pianoRect delegate:self];
            else
                piano = [[Piano alloc] initWithFrame:pianoRect delegate:self];
            [piano setOctave:pianoOctave];
            [self addSubview:piano];
            break;
            
        case PIANO_STATE:
            //if(!CGRectContainsPoint([piano frame], pos))
                //[self changeToNormalState];
            
            if(!CGRectContainsPoint([piano frame], pos))
            {
                [self changeCell:[self cellAtPos:currentCell] isBold:false];
                currentCell = box;
                [self changeCell:[self cellAtPos:currentCell] isBold:true];
                [piano gridCellHasChanged];
            }
            
            break;
        case PATH_EDIT_STATE:
            box = [self getBoxFromCoords:pos];
            CGPoint point = CGPointMake((box.x + 0.5) * [self boxWidth], (box.y + 0.5) * [self boxHeight]);
            [pathView addNoteWithPos:point];
            [pathView setNeedsDisplay];
            break;
        default:
            assert(0); //Unknown state!
    }
}

-  (void) handleSwipe:(UIGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if(!CGRectContainsPoint([piano frame], pos))
        [self changeToNormalState];
}

- (void) resetPath 
{
    [pathView removeAllNotes];
}

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave cellPos:(CellPos)cellPos appendNote:(bool)appendNote
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave <= MAX_OCTAVE && octave >= MIN_OCTAVE);
    assert(cellPos.x < numBoxes.x && cellPos.y < numBoxes.y);
    GridCell *cell = [self cellAtPos:cellPos];
    pianoNote note = [noteTypes getPianoNoteOfPitch:pitch Octave:octave];
    if(appendNote)
        [cell addNote:note];
    else
        [cell setLastNote:note];
}

- (void)changeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave appendNote:(bool)appendNote
{
    [self changeNoteWithPitch:pitch octave:octave cellPos:currentCell appendNote:appendNote];
}

- (void)clearNoteForCell:(CellPos)cellPos
{
    [[self cellAtPos:cellPos] clearNotes];
}

- (void)clearNote
{
    [self clearNoteForCell:currentCell];
}

- (void)playNote
{
    [self playNoteForCell:currentCell];
}

- (void)playNoteForCell:(CellPos)cellPos
{
    NSMutableArray *notes = [[self cellAtPos:cellPos] notes];
    for(NSNumber *n in notes)
    {
        pianoNote note = [n unsignedIntValue];
        if(note != NO_PIANO_NOTE)
        {
            [[piano notePlayer] playNoteWithPitch: [noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]];
        }
    }
}

- (float)boxWidth
{
    return [self bounds].size.width / numBoxes.x;
}

- (float)boxHeight
{
    return [self bounds].size.height / numBoxes.y;
}

- (void)drawGrid
{
    for (int y = 0; y < numBoxes.y; y++) {
        for (int x = 0; x < numBoxes.x; x++) {
            GridCell *cell = [self cellAtPos:CGPointMake(x, y)];
            [self addSubview:cell];
        }
    }
}

-(void) playButtonEvent:(id)sender;
{
    [self changeToNormalState];
    [self playPathWithSpeedFactor:1 reversed:FALSE];
}

-(void) pausePlayback
{
    [pathView pause];
}

-(void) stopPlayback
{
    [pathView stop];
    [delegate setPlayStateToStopped];
}

-(void) saveButtonEvent:(id)sender;
{
    // add path and note colors to file
    // save NSMutable array 'pathView.path.notes' to file
    
    /*
    //Code from http://ipgames.wordpress.com/tutorials/writeread-data-to-plist-file/
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //need to create data.plist file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(!([fileManager fileExistsAtPath:path]))
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:path error:&error];
    }
    
    
    //write Data
    NSMutableArray *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    int value = 5 //change to data elements
    [data writeToFile:path atomically:YES];
    [data release]
    */
    NSLog(@"SaveButtonPressed");
}

-(void) loadButtonEvent:(id)sender;
{
    NSLog(@"LoadButtonPressed");
}

-(void) editButtonEvent:(id)sender;
{
    if([self state] == PATH_EDIT_STATE)
        [self changeToNormalState];
    else
    {
        if([self state] == PIANO_STATE)
            [piano removeFromSuperview];
        [self setState:PATH_EDIT_STATE];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawGrid];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
}

- (CellPos) getBoxFromCoords:(CGPoint)pos 
{
    CellPos box = CGPointMake((int)(pos.x / [self boxWidth]), (int)(pos.y / [self boxHeight]));
    if (box.x > numBoxes.x || box.y > numBoxes.y)
        return CGPointMake(-1, -1);
    return box;
}

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse
{
    [pathView.path setDelegateGrid:self];
    if(reverse)
        factor = -factor;
    if(piano) //Note: This assumes that the grid is blank if the piano doesn't exist
        [pathView playWithSpeedFactor:factor notePlayer:[piano notePlayer]];
}

- (NSMutableArray*)notesAtCell:(CellPos)cellPos
{
    return [[self cellAtPos:cellPos] notes];
}

- (NSMutableArray*)notes
{
    return [self notesAtCell:currentCell];
}

@end
