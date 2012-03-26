//
//  NotePath.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/23/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "NotePath.h"
#import "GridView.h"

@implementation NotePath

@synthesize numNotes;
@synthesize notes;
@synthesize playbackPosition;
@synthesize player;
@synthesize delegateGrid;

const static NSTimeInterval playbackSpeed = 1.0;

- (id)init 
{
    self = [super init];
    if (self) {
        notes = [[NSMutableArray alloc] init];
        numNotes = 0;
        path = nil;
        playbackPosition = 0;
        playbackTimer = nil;
        delegateGrid = nil;
    }
    return self;
}

- (void)addNoteWithPos:(CGPoint)pos 
{
    [notes addObject:[NSValue valueWithCGPoint:pos]];
    numNotes++;
}

- (void)removeNoteAtIndex:(unsigned)index
{
    [notes removeObjectAtIndex:index];
    numNotes--;
}

- (void)buildPath
{
    path = [UIBezierPath bezierPath];
    
    const float radius = 5;
    for (int i = 0; i < numNotes; i++) {
        CGPoint point = [[notes objectAtIndex:i] CGPointValue];
        if (i == 0)
            [path moveToPoint:point];
        else
            [path addLineToPoint:point];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - radius, point.y - radius, radius*2, radius*2)];
        [path appendPath:circlePath];
        [path moveToPoint:point];
    }
}

- (void)updateAndDisplayPath:(CGContextRef)context
{
    [self buildPath];
    CGContextSaveGState(context);
    
    path.lineWidth = 5;
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

- (void)playNote:(NSTimer*)t
{
    NSNumber *r = t.userInfo;
    bool reverse = [r boolValue];
    if((reverse && playbackPosition < 0) || playbackPosition == [notes count])
    {
        [delegateGrid stopPlayback];
        return;
    }
    pianoNote note = [delegateGrid getNoteFromCoords:[[notes objectAtIndex:playbackPosition] CGPointValue]];
    if(note != NO_PIANO_NOTE)
    {
        assert(player);
        [player playNoteWithPitch: [noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]];
    }
    if(reverse)
        playbackPosition--;
    else
        playbackPosition++;
}

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer *)p
{
    assert(delegateGrid);
    [self setPlayer:p];
    bool reverse = false;
    if(factor < 0)
    {
        factor = -factor;
        reverse = true;
    }
    NSTimeInterval speed = playbackSpeed * factor;
    if(reverse)
        playbackPosition = [notes count] - 1;
    NSNumber *r = [NSNumber numberWithBool:reverse];
    if(playbackTimer)
        [playbackTimer invalidate];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(playNote:) userInfo:r repeats:YES];
}

- (void)pause
{
    if(playbackTimer) {
        [player stopAllNotes];
        [playbackTimer invalidate];
    }
}

- (void)stop
{
    [self pause];
    playbackPosition = 0;
}

@end
