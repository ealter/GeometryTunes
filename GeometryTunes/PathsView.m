#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach_time.h>

@interface PathsView ()

- (void)sharedInit;
- (void)initPulseCircle;

@end

@implementation PathsView

@synthesize delegateGrid, pulseCircle;
@synthesize paths, currentPathName;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance, removeDistanceTolerance;
@synthesize speed;

- (NotePath*)currentPath
{
    return [paths objectForKey:currentPathName]; //TODO: what happens if currentPath=nil?
}

- (void)sharedInit
{
    paths = [[NSMutableDictionary alloc]init];
    currentPathName = nil;
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self initPulseCircle];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [tapGestureRecognizer setEnabled:FALSE];
    [self addGestureRecognizer:tapGestureRecognizer];
    tapDistanceTolerance = 90 * 90;
    removeDistanceTolerance = 30 * 30;
    speed = 1;
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
        [self sharedInit];
    }
    return self;
}

#define PATHS_ENCODE_KEY @"paths"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
        NSMutableDictionary *_paths = [aDecoder decodeObjectForKey:PATHS_ENCODE_KEY];
        if(_paths)
            paths = _paths;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:paths forKey:PATHS_ENCODE_KEY];
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

- (float)closestNodeToPos:(CGPoint)pos pathName:(NSString**)pathName index:(int*)i
{
    NSString *closestPath = nil;
    int minIndex = 0;
    float minDistance = FLT_MAX;
    for (NSString *pathName in paths) {
        NotePath *path = [paths objectForKey:pathName];
        if([[path notes] count] > 0) { //There is no closest node if there are no nodes
            int i = [path closestNodeFrom:pos];
            float dist = [path distanceFrom:pos noteIndex:i];
            if(dist <= minDistance) {
                minDistance = dist;
                closestPath = pathName;
                minIndex = i;
            }
        }
    }
    assert(i && pathName);
    *i = minIndex;
    *pathName = closestPath;
    return minDistance;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([paths count] < 1)
        return;
    NSString *closestPath;
    int minIndex;
    if([self closestNodeToPos:pos pathName:&closestPath index:&minIndex] <= tapDistanceTolerance && closestPath != nil) {
        [[paths objectForKey:closestPath] setPlaybackPosition:minIndex];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSString *pathName in paths) {
        NotePath *path = [paths objectForKey:pathName];
        [path updateAndDisplayPath:context];
    }
}

- (void)addNoteWithPos:(CGPoint)pos
{
    [[self currentPath] addNoteWithPos:pos];
    [self setNeedsDisplay];
}

- (bool)removeNoteWithPos:(CGPoint)pos
{
    NSString *closestPath;
    int minIndex;
    if([self closestNodeToPos:pos pathName:&closestPath index:&minIndex] <= removeDistanceTolerance && closestPath != nil) {
        [[paths objectForKey:closestPath] removeNoteAtIndex:minIndex];
        [self setNeedsDisplay];
        return true;
    }
    return false;
}

- (void)removeAllNotes
{
    [[self currentPath] removeAllNotes];
    [self setNeedsDisplay];
}

- (void)play
{
    [tapGestureRecognizer setEnabled:TRUE];
    for (NSString *pathName in paths) {
        NotePath *path = [paths objectForKey:pathName];
        [path play];
    }
}

- (void)pause
{
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        NotePath *path = [paths objectForKey:pathName];
        [path pause];
    }
    [NotePlayer stopAllNotes];
}

- (void)stop
{
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        NotePath *path = [paths objectForKey:pathName];
        [path stop];
    }
    [NotePlayer stopAllNotes];
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
        [NotePlayer stopAllNotes];
        for(NSString *pathName in paths) {
            NotePath *path = [paths objectForKey:pathName];
            [path setPlaybackPosition:0];
        }
        [tapGestureRecognizer setEnabled:FALSE];
        [[delegateGrid delegate] setPlayStateToStopped];
    }
}

- (void)setSpeed:(NSTimeInterval)_speed
{
    speed = _speed;
    for (NSString *pathName in paths) {
        [[paths objectForKey:pathName] setShouldChangeSpeed:TRUE];
    }
}

- (void)setGrid:(GridView *)grid
{
    [self setDelegateGrid:grid];
    for (NSString *pathName in paths) {
        NotePath *path = [paths objectForKey:pathName];
        [path setDelegateGrid:grid];
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
    [self performSelector:@selector(deemphasizeCell:) withObject:cell afterDelay:speed];
    
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
    
    [pulse.layer setOpacity:0];
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

- (void)renamePathFrom:(NSString *)oldName to:(NSString *)newName
{
    id path = [paths objectForKey:oldName];
    if(path && ![paths objectForKey:newName]) {
        [paths removeObjectForKey:oldName];
        [paths setObject:path forKey:newName];
    }
}

- (void)setLooping:(BOOL)doesLoop pathName:(NSString *)pathName
{
    NotePath *path = [paths objectForKey:pathName];
    bool changed = (doesLoop != [path doesLoop]);
    [[paths objectForKey:pathName] setDoesLoop:doesLoop];
    if(changed)
        [self setNeedsDisplay];
}

- (BOOL)pathDoesLoop:(NSString *)pathName
{
    NotePath *path = [paths objectForKey:pathName];
    return [path doesLoop];
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
    NotePath *path = [paths objectForKey:pathName];
    [path stop];
    [paths removeObjectForKey:pathName];
    [self setNeedsDisplay];
}

- (UIImageView *)getPathFollowerAtPos:(CGPoint)pos
{
    const float width = 20;
    const float height = width;
    
    UIImageView *pulse = [[UIImageView alloc]initWithImage:pulseCircle];
    [pulse setBackgroundColor:[UIColor clearColor]];
    [pulse setFrame:CGRectMake(pos.x - width/2, pos.y - height/2, width, height)];
    [self addSubview:pulse];
    return pulse;
}

- (void)movePathFollower:(UIImageView *)follower pos:(CGPoint)pos delegate:(id)delegate
{
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"position"];
    theAnimation.duration=speed;
    theAnimation.fromValue=[NSValue valueWithCGPoint:follower.center];
    theAnimation.toValue=[NSValue valueWithCGPoint:pos];
    [theAnimation setDelegate:delegate];
    
    [follower.layer addAnimation:theAnimation forKey:@"animatePosition"];
}

@end
