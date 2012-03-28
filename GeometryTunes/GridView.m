#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "ViewController.h"

#define NUM_BOXES_X_INITIAL 8
#define NUM_BOXES_Y_INITIAL 10

@implementation GridView

@synthesize numBoxesX;
@synthesize numBoxesY;

@synthesize currentX;
@synthesize currentY;

@synthesize tapGestureRecognizer;
@synthesize tapButtonRecognizer;

@synthesize pianoOctave;
@synthesize delegate;

- (GridCell*)cellAtX:(unsigned)x y:(unsigned)y
{
    return [[cells objectAtIndex:x] objectAtIndex:y];
}

- (STATE)state
{
    ViewController *del = delegate;
    assert(del);
    return del.state;
}

- (void)setState:(STATE)state
{
    ViewController *del = delegate;
    if(del)
    {
        [del setState:state];
        del.state = state;
    }
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
    [self changeCell:[self cellAtX:currentX y:currentY] isBold:false];
    ViewController *del = delegate;
    [del changeStateToNormal:false];
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
    
    numBoxesX = NUM_BOXES_X_INITIAL;
    numBoxesY = NUM_BOXES_Y_INITIAL;
    
    pianoOctave = INITIAL_PIANO_OCTAVE;
    assert(pianoOctave >= MIN_OCTAVE && pianoOctave <= MAX_OCTAVE);
    [self setState:NORMAL_STATE];
    piano = NULL;
    
    cells = [[NSMutableArray alloc] initWithCapacity:numBoxesY];
    NSMutableArray *row;
    
    float boxWidth = [self getBoxWidth];
    float boxHeight = [self getBoxHeight];
    for(int i=0; i<numBoxesX; i++)
    {
        row = [[NSMutableArray alloc] initWithCapacity:numBoxesX];
        for(int j=0; j<numBoxesY; j++)
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
    
    // Add gesture recognizer to the view
    [self addGestureRecognizer:tapGestureRecognizer];
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    CGPoint box = [self getBoxFromCoords:pos];
    assert(box.x >= 0 && box.x < numBoxesX);
    assert(box.y >= 0 && box.y < numBoxesY);
    switch([self state])
    {
        case NORMAL_STATE:
            [self setState:PIANO_STATE];
             box = [self getBoxFromCoords:pos];
            
            currentX = box.x;
            currentY = box.y;
            
            [self changeCell:[self cellAtX:currentX y:currentY] isBold:true];
            int pianoHeight = 200; //TODO change to const
            int pianoY = [self bounds].size.height - pianoHeight;
            if((box.y+1) * [self getBoxHeight] > pianoY) {
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
            [self changeCell:[self cellAtX:currentX y:currentY] isBold:false];
            
            if(!CGRectContainsPoint([piano frame], pos))
            {
                currentX = box.x;
                currentY = box.y;
                [self changeCell:[self cellAtX:currentX y:currentY] isBold:true];
            }
            
            break;
        case PATH_EDIT_STATE:
            box = [self getBoxFromCoords:pos];
            CGPoint point = CGPointMake((box.x + 0.5) * [self getBoxWidth], (box.y + 0.5) * [self getBoxHeight]);
            [pathView addNoteWithPos:point];
            [pathView setNeedsDisplay];
            break;
        default:
            assert(0); //Unknown state!
    }
}

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned)x y:(unsigned)y appendNote:(bool)appendNote
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave <= MAX_OCTAVE && octave >= MIN_OCTAVE);
    assert(x < numBoxesX && y < numBoxesY);
    GridCell *cell = [self cellAtX:x y:y];
    pianoNote note = [noteTypes getPianoNoteOfPitch:pitch Octave:octave];
    if(appendNote)
        [cell addNote:note];
    else
        [cell setLastNote:note];
}

- (void)changeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave appendNote:(bool)appendNote
{
    [self changeNoteWithPitch:pitch octave:octave x:currentX y:currentY appendNote:appendNote];
}

- (void)clearNoteAtX:(unsigned int)x y:(unsigned int)y
{
    [[self cellAtX:x y:y] clearNotes];
}

- (void)clearNote
{
    [self clearNoteAtX:currentX y:currentY];
}

- (float)getBoxWidth
{
    return [self bounds].size.width / numBoxesX;
}

- (float)getBoxHeight
{
    return [self bounds].size.height / numBoxesY;
}

- (void)drawGrid:(CGContextRef)context
{
    for (int y = 0; y < numBoxesY; y++) {
        for (int x = 0; x < numBoxesX; x++) {
            GridCell *cell = [self cellAtX:x y:y];
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
    [self drawGrid:UIGraphicsGetCurrentContext()];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
}

- (CGPoint) getBoxFromCoords:(CGPoint)pos 
{
    CGPoint box = CGPointMake((int)(pos.x / [self getBoxWidth]), (int)(pos.y / [self getBoxHeight]));
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}

- (NSMutableArray*)getNotesFromCoords:(CGPoint)pos
{
    CGPoint box = [self getBoxFromCoords:pos];
    return [[self cellAtX:box.x y:box.y] notes];
}

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse
{
    [pathView.path setDelegateGrid:self];
    if(reverse)
        factor = -factor;
    if(piano) //Note: This assumes that the grid is blank if the piano doesn't exist
        [pathView playWithSpeedFactor:factor notePlayer:[piano notePlayer]];
}

@end
