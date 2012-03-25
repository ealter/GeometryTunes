//
//  GridView.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Piano.h"
#import "PathsView.h"
#import "ViewController.h"

@interface GridView : UIView
{
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row
                           //          2nd index is col
    PathsView *pathView;
    int playbackPosition;
    NSTimer *playbackTimer;
    ViewController *delegate;
}

@property int gridWidth;
@property int gridHeight;
@property int numBoxesX;
@property int numBoxesY;

@property int pianoOctave;

@property unsigned currentX; //These are used when editing a square
@property unsigned currentY;

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapButtonRecognizer;

- (void)sharedInitWithFrame:(CGRect)frame;

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;
- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned) x y:(unsigned)y;

- (int)getBoxWidth;
- (int)getBoxHeight;

- (void)drawGrid:(CGContextRef)context;
- (void)drawPlaybackMenu:(CGContextRef)context;

- (CGPoint)getBoxFromCoords:(CGPoint)pos;

- (void)playPathWithSpeed:(NSTimeInterval)speed;

@end
