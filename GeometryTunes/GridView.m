#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "NotePlayer.h"
#import "PathsView.h"
#import "Piano.h"
#import "PathListController.h"
#import <QuartzCore/QuartzCore.h>

#define NUM_BOXES_X_INITIAL 8
#define NUM_BOXES_Y_INITIAL 10

#define DEFAULT_DURATION 1

@interface GridView () {
    @private
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row (also an NSMutableArray)
                           //          2nd index is col
}

@property (nonatomic) CellPos numBoxes; /* The number of cells on the grid */
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

+ (CellPos)cellPosMakeX:(unsigned)x y:(unsigned) y;

- (void)sharedInit;
- (void)allocateCells; /* Allocates the 2D array of cells */
- (void)initCells;     /* Resets the content and initializes the 2D array of cells */
- (void)drawGrid;
- (void)draw; /* The equivalent of drawRect (except it only adds subviews, instead of actually drawing) */
- (void)convertCellBorderColors:(CGColorRef)color;

/* Note: The variable for the state is stored in the ViewController */
- (void)setState:(STATE)state;

@end

@implementation GridView

@synthesize numBoxes;
@synthesize currentCell;
@synthesize tapGestureRecognizer, swipeGestureRecognizer;
@synthesize viewController, pathView;

#define CELL_BORDER_COLOR [[UIColor grayColor] CGColor]
#define CELL_BORDER_COLOR_WHILE_PLAYING [[UIColor clearColor] CGColor]

- (GridCell*)cellAtPos:(CellPos)cellPos
{
    return [[cells objectAtIndex:cellPos.x] objectAtIndex:cellPos.y];
}

- (STATE)state
{
    assert(viewController);
    return [viewController state];
}

- (void)setState:(STATE)state
{
    if([viewController state] == PATH_EDIT_STATE)
        [pathView setNeedsDisplay]; //Since the current path is dotted
    if(viewController)
        [viewController setState:state];
}

- (void)draw
{
    [self drawGrid];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
}

- (void)setIsBold:(BOOL)isBold cell:(GridCell *)cell
{
    assert(cell);
    if(isBold) {
        [cell.layer setBorderWidth:8];
        [cell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    }
    else {
        [cell.layer setBorderWidth:2];
        if([pathView isPlaying])
            [cell.layer setBorderColor:CELL_BORDER_COLOR_WHILE_PLAYING];
        else
            [cell.layer setBorderColor:CELL_BORDER_COLOR];
    }
}

- (void)changeToNormalState
{
    STATE oldState = [self state];
    if(oldState == PIANO_STATE)
        [piano removeFromSuperview];
    [viewController changeStateToNormal:false];
    [self setState:NORMAL_STATE];
    [self setIsBold:FALSE cell:[self cellAtPos:currentCell]];
    if(oldState == PATH_EDIT_STATE)
        [pathView setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        [self allocateCells];
        [self initCells];
        pathView = [[PathsView alloc]initWithFrame:[self bounds]];
        [pathView setGrid:self];
        [self draw];
    }
    return self;
}

#define PATHVIEW_ENCODE_KEY @"pathView"
#define CELLS_ENCODE_KEY @"cells"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
        cells = [aDecoder decodeObjectForKey:CELLS_ENCODE_KEY];
        if(!cells)
            [self allocateCells];
        [self initCells];
        [pathView removeFromSuperview];
        pathView = [aDecoder decodeObjectForKey:PATHVIEW_ENCODE_KEY];
        if(!pathView)
            pathView = [[PathsView alloc]initWithFrame:[self bounds]];
        [pathView setGrid:self];
        [self draw];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:pathView forKey:PATHVIEW_ENCODE_KEY];
    [aCoder encodeObject:cells forKey:CELLS_ENCODE_KEY];
}

- (void)allocateCells
{
    cells = [[NSMutableArray alloc] initWithCapacity:numBoxes.y];
    NSMutableArray *row;
    
    float boxWidth = [self boxWidth];
    float boxHeight = [self boxHeight];
    for(int i=0; i<numBoxes.x; i++) {
        row = [[NSMutableArray alloc] initWithCapacity:numBoxes.x];
        for(int j=0; j<numBoxes.y; j++) {
            CGRect cellBounds = CGRectMake(i * boxWidth, j * boxHeight, boxWidth, boxHeight);
            GridCell *cell = [[GridCell alloc]initWithFrame:cellBounds];
            [row addObject:cell];
        }
        [cells addObject:row];
    }
}

- (void)initCells
{
    for(NSMutableArray *row in cells) {
        for(int j=0; j<numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [[cell layer] setBorderColor:CELL_BORDER_COLOR];
            [self setIsBold:FALSE cell:cell];
            [row addObject:cell];
        }
    }
}

-(void)sharedInit
{
    [self setBackgroundColor:[UIColor blackColor]];
    
    numBoxes = [GridView cellPosMakeX:NUM_BOXES_X_INITIAL y:NUM_BOXES_Y_INITIAL];

    [self setState:NORMAL_STATE];
    piano = NULL;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [tapGestureRecognizer setCancelsTouchesInView:false];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addGestureRecognizer:swipeGestureRecognizer];
}

