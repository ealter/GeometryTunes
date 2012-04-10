#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"

@implementation NotePath

@synthesize notes;
@synthesize playbackPosition;
@synthesize player;
@synthesize delegateGrid;
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
        CellPos coords = [delegateGrid getBoxFromCoords:[[notes objectAtIndex:playbackPosition] CGPointValue]];
        [delegateGrid playNoteForCell:coords duration:[t timeInterval]];
    
        
        //timerEventCount = 0;
        
        // pulse code begin (unfinished)
    
        /*CGPoint point = [[notes objectAtIndex:playbackPosition] CGPointValue];
         pulse = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - 5, point.y - 5, 20, 20)];
         pulse.lineWidth = 5;
         [[UIColor redColor] setStroke];
         [pulse stroke];*/
    
        // pulse code end
        
        playbackPosition++;
    if(playbackPosition >= [notes count])
    {
        [self stop];
    }
    if(shouldChangeSpeed)
    {
        shouldChangeSpeed = false;
        [t invalidate];
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speedFactor * playbackSpeed target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
    }
}

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer *)p
{
    NSLog(@"NOTE PATH");
    assert(delegateGrid);
    [self setPlayer:p];
    
    shouldChangeSpeed = false;
    
    //NSTimeInterval speed = playbackSpeed * factor;
    speedFactor = factor;
    
    if(playbackTimer)
        [playbackTimer invalidate];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:speedFactor * playbackSpeed target:self selector:@selector(playNote:) userInfo:nil repeats:YES];
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

- (void)setSpeedFactor:(float)_speedFactor
{
    speedFactor = _speedFactor;
    shouldChangeSpeed = true;
}

@end
