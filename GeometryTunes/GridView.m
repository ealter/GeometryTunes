//
//  GridView.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "GridView.h"

@implementation GridView

@synthesize numBoxesX;
@synthesize numBoxesY; 
@synthesize gridWidth;
@synthesize gridHeight;

@synthesize tapGestureRecognizer;
@synthesize tapButtonRecognizer;

@synthesize pianoOctave;
@synthesize state;

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
    numBoxesX = 10;
    numBoxesY = 10;
    
    pianoOctave = 5;
    state = NORMAL_STATE;
    piano = NULL;
    
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
            int pianoHeight = 200;
            int pianoY = gridHeight - pianoHeight;
            if((box.y+1) * [self getBoxHeight] > gridHeight - pianoHeight)
                pianoY = (box.y - 0.5) * [self getBoxHeight] - pianoHeight;
            CGRect pianoRect = CGRectMake(0, pianoY, gridWidth, pianoHeight);
            piano = [[Piano alloc] initWithFrame:pianoRect];
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
            piano = NULL;
            state = NORMAL_STATE;
        }
    }
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
    CGRect myRect;
    for (int i = 0; i <= numBoxesX; i++) {
        for (int j = 0; j <= numBoxesY; j++) {
            myRect = CGRectMake(i * [self getBoxWidth], j * [self getBoxHeight], [self getBoxWidth], [self getBoxHeight]);
            CGContextAddRect(context, myRect);  
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

-(void) buttonEvent
{
    NSLog(@"ButtonPressed");
}

- (void) makePlaybackButtons
{
    UIColor *playbarButtonsBackground = [UIColor whiteColor];
    UIFont  *playbarButtonsFont = [UIFont systemFontOfSize:30];
    UIColor *playbarButtonsTextColor = [UIColor blueColor];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int playbarButtonHeight = [self getBoxHeight]-20;
    int playbarButtonWidth = screenRect.size.width/10 + 20;
    int nextXPosition = 20;
    int buttonSpacing = 15;
    int YPosition = 10;
    
    NSString * buttonNames[] = {@"Play", @"Pause", @"Rew", @"FF", @"Save", @"Load"};
    int numButtons = sizeof(buttonNames)/sizeof(buttonNames[0]);
    
    for(int i=0; i<numButtons; i++, nextXPosition += playbarButtonWidth + buttonSpacing)
    {
        CGRect rect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
        UIButton *btn = [[UIButton alloc]initWithFrame:rect];
        [btn setBackgroundColor:playbarButtonsBackground];
        [btn setTitle:buttonNames[i] forState:UIControlStateNormal];
        btn.titleLabel.font = playbarButtonsFont;
        btn.titleLabel.textColor = playbarButtonsTextColor;
        [btn setTitleColor:playbarButtonsTextColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        //tapButtonRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:btn action:@selector(butttonEvent:)];
        //tapButtonRecognizer.numberOfTapsRequired = 1;
        //[btn addGestureRecognizer:tapButtonRecognizer];
        [self addSubview:btn];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Draw Playback Menu at top of screen
    CGContextRef playbackContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(playbackContext, 2.0);
    CGContextSetFillColorWithColor(playbackContext, [UIColor blackColor].CGColor);
    [self drawPlaybackMenu:playbackContext];
    
    // Add Playback buttons
    [self makePlaybackButtons];
    
    // Draw Grid of screen size
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    // Set fill color to blue (Don't need this)
    // CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    [self drawGrid:context];
    
    // Draw
    CGContextStrokePath(context);

}

- (CGPoint) getBoxFromCoords:(CGPoint)pos 
{
    CGPoint box = CGPointMake((int)pos.x / [self getBoxWidth], (int)pos.y / [self getBoxHeight]);
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}

@end
