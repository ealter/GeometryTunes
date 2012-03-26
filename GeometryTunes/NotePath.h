//
//  NotePath.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/23/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotePlayer.h"

@interface NotePath : NSObject
{
    UIBezierPath* path;
    NSTimer *playbackTimer;
}

 //Contains NSValue representations of CGPoints of path vertices
@property (readonly, retain) NSMutableArray *notes;
@property (readonly) int numNotes;
@property int playbackPosition;
@property (retain) NotePlayer *player;
@property (retain) id delegateGrid;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)updateAndDisplayPath:(CGContextRef)context;

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

@end
