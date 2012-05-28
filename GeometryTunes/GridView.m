#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "NotePlayer.h"
#import "PathsView.h"
#import "Piano.h"
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

@synthesize numBoxes = _numBoxes;
@synthesize currentCell = _currentCell;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize swipeGestureRecognizer = _swipeGestureRecognizer;
@synthesize viewController = _viewController;
@synthesize pathView = _pathView;

#define CELL_BORDER_COLOR [[UIColor grayColor] CGColor]
#define CELL_BORDER_COLOR_WHILE_PLAYING [[UIColor clearColor] CGColor]

- (GridCell*)cellAtPos:(CellPos)cellPos
{
    return [[cells objectAtIndex:cellPos.x] objectAtIndex:cellPos.y];
}

- (STATE)state
{
    assert(self.viewController);
    return [self.viewController state];
}

- (void)setState:(STATE)state
{
    if(self.viewController.state == PATH_EDIT_STATE)
        [self.pathView setNeedsDisplay]; //Since the current path is dotted
    if(self.viewController)
        self.viewController.state = state;
}

- (void)draw
{
    [self drawGrid];
    [self addSubview:self.pathView];
}

- (void)setIsBold:(BOOL)isBold cell:(GridCell *)cell
{
    assert(cell);
    if(isBold) {
        cell.layer.borderWidth = 8;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else {
        cell.layer.borderWidth = 2;
        if(self.pathView.isPlaying)
            cell.layer.borderColor = CELL_BORDER_COLOR_WHILE_PLAYING;
        else
            cell.layer.borderColor = CELL_BORDER_COLOR;
    }
}

- (void)changeToNormalState
{
    STATE oldState = [self state];
    if(oldState == PIANO_STATE)
        [piano removeFromSuperview];
    [self.viewController changeStateToNormal:false];
    self.state = NORMAL_STATE;
    [self setIsBold:FALSE cell:[self cellAtPos:self.currentCell]];
    if(oldState == PATH_EDIT_STATE)
        [self.pathView setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        [self allocateCells];
        [self initCells];
        _pathView = [[PathsView alloc]initWithFrame:[self bounds]]; //maybe wrong?
        [self.pathView setGrid:self];
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
        [self.pathView removeFromSuperview];
        _pathView = [aDecoder decodeObjectForKey:PATHVIEW_ENCODE_KEY];
        if(!self.pathView)
            _pathView = [[PathsView alloc]initWithFrame:[self bounds]];
        self.pathView.grid = self;
        [self draw];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pathView forKey:PATHVIEW_ENCODE_KEY];
    [aCoder encodeObject:cells forKey:CELLS_ENCODE_KEY];
}

- (void)allocateCells
{
    cells = [[NSMutableArray alloc] initWithCapacity:self.numBoxes.y];
    NSMutableArray *row;
    
    float boxWidth = [self boxWidth];
    float boxHeight = [self boxHeight];
    for(int i=0; i<self.numBoxes.x; i++) {
        row = [[NSMutableArray alloc] initWithCapacity:self.numBoxes.x];
        for(int j=0; j<self.numBoxes.y; j++) {
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
        for(int j=0; j<self.numBoxes.y; j++) {
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
    
    self.numBoxes = [GridView cellPosMakeX:NUM_BOXES_X_INITIAL y:NUM_BOXES_Y_INITIAL];

    [self setState:NORMAL_STATE];
    piano = NULL;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    self.swipeGestureRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.swipeGestureRecognizer];
}

- (void)reset
{
    [self stopPlayback];
    for(NSMutableArray *row in cells) {
        for(int j=0; j<self.numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [cell clearNotes];
        }
    }
    [self.pathView reset];
    [self changeToNormalState];
    [self setNeedsDisplay];
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    CellPos box = [self getBoxFromCoords:pos];
    assert(box.x >= 0 && box.x < self.numBoxes.x);
    assert(box.y >= 0 && box.y < self.numBoxes.y);
    switch([self state]) {
        case NORMAL_STATE:
            [self setState:PIANO_STATE];
             box = [self getBoxFromCoords:pos];
            
            _currentCell = box;
            [self playCurrentCellForDuration:DEFAULT_DURATION];
            
            [self setIsBold:TRUE cell:[self cellAtPos:self.currentCell]];
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
                [self setIsBold:FALSE cell:[self cellAtPos:self.currentCell]];
                _currentCell = box;
                [self setIsBold:TRUE  cell:[self cellAtPos:self.currentCell]];
                [self playCurrentCellForDuration:DEFAULT_DURATION];
                [piano gridCellHasChanged];
            }
            break;
        case PATH_EDIT_STATE:
            //CGPoint point = CGPointMake((box.x + 0.5) * [self boxWidth], (box.y + 0.5) * [self boxHeight]); //Snap to center
            assert(self.pathView);
            [self.viewController projectHasChanged];
            if([self.viewController pathEditStateIsAdding])
                [self.pathView addNoteWithPos:pos];
            else
                [self.pathView removeNoteWithPos:pos];
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
    GridCell *cell = [self cellAtPos:self.currentCell];
    midinote note = [noteTypes midinoteOfPitch:pitch octave:octave];
    [cell addNote:note];
    [self.viewController projectHasChanged];
}

- (void)removeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    GridCell *cell = [self cellAtPos:self.currentCell];
    midinote note = [noteTypes midinoteOfPitch:pitch octave:octave];
    [cell removeNote:note];
    [self.viewController projectHasChanged];
}

- (void)clearNote
{
    [[self cellAtPos:self.currentCell] clearNotes];
    [self.viewController projectHasChanged];
}

- (void)playCurrentCellForDuration:(NSTimeInterval)duration
{
    [self playCell:self.currentCell duration:duration];
}

- (void)playCell:(CellPos)cellPos duration:(NSTimeInterval)duration
{
    NSMutableArray *notes = [[self cellAtPos:cellPos] notes];
    for(NSNumber *n in notes) {
        midinote note = [n unsignedIntValue];
        [NotePlayer playNoteWithPitch: note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE duration:duration]; // Get duration from cell at cellPos
    }
}

- (float)boxWidth
{
    return [self bounds].size.width / self.numBoxes.x;
}

- (float)boxHeight
{
    return [self bounds].size.height / self.numBoxes.y;
}

- (void)drawGrid
{
    for (int y = 0; y < self.numBoxes.y; y++) {
        for (int x = 0; x < self.numBoxes.x; x++) {
            GridCell *cell = [self cellAtPos:[GridView cellPosMakeX:x y:y]];
            [self addSubview:cell];
        }
    }
}

-(void)convertCellBorderColors:(CGColorRef)color
{
    for(NSMutableArray *row in cells) {
        for(int j=0; j<self.numBoxes.y; j++) {
            GridCell *cell = [row objectAtIndex:j];
            [[cell layer] setBorderColor:color];
        }
    }
}

-(void) pausePlayback
{
    [self.pathView pause];
    [self convertCellBorderColors:CELL_BORDER_COLOR];
}

-(void) stopPlayback
{
    [self.pathView stop];
    [self.viewController setPlayStateToStopped];
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
    assert(box.x <= self.numBoxes.x || box.y <= self.numBoxes.y);
    return box;
}

- (void)play
{
    [self.pathView setGrid:self];
    [self convertCellBorderColors:CELL_BORDER_COLOR_WHILE_PLAYING];
    [self.pathView play];
}

- (void)playbackHasStopped
{
    [self convertCellBorderColors:CELL_BORDER_COLOR];
}

- (NSArray*)notes
{
    return [[self cellAtPos:self.currentCell] notes];
}

- (void)setSpeed:(NSTimeInterval)speed
{
    if(speed != [self.pathView speed])
        [self.viewController projectHasChanged];
    [self.pathView setSpeed:speed];
}

+ (CellPos)cellPosMakeX:(unsigned int)x y:(unsigned int)y
{
    CellPos pos = {x,y};
    return pos;
}

@end
