#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach_time.h>

@interface PathsView ()

@property (retain) NSMutableDictionary *paths;
@property (retain) UIImage *pulseCircle;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) float tapDistanceTolerance; //Units are pixels^2. This is the maximum distance a touch can be from a node for it to register that the touch was meant for that node
@property (nonatomic) float removeDistanceTolerance;

- (void)sharedInit;
- (void)initPulseCircle;
- (void)projectHasChanged;
- (NotePath *)path:(NSString *)pathName;

@end

@implementation PathsView

@synthesize grid, pulseCircle;
@synthesize paths, currentPathName;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance, removeDistanceTolerance;
@synthesize speed, isPlaying;

- (NotePath *)currentPath
{
    return [self path:currentPathName]; //TODO: what happens if currentPath=nil?
}

- (NotePath *)path:(NSString *)pathName
{
    if(pathName)
        return [paths objectForKey:pathName];
    return nil;
}

- (void)projectHasChanged
{
    [grid.viewController projectHasChanged];
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
    tapDistanceTolerance = 0; /* Gets set in setGrid */
    removeDistanceTolerance = 30 * 30;
    speed = 1;
    isPlaying = FALSE;
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
        for(NSString *pathName in paths) {
            [[self path:pathName] setPathView:self];
        }
        if([paths count] == 0)
            currentPathName = nil;
        else
            currentPathName = [self nthPathName:0];
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
    if(![self pathExists:pathName]) {
        NotePath *path = [[NotePath alloc]init];
        [path setPathView:self];
        assert(paths);
        [paths setValue:path forKey:pathName];
        [self projectHasChanged];
    }
    [self setCurrentPathName:pathName];
}

- (int)numPaths
{
    return [paths count];
}

- (BOOL)pathExists:(NSString *)pathName
{
    return [self path:pathName] != nil;
}

- (float)closestNodeToPos:(CGPoint)pos pathName:(NSString**)pathName index:(int*)i
{
    NSString *closestPath = nil;
    int minIndex = 0;
    float minDistance = FLT_MAX;
    for (NSString *pathName in paths) {
        NotePath *path = [self path:pathName];
        if([path numNotes] > 0) { //There is no closest node if there are no nodes
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
        [[self path:closestPath] setPlaybackPosition:minIndex];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSString *pathName in paths) {
        BOOL isCurrentPath = ([grid state] == PATH_EDIT_STATE) && ([pathName compare:currentPathName] == NSOrderedSame);
        [[self path:pathName] updateAndDisplayPath:context dashed:isCurrentPath];
    }
}

- (void)addNoteWithPos:(CGPoint)pos
{
    if(![self currentPath]) {
        if([paths count] != 0) {
            assert(0);
        }
        NSLog(@"There are no paths to be added to");
        return;
    }
    [[self currentPath] addNoteWithPos:pos];
    [self setNeedsDisplay];
    [self projectHasChanged];
}

- (bool)removeNoteWithPos:(CGPoint)pos
{
    NSString *closestPath;
    int minIndex;
    if([self closestNodeToPos:pos pathName:&closestPath index:&minIndex] <= removeDistanceTolerance && closestPath != nil) {
        [[self path:closestPath] removeNoteAtIndex:minIndex];
        [self setNeedsDisplay];
        [self projectHasChanged];
        return true;
    }
    return false;
}

- (void)removeAllNotes
{
    [[self currentPath] removeAllNotes];
    [self setNeedsDisplay];
    [self projectHasChanged];
}

- (void)play
{
    isPlaying = TRUE;
    if([paths count] == 0) {
        [self performSelector:@selector(playHasStopped) withObject:nil afterDelay:0];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"There are no paths to play!" message:@"To make a path, click the \"Paths\" button at the top right of the screen." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [tapGestureRecognizer setEnabled:TRUE];
    for (NSString *pathName in paths) {
        [[self path:pathName] play];
    }
}

- (void)pause
{
    isPlaying = FALSE;
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        [[self path:pathName] pause];
    }
    [NotePlayer stopAllNotes];
}

- (void)stop
{
    isPlaying = FALSE;
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        [[self path:pathName] stop];
    }
    [NotePlayer stopAllNotes];
}

- (void)playHasStopped
{
    //Check if the play has stopped for all paths
    bool stillPlaying = false;
    for (NSString *pathName in paths)
    {
        stillPlaying = stillPlaying || [[self path:pathName] isPlaying];
    }
    if(!stillPlaying) {
        isPlaying = FALSE;
        [NotePlayer stopAllNotes];
        for(NSString *pathName in paths) {
            [[self path:pathName] setPlaybackPosition:0];
        }
        [tapGestureRecognizer setEnabled:FALSE];
        [[grid viewController] setPlayStateToStopped];
    }
}

- (void)setSpeed:(NSTimeInterval)_speed
{
    speed = _speed;
    for (NSString *pathName in paths) {
        [[self path:pathName] setShouldChangeSpeed:TRUE];
    }
}

- (void)setGrid:(GridView *)_grid
{
    grid = _grid;
    tapDistanceTolerance = [grid boxWidth] * [grid boxHeight];
}

- (void)deemphasizeCell:(GridCell *)cell
{
    [grid setIsBold:FALSE cell:cell];
}

- (void)pulseAt:(CGPoint)pos
{
    assert(pulseCircle);
    //Pulse the grid cell
    GridCell *cell = [grid cellAtPos:[grid getBoxFromCoords:pos]];
    [grid setIsBold:TRUE cell:cell];
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
    uint64_t date1 = [(NotePath*)[dict objectForKey:path1] mostRecentAccess];
    uint64_t date2 = [(NotePath*)[dict objectForKey:path2] mostRecentAccess];
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
    NotePath *path = [self path:oldName];
    if(path && ![self pathExists:newName]) {
        [paths removeObjectForKey:oldName];
        [paths setObject:path forKey:newName];
        [self projectHasChanged];
    }
}

- (void)setLooping:(BOOL)doesLoop pathName:(NSString *)pathName
{
    NotePath *path = [self path:pathName];
    bool changed = (doesLoop != [path doesLoop]);
    if(changed) {
        [path setDoesLoop:doesLoop];
        [self setNeedsDisplay];
        [self projectHasChanged];
    }
}

- (BOOL)pathDoesLoop:(NSString *)pathName
{
    return [[self path:pathName] doesLoop];
}

- (void)setCurrentPathName:(NSString *)_currentPathName
{
    currentPathName = _currentPathName;
    NotePath *path = [self path:currentPathName];
    if(path)
        [path setMostRecentAccess:mach_absolute_time()];
    if([grid state] == PATH_EDIT_STATE)
        [self setNeedsDisplay];
}

- (void)deletePath:(NSString *)pathName
{
    if([currentPathName isEqualToString:pathName])
        currentPathName = nil;
    [[self path:pathName] stop];
    [paths removeObjectForKey:pathName];
    [self setNeedsDisplay];
    [self projectHasChanged];
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

- (void)reset
{
    [paths removeAllObjects];
    [self setNeedsDisplay];
}

@end
