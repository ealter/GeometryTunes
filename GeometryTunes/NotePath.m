#import "NotePath.h"
#import "GridView.h"
#import "PathsView.h"
#import <QuartzCore/QuartzCore.h>

@interface NotePath () {
    @private
    UIBezierPath* path;
    NSTimer *playbackTimer;
}

- (GridView *)grid;

@end

@implementation NotePath

@synthesize notes;
@synthesize playbackPosition, isPlaying;
@synthesize pathView;
@synthesize shouldChangeSpeed;
@synthesize mostRecentAccess;
@synthesize pathFollower;
@synthesize doesLoop;

- (id)init 
{
    self = [super init];
    if (self) {
        notes = [[NSMutableArray alloc] init];
        path = nil;
        playbackPosition = 0;
        playbackTimer = nil;
        pathView = nil;
        shouldChangeSpeed = false;
        isPlaying = false;
        mostRecentAccess = 0;
        pathFollower = nil;
        doesLoop = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    NSMutableArray *_notes = [aDecoder decodeObject];
    if(_notes)
        notes = _notes;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:notes];
}

- (GridView *)grid
{
    assert(pathView);
    return [pathView grid];
}

- (NSTimeInterval)speed
{
    return [pathView speed];
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
    [self stop];
}

- (void)buildPath
{
    path = [UIBezierPath bezierPath];
    int count = notes.count;
    const float defaultRadius = 5;
    for (int i = 0; i < count; i++) {
        CGPoint point = [[notes objectAtIndex:i] CGPointValue];
        if (i == 0)
            [path moveToPoint:point];
        else
            [path addLineToPoint:point];
        float radius = i==0 ? defaultRadius * 2 : defaultRadius;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - radius, point.y - radius, radius*2, radius*2)];
        [path appendPath:circlePath];
        [path moveToPoint:point];
    }
    if(doesLoop && count > 1)
        [path addLineToPoint:[[notes objectAtIndex:0] CGPointValue]];
}

- (void)updateAndDisplayPath:(CGContextRef)context dashed:(BOOL)isDashed
{
    [self buildPath];
    CGContextSaveGState(context);
    
    path.lineWidth = 5;
    if(isDashed) {
        const CGFloat lineDash[] = {15, 6};
        [path setLineDash:lineDash count:sizeof(lineDash)/sizeof(lineDash[0]) phase:0];
    }
    else {
        [path setLineDash:nil count:1 phase:0];
    }
    [[UIColor whiteColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

- (void)playNote:(NSTimer*)t
{
    assert(notes);
    if(playbackPosition >= [notes count]) {
        if(doesLoop) {
            playbackPosition %= [notes count];
        }
        else {
            [self stop];
            return;
        }
    }
    CGPoint pos = [[notes objectAtIndex:playbackPosition] CGPointValue];
    CellPos coords = [[self grid] getBoxFromCoords:pos];
    [[self grid] playCell:coords duration:[t timeInterval]*.99];
    [pathView pulseAt:pos];
    if(playbackPosition < [notes count])
    {
        CGPoint pos = [[notes objectAtIndex:playbackPosition] CGPointValue];
        [[pathFollower layer] setPosition:pos];
        if(playbackPosition + 1 < [notes count] || doesLoop)
            [pathView movePathFollower:pathFollower pos:[[notes objectAtIndex:(playbackPosition + 1) % [notes count]] CGPointValue] delegate:self];
    }
    playbackPosition++;
    if(playbackPosition >= [notes count] && !doesLoop) {
        [self performSelector:@selector(stop) withObject:nil afterDelay:[t timeInterval]];
        [t invalidate];
    }
    else if(shouldChangeSpeed)
    {
        shouldChangeSpeed = false;
        [t invalidate];
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:[self speed] target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
    }
}

- (void)play
{
    isPlaying = true;
    if([notes count] < 1)
    {
        [self performSelector:@selector(stop) withObject:nil afterDelay:0];
        return;
    }
    if(pathFollower)
        [pathFollower removeFromSuperview];
    pathFollower = [pathView getPathFollowerAtPos:[[notes objectAtIndex:0] CGPointValue]];
    assert([self grid]);
    
    shouldChangeSpeed = false;
    
    if(playbackTimer)
        [playbackTimer invalidate];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:[self speed] target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
    [playbackTimer fire];
}

- (void)pause
{
    isPlaying = false;
    if(playbackTimer) {
        [playbackTimer invalidate];
    }
}

- (void)stop
{
    [self pause];
    shouldChangeSpeed = false;
    if(pathFollower) {
        [pathFollower stopAnimating];
        [pathFollower removeFromSuperview];
        pathFollower = nil;
    }
    [pathView playHasStopped];
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
    for(int i = 0; i<numNotes; i++) {
        float dist = [self distanceFrom:pos noteIndex:i];
        if(dist < minDistance) {
            minDistance = dist;
            minIndex = i;
        }
    }
    return minIndex;
}

@end
