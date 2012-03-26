//
//  GridView.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "GridView.h"
#import "GridCell.h"
#import "noteTypes.h"
#import "ViewController.h"

@implementation GridView

@synthesize numBoxesX;
@synthesize numBoxesY; 
@synthesize gridWidth;
@synthesize gridHeight;

@synthesize currentX;
@synthesize currentY;

@synthesize tapGestureRecognizer;
@synthesize tapButtonRecognizer;

@synthesize pianoOctave;
@synthesize delegate;

static NSString* editPathButtonStr = @"Edit Path";
static NSString* finishEditingPathButtonStr = @"Finish";

const static NSTimeInterval playbackSpeed = 1.0;

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

- (void)changeToNormalState
{
    if([self state] == PIANO_STATE)
        [piano removeFromSuperview];
    else if([self state] == PATH_EDIT_STATE)
    {
        //TODO: Change toolbar button text
    }
    [self setState:NORMAL_STATE];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInitWithFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInitWithFrame:[self bounds]];
    }
    return self;
}

-(void)sharedInitWithFrame:(CGRect)frame
{
    [self setBackgroundColor:[UIColor whiteColor]];
    gridWidth = frame.size.width;
    gridHeight = frame.size.height;
    numBoxesX = 8;
    numBoxesY = 10;
    
    pianoOctave = INITIAL_PIANO_OCTAVE;
    assert(pianoOctave >= MIN_OCTAVE && pianoOctave <= MAX_OCTAVE);
    [self setState:NORMAL_STATE];
    piano = NULL;
    
    playbackPosition = 0;
    playbackTimer = nil;
    
    cells = [[NSMutableArray alloc] initWithCapacity:numBoxesY];
    NSMutableArray *row;
    
    for(int i=0; i<numBoxesX; i++)
    {
        row = [[NSMutableArray alloc] initWithCapacity:numBoxesX];
        for(int j=0; j<numBoxesY; j++)
        {
            CGRect cell = CGRectMake(i * [self getBoxWidth], j * [self getBoxHeight], [self getBoxWidth], [self getBoxHeight]);
            [row addObject:[[GridCell alloc]initWithFrame:cell]];
        }
        [cells addObject:row];
    }
    
    pathView = [[PathsView alloc]initWithFrame:frame];
    
    // Initialize tap gesture recognizer
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]; 
    
    // The number of taps in order for gesture to be recognized
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    // Add gesture recognizer to the view
    [self addGestureRecognizer:tapGestureRecognizer];
    NSLog(@"Finished init with frame");
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"Handling tap in state: %d", [self state]);
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([self state] == NORMAL_STATE)
    {
        if(pos.y > [self getBoxHeight]) //Don't handle taps to the toolbar
        {
            [self setState:PIANO_STATE];
            CGPoint box = [self getBoxFromCoords:pos];
            assert(box.x >= 0 && box.x < numBoxesX);
            assert(box.y >= 0 && box.y < numBoxesY);
            
            currentX = box.x;
            currentY = box.y;
            int pianoHeight = 200;
            int pianoY = gridHeight - pianoHeight;
            if((box.y+1) * [self getBoxHeight] > gridHeight - pianoHeight) {
                pianoY = [self getBoxHeight];
            }
                
            CGRect pianoRect = CGRectMake(0, pianoY, gridWidth, pianoHeight);
            if (!piano)
                piano = [[Piano alloc] initWithFrame:pianoRect delegate:self];
            [piano setOctave:pianoOctave];
            [self addSubview:piano];
            NSLog(@"%@", NSStringFromCGPoint(box));
        }
    }
    else if([self state] == PIANO_STATE)
    {
        if(!CGRectContainsPoint([piano frame], pos))
        {
            [self changeToNormalState];
            NSLog(@"Time to remove piano");
        }
        else
            NSLog(@"Don't remove piano");
    }
    else if([self state] == PATH_EDIT_STATE)
    {
        if(pos.y > [self getBoxHeight]) //Don't handle taps to the toolbar
        {
            CGPoint box = [self getBoxFromCoords:pos];
            CGPoint point = CGPointMake((box.x + 0.5) * [self getBoxWidth], (box.y + 0.5) * [self getBoxHeight]);
            [pathView addNoteWithPos:point];
            [pathView setNeedsDisplay];
        }
    }
}

