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

@interface GridView : UIView
{
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row
                           //          2nd index is col
    //CGRect **rects; //2D array of grid CGrects
    PathsView *pathView;
}

@property int gridWidth;
@property int gridHeight;
@property int numBoxesX;
@property int numBoxesY;
@property (retain) id delegate; //A ViewController

@property int pianoOctave;

@property unsigned currentX; //These are used when editing a square
@property unsigned currentY;

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapButtonRecognizer;

- (void)sharedInitWithFrame:(CGRect)frame;

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;
- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned) x y:(unsigned)y;

- (float)getBoxWidth;
- (float)getBoxHeight;

- (void)drawGrid:(CGContextRef)context;

- (CGPoint)getBoxFromCoords:(CGPoint)pos;
- (pianoNote)getNoteFromCoords:(CGPoint)pos;

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse;
- (void)pausePlayback;
- (void)stopPlayback;

- (void)changeToNormalState;

@end
