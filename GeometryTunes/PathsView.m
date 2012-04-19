#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach_time.h>

@implementation PathsView

@synthesize delegateGrid, pulseCircle;
@synthesize paths, currentPathName;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance;
@synthesize speedFactor;

- (NotePath*)currentPath
{
    return [paths objectForKey:currentPathName]; //TODO: what happens if currentPath=nil?
}

- (void)initPulseCircle
{
    CGFloat radius = 50;
    CGSize size = CGSizeMake(radius*2,radius*2);
    CGPoint centre = CGPointMake(radius,radius);
    
    UIGraphicsBeginImageContextWithOptions(size,NO, 0.0);
    UIBezierPath * solidPath = [UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [solidPath closePath];
    [[UIColor whiteColor] set];
    [solidPath fill];
    
    pulseCircle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        paths = [[NSMutableDictionary alloc]init];
        currentPathName = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self initPulseCircle];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [tapGestureRecognizer setEnabled:FALSE];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapDistanceTolerance = 90 * 90;
        speedFactor = 1;
    }
    return self;
}

- (void)addPath:(NSString *)pathName
{
    assert(pathName);
    NotePath *path = [paths objectForKey:pathName];
    if(path == NULL)
    {
        path = [[NotePath alloc]init];
        [path setPathView:self];
        assert(paths);
        [paths setValue:path forKey:pathName];
    }
    [self setCurrentPathName:pathName];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([paths count] < 1)
        return;
    NSString *closestPath = nil;
    int minIndex = 0;
    float minDistance = FLT_MAX;
    for (NSString *pathName in paths)
    {
        int i = [[paths objectForKey:pathName] closestNodeFrom:pos];
        float dist = [[paths objectForKey:pathName] distanceFrom:pos noteIndex:i];
        if(dist <= minDistance)
        {
            minDistance = dist;
            closestPath = pathName;
            minIndex = i;
        }
    }
    if(minDistance <= tapDistanceTolerance && closestPath != nil)
    {
        [[paths objectForKey:closestPath] setPlaybackPosition:minIndex];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] updateAndDisplayPath:context];
    }
}

- (void)addNoteWithPos:(CGPoint)pos
{
    [[self currentPath] addNoteWithPos:pos];
}

- (void)removeAllNotes
{
    [[self currentPath] removeAllNotes];
    [self setNeedsDisplay];
}

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player
{
    [tapGestureRecognizer setEnabled:TRUE];
    speedFactor = factor;
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] playWithSpeedFactor:factor notePlayer:player];
    }
}

- (void)pause
{
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] pause];
    }
    if(currentPathName) //TODO: If currentPathName is nil but there exists a path, this will not work
    {
        [[[self currentPath] player] stopAllNotes];
    }
}

- (void)stop
{
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] stop];
    }
    if(currentPathName) //TODO: If currentPathName is nil but there exists a path, this will not work
    {
        [[[self currentPath] player] stopAllNotes];
    }
}

- (void)playHasStopped:(NotePath *)path
{
    //Check if the play has stopped for all paths
    bool stillPlaying = false;
    for (NSString *pathName in paths)
    {
        stillPlaying = stillPlaying || [[paths objectForKey:pathName] isPlaying];
    }
    if(!stillPlaying)
    {
        if(currentPathName) //TODO: If currentPathName is nil but there exists a path, this will not work
            [[[self currentPath] player] stopAllNotes];
        [tapGestureRecognizer setEnabled:FALSE];
        [[delegateGrid delegate] setPlayStateToStopped];
    }
}

- (void)setSpeedFactor:(float)factor
{
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] setSpeedFactor:factor];
    }
    speedFactor = factor;
}

- (void)setGrid:(GridView *)grid
{
    [self setDelegateGrid:grid];
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] setDelegateGrid:grid];
    }
    tapDistanceTolerance = [grid boxWidth] * [grid boxHeight];
}

- (void)deemphasizeCell:(GridCell *)cell
{
    [delegateGrid changeCell:cell isBold:FALSE];
}

- (void)pulseAt:(CGPoint)pos
{
    assert(pulseCircle);
    //Pulse the grid cell
    GridCell *cell = [delegateGrid cellAtPos:[delegateGrid getBoxFromCoords:pos]];
    [delegateGrid changeCell:cell isBold:TRUE];
    [self performSelector:@selector(deemphasizeCell:) withObject:cell afterDelay:speedFactor];
    
    const float width = 40;
    const float height = width;
    
    UIImageView *pulse = [[UIImageView alloc]initWithImage:pulseCircle];
    [pulse setBackgroundColor:[UIColor clearColor]];
    [pulse setFrame:CGRectMake(pos.x - width/2, pos.y - height/2, width, height)];
    [self addSubview:pulse];
    
    const float duration = 1.0;
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=duration;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    
    [pulse.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    [pulse performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
}

static NSInteger comparePaths(NSString *path1, NSString *path2, void *context)
{
    NSMutableDictionary *dict = (__bridge NSMutableDictionary*)context;
    uint64_t date1 = [[dict objectForKey:path1] mostRecentAccess];
    uint64_t date2 = [[dict objectForKey:path2] mostRecentAccess];
    if (date1 > date2)
        return NSOrderedAscending;
    else if(date1 < date2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (NSString*)nthPathName:(NSInteger)index
{
    NSArray *sortedKeys = [[paths allKeys] sortedArrayUsingFunction:comparePaths context:(__bridge void*)paths];
    return [sortedKeys objectAtIndex:index];
}

- (void)setCurrentPathName:(NSString *)_currentPathName
{
    currentPathName = _currentPathName;
    NotePath *path = [paths objectForKey:currentPathName];
    if(path)
        [path setMostRecentAccess:mach_absolute_time()];
}

- (void)deletePath:(NSString *)pathName
{
    if([currentPathName isEqualToString:pathName])
        currentPathName = nil;
    [paths removeObjectForKey:pathName];
    [self setNeedsDisplay];
}

@end