- (void)changeNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    [self changeNoteWithPitch:pitch octave:octave x:currentX y:currentY];
}

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned)x y:(unsigned)y
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave <= MAX_OCTAVE && octave >= MIN_OCTAVE);
    assert(x < numBoxesX && y < numBoxesY);
    GridCell *cell = [self cellAtX:x y:y];
    [cell setNote:[noteTypes getPianoNoteOfPitch:pitch Octave:octave]];
}

- (int)getBoxWidth
{
    return gridWidth / numBoxesX;
}

- (int)getBoxHeight
{
    return gridHeight / numBoxesY;
}

- (void)drawGrid:(CGContextRef)context
{
    for (int y = 1; y < numBoxesY; y++) {
        for (int x = 0; x < numBoxesX; x++) {
            GridCell *cell = [self cellAtX:x y:y];
            [self addSubview:cell];
        }
    }
}

- (void) drawPlaybackMenu:(CGContextRef)context
{
    CGRect playbackBar;
    playbackBar = CGRectMake(0, 0, gridWidth, [self getBoxHeight]);
    [[UIColor blackColor] set];
    UIRectFill(playbackBar);
}

-(void) playButtonEvent:(id)sender;
{
    [self changeToNormalState];
    [self playPathWithSpeed:playbackSpeed];
}

-(void) pauseButtonEvent:(id)sender;
{
    if([self state] == NORMAL_STATE)
    {
        if(playbackTimer)
            [playbackTimer invalidate];
    }
    else
        [self changeToNormalState];
}

-(void) rewButtonEvent:(id)sender;
{
    NSLog(@"RewButtonPressed");
}

-(void) ffButtonEvent:(id)sender;
{
    if(playbackTimer)
        [playbackTimer invalidate];
    if([self state] == NORMAL_STATE)
    {
        [self playPathWithSpeed:playbackSpeed * 0.5];
    }
    else
        [self changeToNormalState];
}

-(void) saveButtonEvent:(id)sender;
{
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
        //TODO: change Edit Path button text
        [self setState:PATH_EDIT_STATE];
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"Drawing rectangle");
    // Draw Playback Menu at top of screen
    CGContextRef playbackContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(playbackContext, 2.0);
    CGContextSetFillColorWithColor(playbackContext, [UIColor blackColor].CGColor);
    
    [self drawGrid:UIGraphicsGetCurrentContext()];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
    [self drawPlaybackMenu:playbackContext];
}

- (CGPoint) getBoxFromCoords:(CGPoint)pos 
{
    CGPoint box = CGPointMake((int)pos.x / [self getBoxWidth], (int)pos.y / [self getBoxHeight]);
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}

- (void)playNote:(NSTimer*)t
{
    NSMutableArray *points = pathView.path.notes;
    if(playbackPosition == [points count])
    {
        playbackPosition = 0;
        [playbackTimer invalidate];
        return;
    }
    CGPoint box = [self getBoxFromCoords:[[points objectAtIndex:playbackPosition] CGPointValue]];
    assert(box.x > 0 && box.y > 0);
    GridCell *cell = [self cellAtX:box.x y:box.y];
    pianoNote note = [cell getNote];
    if(note != NO_PIANO_NOTE)
    {
        assert(piano && piano.notePlayer);
        [piano.notePlayer playNoteWithPitch: [noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]];
    }
    playbackPosition++;
}

- (void)playPathWithSpeed:(NSTimeInterval)speed
{
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
}

@end
