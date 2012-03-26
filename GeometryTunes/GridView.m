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
    
    //Initialize playback features
    /*struct PlaybackFeatures{
        int playSpeed;
        int currentNote;
    };*/
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
        //TODO: change Edit Path button text
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
    CGPoint box = CGPointMake((int)pos.x / [self getBoxWidth], (int)pos.y / [self getBoxHeight]);
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}

- (pianoNote)getNoteFromCoords:(CGPoint)pos
{
    CGPoint box = [self getBoxFromCoords:pos];
    return [[self cellAtX:box.x y:box.y] note];
}


- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse
{
    [pathView.path setDelegateGrid:self];
    if(reverse)
        factor = -factor;
    [pathView playWithSpeedFactor:factor notePlayer:[piano notePlayer]];
}

@end
