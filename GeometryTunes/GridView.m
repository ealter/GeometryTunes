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
    CGPoint box = [self getBoxFromCoords:pos];
    CGRect pianoRect = CGRectMake(0, gridHeight-200, gridWidth, 200);
    Piano* piano = [[Piano alloc] initWithFrame:pianoRect];
    [piano setOctave:pianoOctave];
    [self addSubview:piano];
    NSLog(@"%@", NSStringFromCGPoint(box));
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

- (void)drawRect:(CGRect)rect
{
    // Draw Playback Menu at top of screen
    CGContextRef playbackContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(playbackContext, 2.0);
    CGContextSetFillColorWithColor(playbackContext, [UIColor blackColor].CGColor);
    [self drawPlaybackMenu:playbackContext];
    
    // Add Playback buttons
    //[makePlaybackButton];
    
    
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
