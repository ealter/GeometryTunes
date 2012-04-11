#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"
#import "PathsView.h"

@implementation NotePath

@synthesize notes;
@synthesize playbackPosition;
@synthesize player;
@synthesize delegateGrid, pathView;
@synthesize speedFactor;

const static NSTimeInterval playbackSpeed = 1;

- (id)init 
{
    self = [super init];
    if (self) {
        notes = [[NSMutableArray alloc] init];
        path = nil;
        pulse = nil;
        playbackPosition = 0;
        playbackTimer = nil;
        delegateGrid = nil;
        shouldChangeSpeed = false;
        pathView = nil;
    }
    return self;
}

- (void)addNoteWithPos:(CGPoint)pos 
{
    [notes addObject:[NSValue valueWithCGPoint:pos]];
}

- (void)removeNoteAtIndex:(unsigned)index
{
    [notes removeObjectAtIndex:index];
} // removes every other node, needs to be debugged

- (void) removeAllNotes
{
    [notes removeAllObjects];
    [path removeAllPoints];
    
}

- (void)buildPath
{
    path = [UIBezierPath bezierPath];
    int count = notes.count;
    const float radius = 5;
    for (int i = 0; i < count; i++) {
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
    [[UIColor whiteColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

- (void)playNote:(NSTimer*)t
{
    CGPoint pos = [[notes objectAtIndex:playbackPosition] CGPointValue];
    CellPos coords = [delegateGrid getBoxFromCoords:pos];
    [delegateGrid playNoteForCell:coords duration:[t timeInterval]];
    [pathView pulseAt:pos];
    playbackPosition++;
    if(playbackPosition >= [notes count])
    {
        [self stop];
    }
    else if(shouldChangeSpeed)
    {
        shouldChangeSpeed = false;
        [t invalidate];
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speedFactor * playbackSpeed target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
    }
}

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer *)p
{
    if([notes count] < 1)
    {
        [self performSelector:@selector(stop) withObject:nil afterDelay:0];
        return;
    }
    assert(delegateGrid);
    [self setPlayer:p];
    
    shouldChangeSpeed = false;
    
    //NSTimeInterval speed = playbackSpeed * factor;
    speedFactor = factor;
    
    if(playbackTimer)
        [playbackTimer invalidate];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speedFactor * playbackSpeed target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
    [playbackTimer fire];
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
    shouldChangeSpeed = false;
    [pathView playHasStopped:self];
}

- (void)setSpeedFactor:(float)_speedFactor
{
    speedFactor = _speedFactor;
    shouldChangeSpeed = true;
}

- (float)distanceFrom:(CGPoint)pos noteIndex:(int)i
{
    CGPoint notePos = [[notes objectAtIndex:i] CGPointValue];
    float deltaX = notePos.x - pos.x;
    float deltaY = notePos.y - pos.y;
    return deltaX*deltaX + deltaY*deltaY;
}

- (int)closestNodeFrom:(CGPoint)pos
{
    int numNotes = [notes count];
    int minIndex = 0;
    float minDistance = FLT_MAX;
    for(int i = 0; i<numNotes; i++)
    {
        float dist = [self distanceFrom:pos noteIndex:i];
        if(dist < minDistance)
        {
            minDistance = dist;
            minIndex = i;
        }
    }
    return minIndex;
}

- (void)setPlaybackPosition:(int)_playbackPosition
{
    playbackPosition = _playbackPosition;
    if(playbackTimer && [playbackTimer isValid])
    {
        [self playWithSpeedFactor:[playbackTimer timeInterval] notePlayer:player];
    }
}

@end
