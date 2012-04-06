#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"

@implementation NotePath

@synthesize notes;
@synthesize playbackPosition;
@synthesize player;
@synthesize delegateGrid;


const static NSTimeInterval playbackSpeed = 0.25;




- (id)init 
{
    self = [super init];
    if (self) {
        notes = [[NSMutableArray alloc] initWithCapacity:100];
        path = nil;
        pulse = nil;
        playbackPosition = 0;
        playbackTimer = nil;
        delegateGrid = nil;
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
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

- (void) removeAllNotes
{
    [notes removeAllObjects];
    [path removeAllPoints];
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
    CellPos coords = [delegateGrid getBoxFromCoords:[[notes objectAtIndex:playbackPosition] CGPointValue]];
    [delegateGrid playNoteForCell:coords duration:[t timeInterval]];
    
    // pulse code begin (unfinished)
    
    /*CGPoint point = [[notes objectAtIndex:playbackPosition] CGPointValue];
    pulse = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - 5, point.y - 5, 20, 20)];
    pulse.lineWidth = 5;
    [[UIColor redColor] setStroke];
    [pulse stroke];*/
    
    // pulse code end
    
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
    //if(reverse)
        //playbackPosition = [notes count] - 1; Commented out for reason: Causes Rew to start from end every time
    if(reverse)
        playbackPosition = playbackPosition - 1;
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
