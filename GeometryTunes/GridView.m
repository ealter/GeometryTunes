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

@synthesize pianoOctave;

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
    NSLog(@"%d, %d", gridWidth, gridHeight);
    numBoxesX = 10;
    numBoxesY = 10;
    
    pianoOctave = 5;
    
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
    if(pos.y > [self getBoxHeight])
    {
        CGPoint box = [self getBoxFromCoords:pos];
        CGRect pianoRect = CGRectMake(0, gridHeight-200, gridWidth, 200);
        Piano* piano = [[Piano alloc] initWithFrame:pianoRect];
        [piano setOctave:pianoOctave];
        [self addSubview:piano];
        NSLog(@"%@", NSStringFromCGPoint(box));
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

//-(void) playEvent
//{
//    
//}

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
    
    
    //Play rect
    CGRect playRect;
    playRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Play button
    UIButton *play = [[UIButton alloc]initWithFrame:playRect];
    [play setBackgroundColor:playbarButtonsBackground];
    [play setTitle:@"Play" forState:UIControlStateNormal];
    play.titleLabel.font = playbarButtonsFont;
    play.titleLabel.textColor = playbarButtonsTextColor;
    //[play beginTrackingWithTouch:play withEvent:playEvent];
    [self addSubview:play];
    
    //Pause rect
    CGRect pauseRect;
    pauseRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Pause button
    UIButton *pause = [[UIButton alloc]initWithFrame:pauseRect];
    [pause setBackgroundColor:playbarButtonsBackground];
    [pause setTitle:@"Pause" forState:UIControlStateNormal];
    pause.titleLabel.font = playbarButtonsFont;
    pause.titleLabel.textColor = playbarButtonsTextColor;
    [self addSubview:pause];
    
    //Rew rect
    CGRect rewRect;
    rewRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Rew button
    UIButton *rew = [[UIButton alloc]initWithFrame:rewRect];
    [rew setBackgroundColor:playbarButtonsBackground];
    [rew setTitle:@"Rew" forState:UIControlStateNormal];
    rew.titleLabel.font = playbarButtonsFont;
    rew.titleLabel.textColor = playbarButtonsTextColor;
    [self addSubview:rew];
    
    //FF rect
    CGRect ffRect;
    ffRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Rew button
    UIButton *ff = [[UIButton alloc]initWithFrame:ffRect];
    [ff setBackgroundColor:playbarButtonsBackground];
    [ff setTitle:@"FF" forState:UIControlStateNormal];
    ff.titleLabel.font = playbarButtonsFont;
    ff.titleLabel.textColor = playbarButtonsTextColor;
    [self addSubview:ff];
    
    //Save rect
    CGRect saveRect;
    saveRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Save button
    UIButton *save = [[UIButton alloc]initWithFrame:saveRect];
    [save setBackgroundColor:playbarButtonsBackground];
    [save setTitle:@"Save" forState:UIControlStateNormal];
    save.titleLabel.font = playbarButtonsFont;
    save.titleLabel.textColor = playbarButtonsTextColor;
    [self addSubview:save];
    
    //Load rect
    CGRect loadRect;
    loadRect = CGRectMake(nextXPosition, YPosition, playbarButtonWidth, playbarButtonHeight);
    nextXPosition += playbarButtonWidth + buttonSpacing;
    //Load button
    UIButton *load = [[UIButton alloc]initWithFrame:loadRect];
    [load setBackgroundColor:playbarButtonsBackground];
    [load setTitle:@"Load" forState:UIControlStateNormal];
    load.titleLabel.font = playbarButtonsFont;
    load.titleLabel.textColor = playbarButtonsTextColor;
    [self addSubview:load];
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
    CGPoint box = CGPointMake((int)pos.x / [self getBoxWidth], (int)pos.y / [self getBoxWidth]);
    if (box.x > numBoxesX || box.y > numBoxesY)
        return CGPointMake(-1, -1);
    return box;
}


@end
