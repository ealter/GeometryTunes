#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "ViewController.h"
#import "NotePlayer.h"
#import "PathsView.h"
#import "Piano.h"
#import "PathListController.h"
#import <QuartzCore/QuartzCore.h>

#define NUM_BOXES_X_INITIAL 8
#define NUM_BOXES_Y_INITIAL 10

#define DEFAULT_DURATION 1

@interface GridView ()

- (void)sharedInit;
- (void)initCells;
- (void)allocateCells;
- (void)drawGrid;
- (void)convertCellBorderColors:(CGColorRef)color;

@end

@implementation GridView

@synthesize numBoxes;
@synthesize currentCell;
@synthesize tapGestureRecognizer, swipeGestureRecognizer;
@synthesize delegate, pathView;

#define CELL_BORDER_COLOR [[UIColor grayColor] CGColor]
#define CELL_BORDER_COLOR_WHILE_PLAYING [[UIColor clearColor] CGColor]

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

- (void)draw
{
    [self drawGrid];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
}

- (void)changeCell:(GridCell *)cell isBold:(bool)isBold
{
    assert(cell);
    if(isBold)
    {
        [cell.layer setBorderWidth:8];
        [cell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    }
    else
    {
        [cell.layer setBorderWidth:2];
        if([pathView isPlaying])
            [cell.layer setBorderColor:CELL_BORDER_COLOR_WHILE_PLAYING];
        else
            [cell.layer setBorderColor:CELL_BORDER_COLOR];
    }
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
        [self allocateCells];
        [self initCells];
        pathView = [[PathsView alloc]initWithFrame:[self bounds]];
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
    for(int i=0; i<numBoxes.x; i++)
    {
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
            [self changeCell:cell isBold:false];
            [cell.layer setCornerRadius:6.0f];
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
    swipeGestureRecognizer.numberOfTouchesRequired = 1; //TODO: maybe change to 2?
    
    [self addGestureRecognizer:tapGestureRecognizer];
    [self addGestureRecognizer:swipeGestureRecognizer];
}

- (void)reset
{
    for(NSMutableArray *row in cells) {
        for(int j=0; j<numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [cell clearNotes];
        }
    }
    [pathView reset];
    [self setNeedsDisplay];
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
            [self addSubview:piano];
            break;
            
        case PIANO_STATE:
            if(!CGRectContainsPoint([piano frame], pos))
            {
                [self changeCell:[self cellAtPos:currentCell] isBold:false];
                currentCell = box;
                [self changeCell:[self cellAtPos:currentCell] isBold:true];
                [self playNoteForDuration:DEFAULT_DURATION];
                [piano gridCellHasChanged];
            }
            
            break;
        case PATH_EDIT_STATE:
            //CGPoint point = CGPointMake((box.x + 0.5) * [self boxWidth], (box.y + 0.5) * [self boxHeight]); //Snap to center
            assert(pathView);
            if([[delegate pathList] pathEditStateIsAdding])
                [pathView addNoteWithPos:pos];
            else
                [pathView removeNoteWithPos:pos];
            break;
        default:
            assert(0); //Unknown state!
    }
}

-  (void) handleSwipe:(UIGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([self state] == PIANO_STATE)
    {
        if(!CGRectContainsPoint([piano frame], pos))
            [self changeToNormalState];
    }
}

- (void)addNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave <= MAX_OCTAVE && octave >= MIN_OCTAVE);
    GridCell *cell = [self cellAtPos:currentCell];
    midinote note = pitch + octave * NOTES_IN_OCTAVE;
    [cell addNote:note];
}

- (void)removeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave <= MAX_OCTAVE && octave >= MIN_OCTAVE);
    midinote note = pitch + octave * NOTES_IN_OCTAVE;
    GridCell *cell = [self cellAtPos:currentCell];
    [cell removeNote:note];
}

- (void)updateDisplayAtCurrentCell
{
    [[self cellAtPos:currentCell] setNeedsDisplay];
}

- (void)clearNoteForCell:(CellPos)cellPos
{
    [[self cellAtPos:cellPos] clearNotes];
}

- (void)clearNote
{
    [self clearNoteForCell:currentCell];
}

- (void)playNoteForDuration:(NSTimeInterval)duration
{
    [self playNoteForCell:currentCell duration:duration];
}

- (void)playNoteForCell:(CellPos)cellPos duration:(NSTimeInterval)duration
{
    NSMutableArray *notes = [[self cellAtPos:cellPos] notes];
    for(NSNumber *n in notes)
    {
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
    [delegate setPlayStateToStopped];
    [self convertCellBorderColors:CELL_BORDER_COLOR];
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

- (CellPos) getBoxFromCoords:(CGPoint)pos 
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

- (NSMutableArray*)notesAtCell:(CellPos)cellPos
{
    return [[self cellAtPos:cellPos] notes];
}

- (NSMutableArray*)notes
{
    return [self notesAtCell:currentCell];
}

- (void)setSpeed:(NSTimeInterval)speed
{
    [pathView setSpeed:speed];
}

+ (CellPos)cellPosMakeX:(unsigned int)x y:(unsigned int)y
{
    CellPos pos = {x,y};
    return pos;
}

@end
