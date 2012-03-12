//
//  GridView.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Piano.h"

@interface GridView : UIView

typedef enum STATE
{
    NORMAL_STATE,
    PIANO_STATE,
    PIPE_EDIT_STATE
} STATE;

@property int gridWidth;
@property int gridHeight;
@property int numBoxesX;
@property int numBoxesY;

@property int pianoOctave;

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;

@property STATE state;

-(id)sharedInit;
- (void)handleTap:(UITapGestureRecognizer *)sender;
- (int)getBoxWidth;
- (int)getBoxHeight;
- (void)drawGrid:(CGContextRef)context;
- (void)drawPlaybackMenu:(CGContextRef)context;
- (void) makePlaybackButtons;
- (CGPoint)getBoxFromCoords:(CGPoint)pos;
//- (void) playEvent;

@end