- (void)reset
{
    [self stopPlayback];
    for(NSMutableArray *row in cells) {
        for(int j=0; j<numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [cell clearNotes];
        }
    }
    [pathView reset];
    [self changeToNormalState];
    [self setNeedsDisplay];
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    CellPos box = [self getBoxFromCoords:pos];
    assert(box.x >= 0 && box.x < numBoxes.x);
    assert(box.y >= 0 && box.y < numBoxes.y);
    switch([self state]) {
        case NORMAL_STATE:
            [self setState:PIANO_STATE];
             box = [self getBoxFromCoords:pos];
            
            currentCell = box;
            
            [self setIsBold:TRUE cell:[self cellAtPos:currentCell]];
            int pianoHeight = 200; //TODO change to const
            int pianoY = [self bounds].size.height - pianoHeight;
            if((box.y+1) * [self boxHeight] > pianoY) {
                pianoY = 0;
            }
            
            CGRect pianoRect = CGRectMake(0, pianoY, [self bounds].size.width, pianoHeight);
            if(!piano)
                piano = [Piano alloc];
            piano = [piano initWithFrame:pianoRect];
            [piano setGrid:self];
            [self addSubview:piano];
            break;
            
        case PIANO_STATE:
            if(!CGRectContainsPoint([piano frame], pos)) {
                [self setIsBold:FALSE cell:[self cellAtPos:currentCell]];
                currentCell = box;
                [self setIsBold:TRUE  cell:[self cellAtPos:currentCell]];
                [self playCurrentCellForDuration:DEFAULT_DURATION];
                [piano gridCellHasChanged];
            }
            break;
        case PATH_EDIT_STATE:
            //CGPoint point = CGPointMake((box.x + 0.5) * [self boxWidth], (box.y + 0.5) * [self boxHeight]); //Snap to center
            assert(pathView);
            [viewController projectHasChanged];
            if([viewController pathEditStateIsAdding])
                [pathView addNoteWithPos:pos];
            else
                [pathView removeNoteWithPos:pos];
            break;
        default:
            assert(0); //Unknown state!
    }
}

- (void)handleSwipe:(UIGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([self state] == PIANO_STATE) {
        if(!CGRectContainsPoint([piano frame], pos))
            [self changeToNormalState];
    }
}

- (void)addNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    GridCell *cell = [self cellAtPos:currentCell];
    midinote note = [noteTypes midinoteOfPitch:pitch octave:octave];
    [cell addNote:note];
    [viewController projectHasChanged];
}

- (void)removeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    GridCell *cell = [self cellAtPos:currentCell];
    midinote note = [noteTypes midinoteOfPitch:pitch octave:octave];
    [cell removeNote:note];
    [viewController projectHasChanged];
}

- (void)clearNote
{
    [[self cellAtPos:currentCell] clearNotes];
    [viewController projectHasChanged];
}

- (void)playCurrentCellForDuration:(NSTimeInterval)duration
{
    [self playCell:currentCell duration:duration];
}

- (void)playCell:(CellPos)cellPos duration:(NSTimeInterval)duration
{
    NSMutableArray *notes = [[self cellAtPos:cellPos] notes];
    for(NSNumber *n in notes) {
        midinote note = [n unsignedIntValue];
        [NotePlayer playNoteWithPitch: note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE duration:duration];
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
            GridCell *cell = [self cellAtPos:[GridView cellPosMakeX:x y:y]];
            [self addSubview:cell];
        }
    }
}

-(void)convertCellBorderColors:(CGColorRef)color
{
    for(NSMutableArray *row in cells) {
        for(int j=0; j<numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [[cell layer] setBorderColor:color];
            [cell.layer setCornerRadius:6.0f];
        }
    }
}

-(void) pausePlayback
{
    [pathView pause];
    [self convertCellBorderColors:CELL_BORDER_COLOR];
}

-(void) stopPlayback
{
    [pathView stop];
    [viewController setPlayStateToStopped];
    [self convertCellBorderColors:CELL_BORDER_COLOR];
}

-(void) editButtonEvent:(id)sender;
{
    if([self state] == PATH_EDIT_STATE)
        [self changeToNormalState];
    else {
        if([self state] == PIANO_STATE)
            [piano removeFromSuperview];
        [self setState:PATH_EDIT_STATE];
    }
}

- (CellPos)getBoxFromCoords:(CGPoint)pos
{
    CellPos box = [GridView cellPosMakeX:(pos.x / [self boxWidth]) y:(pos.y / [self boxHeight])];
    assert(box.x <= numBoxes.x || box.y <= numBoxes.y);
    return box;
}

- (void)play
{
    [pathView setGrid:self];
    [self convertCellBorderColors:CELL_BORDER_COLOR_WHILE_PLAYING];
    [pathView play];
}

- (void)playbackHasStopped
{
    [self convertCellBorderColors:CELL_BORDER_COLOR];
}

- (NSMutableArray*)notes
{
    return [[self cellAtPos:currentCell] notes];
}

- (void)setSpeed:(NSTimeInterval)speed
{
    if(speed != [pathView speed])
        [viewController projectHasChanged];
    [pathView setSpeed:speed];
}

+ (CellPos)cellPosMakeX:(unsigned int)x y:(unsigned int)y
{
    CellPos pos = {x,y};
    return pos;
}

@end
