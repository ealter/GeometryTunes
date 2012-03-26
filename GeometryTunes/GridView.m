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
    [self setState:NORMAL_STATE];
    ViewController *del = delegate;
    [del changeStateToNormal:false];
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
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([self state] == NORMAL_STATE)
    {
        [self setState:PIANO_STATE];
        CGPoint box = [self getBoxFromCoords:pos];
        assert(box.x >= 0 && box.x < numBoxesX);
        assert(box.y >= 0 && box.y < numBoxesY);
        
        currentX = box.x;
        currentY = box.y;
        int pianoHeight = 200;
        int pianoY = gridHeight - pianoHeight;
        if((box.y+1) * [self getBoxHeight] > pianoY) {
            pianoY = 0;
        }
            
        CGRect pianoRect = CGRectMake(0, pianoY, gridWidth, pianoHeight);
        if (piano)
            piano = [piano initWithFrame:pianoRect delegate:self];
        else
            piano = [[Piano alloc] initWithFrame:pianoRect delegate:self];
        [piano setOctave:pianoOctave];
        [self addSubview:piano];
    }
    else if([self state] == PIANO_STATE)
    {
        if(!CGRectContainsPoint([piano frame], pos))
            [self changeToNormalState];
    }
    else if([self state] == PATH_EDIT_STATE)
    {
        CGPoint box = [self getBoxFromCoords:pos];
        CGPoint point = CGPointMake((box.x + 0.5) * [self getBoxWidth], (box.y + 0.5) * [self getBoxHeight]);
        [pathView addNoteWithPos:point];
        [pathView setNeedsDisplay];
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
    if(playbackTimer)
        [playbackTimer invalidate];
}

- (void)drawRect:(CGRect)rect
{
    // Draw Playback Menu at top of screen
    
    [self drawGrid:UIGraphicsGetCurrentContext()];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
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
    bool *reverse = NULL;//= t.userInfo;
    [t.userInfo getValue:reverse];
    assert(reverse);
    NSMutableArray *points = pathView.path.notes;
    if((reverse && playbackPosition == 0) || playbackPosition == [points count])
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
    if(reverse)playbackPosition--;
    else playbackPosition++;
}

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse
{
    //NSMutableArray *notes = pathView.path.notes;
    //if(reverse) notes = [[notes reverseObjectEnumerator] allObjects];
    
    NSTimeInterval speed = playbackSpeed * factor;
    if(reverse) playbackPosition = [pathView.path.notes count];
    NSValue *reverseObject = [NSValue value:&reverse withObjCType:@encode(bool *)];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(playNote:) userInfo:reverseObject repeats:YES];

}

@end
