//
//  GridView.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "GridView.h"
#import "GridCell.h"

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
@synthesize state;

- (GridCell*)cellAtX:(unsigned)x y:(unsigned)y
{
    return [[cells objectAtIndex:x] objectAtIndex:y];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

-(id)sharedInit
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    gridWidth = screenRect.size.width;
    gridHeight = screenRect.size.height;
    numBoxesX = 8;
    numBoxesY = 10;
    
    pianoOctave = INITIAL_PIANO_OCTAVE;
    assert(pianoOctave >= MIN_OCTAVE && pianoOctave <= MAX_OCTAVE);
    state = NORMAL_STATE;
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
    
    pathView = [[PathsView alloc]initWithFrame:screenRect];
    
    // Initialize tap gesture recognizer
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]; 
    
    // The number of taps in order for gesture to be recognized
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    // Add gesture recognizer to the view
    [self addGestureRecognizer:tapGestureRecognizer];
    return self;
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if(state == NORMAL_STATE)
    {
        if(pos.y > [self getBoxHeight]) //Don't handle taps to the toolbar
        {
            state = PIANO_STATE;
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
    else if(state == PIANO_STATE)
    {
        if(!CGRectContainsPoint([piano frame], pos))
        {
            [piano removeFromSuperview];
            state = NORMAL_STATE;
        }
    }
    else if(state == PATH_EDIT_STATE)
    {
        if(pos.y > [self getBoxHeight]) //Don't handle taps to the toolbar
        {
            [pathView addNoteWithPos:pos]; //TODO: snap to center
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
    NSLog(@"PlayButtonPressed");
}
-(void) pauseButtonEvent:(id)sender;
{
    NSLog(@"PauseButtonPressed");
}
-(void) rewButtonEvent:(id)sender;
{
    NSLog(@"RewButtonPressed");
}
-(void) ffButtonEvent:(id)sender;
{
    NSLog(@"FFButtonPressed");
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
    NSLog(@"EditButtonPressed");
    state = PATH_EDIT_STATE;
}

- (void) makePlaybackButtons
{
    UIColor *playbarButtonsBackground = [UIColor blueColor];
    UIFont  *playbarButtonsFont = [UIFont systemFontOfSize:20];
    UIColor *playbarButtonsTextColor = [UIColor whiteColor];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int playbarButtonHeight = [self getBoxHeight]-30;
    int playbarButtonWidth = screenRect.size.width/10 + 10;
    int nextXPosition = 20;
    int buttonSpacing = 15;
    int YPosition = 15;
    
    NSString * buttonNames[] = {@"Play", @"Pause", @"Rew", @"FF", @"Save", @"Load", @"Edit Path"};
    int numButtons = sizeof(buttonNames)/sizeof(buttonNames[0]);
    UIButton *btn[numButtons];
    
    //Creates array of event functions
    SEL selEventPlay  = @selector(playButtonEvent:);
    SEL selEventPause = @selector(pauseButtonEvent:);
    SEL selEventRew   = @selector(rewButtonEvent:);
    SEL selEventFF    = @selector(ffButtonEvent:);
    SEL selEventSave  = @selector(saveButtonEvent:);
    SEL selEventLoad  = @selector(loadButtonEvent:);
    SEL selEventEdit  = @selector(editButtonEvent:);
    SEL events[] = {selEventPlay, selEventPause, selEventRew, selEventFF, selEventSave, selEventLoad, selEventEdit};
    
    for(int i=0; i<numButtons; i++, nextXPosition += playbarButtonWidth + buttonSpacing)
    {
        if([buttonNames[i] isEqualToString:@"Save"]) nextXPosition += 20;
        CGRect rect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
        btn[i] = [[UIButton alloc]initWithFrame:rect];
        SEL eventHandler = events[i];
        [btn[i] addTarget:self action:eventHandler forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
        [btn[i] setBackgroundColor:playbarButtonsBackground];
        [btn[i] setTitle:buttonNames[i] forState:UIControlStateNormal];
        btn[i].titleLabel.font = playbarButtonsFont;
        btn[i].titleLabel.textColor = playbarButtonsTextColor;
        [btn[i] setTitleColor:playbarButtonsTextColor forState:UIControlStateNormal];
        [self addSubview:btn[i]];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Draw Playback Menu at top of screen
    CGContextRef playbackContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(playbackContext, 2.0);
    CGContextSetFillColorWithColor(playbackContext, [UIColor blackColor].CGColor);
    
    [self drawGrid:UIGraphicsGetCurrentContext()];
    [self addSubview:pathView];
    [self bringSubviewToFront:pathView];
    [self drawPlaybackMenu:playbackContext];
    
    [self makePlaybackButtons];
}

- (CGPoint) getBoxFromCoords:(CGPoint)pos 
{
    CGPoint box = CGPointMake((int)pos.x / [self getBoxWidth], (int)pos.y / [self getBoxHeight]);
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}

@end
