#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "NotePlayer.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach_time.h>

@interface PathsView ()

@property (nonatomic, retain) NSMutableDictionary *paths;
@property (nonatomic, retain) UIImage *pulseCircle;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) float tapDistanceTolerance; //Units are pixels^2. This is the maximum distance a touch can be from a node for it to register that the touch was meant for that node
@property (nonatomic) float removeDistanceTolerance;

- (void)sharedInit;
- (void)initPulseCircle;
- (void)projectHasChanged;
- (NotePath *)path:(NSString *)pathName;
- (NSTimeInterval)timeUntilNextNote;

@end

@implementation PathsView

@synthesize grid = _grid;
@synthesize pulseCircle = _pulseCircle;
@synthesize currentPathName = _currentPathName;
@synthesize paths = _paths;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance, removeDistanceTolerance;
@synthesize speed = _speed;
@synthesize isPlaying = _isPlaying;

- (NotePath *)currentPath
{
    return [self path:self.currentPathName]; //TODO: what happens if currentPath=nil?
}

- (NSMutableDictionary *)paths
{
    if(!_paths) _paths = [[NSMutableDictionary alloc]init];
    return _paths;
}

- (NotePath *)path:(NSString *)pathName
{
    if(pathName)
        return [self.paths objectForKey:pathName];
    return nil;
}

- (void)projectHasChanged
{
    [self.grid.viewController projectHasChanged];
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [tapGestureRecognizer setEnabled:FALSE];
    [self addGestureRecognizer:tapGestureRecognizer];
    removeDistanceTolerance = 30 * 30;
    self.speed = 1;
    _isPlaying = FALSE;
}

- (UIImage *)pulseCircle
{
    if(!_pulseCircle) [self initPulseCircle];
    return _pulseCircle;
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
    
    self.pulseCircle = UIGraphicsGetImageFromCurrentImageContext();
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
        NSMutableDictionary *savedPaths = [aDecoder decodeObjectForKey:PATHS_ENCODE_KEY];
        if(savedPaths)
            self.paths = savedPaths;
        for(NSString *pathName in self.paths) {
            [[self path:pathName] setPathView:self];
        }
        if([self numPaths] == 0)
            self.currentPathName = nil;
        else
            self.currentPathName = [self nthPathName:0];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.paths forKey:PATHS_ENCODE_KEY];
}

- (void)addPath:(NSString *)pathName
{
    assert(pathName);
    if(![self pathExists:pathName]) {
        NotePath *path = [[NotePath alloc]init];
        [path setPathView:self];
        [self.paths setValue:path forKey:pathName];
        [self projectHasChanged];
    }
    [self setCurrentPathName:pathName];
}

- (int)numPaths
{
    return [self.paths count];
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
    for (NSString *pathName in self.paths) {
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

- (NSTimeInterval)timeUntilNextNote
{
    for(NSString *pathName in self.paths) {
        NotePath *path = [self path:pathName];
        if([path isPlaying]) {
            return [path timeUntilNextNote];
        }
    }
    return 0;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    if([self numPaths] < 1)
        return;
    NSString *closestPath;
    int minIndex;
    if([self closestNodeToPos:pos pathName:&closestPath index:&minIndex] <= tapDistanceTolerance && closestPath != nil) {
        NotePath *path = [self path:closestPath];
        [path setPlaybackPosition:minIndex];
        if(![path isPlaying])
            [path performSelector:@selector(play) withObject:nil afterDelay:[self timeUntilNextNote]];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSString *pathName in self.paths) {
        BOOL isCurrentPath = (self.grid.state == PATH_EDIT_STATE) && ([pathName compare:self.currentPathName] == NSOrderedSame);
        [[self path:pathName] updateAndDisplayPath:context dashed:isCurrentPath];
    }
}

- (void)addNoteWithPos:(CGPoint)pos
{
    if(![self currentPath]) {
        if([self numPaths] != 0) {
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
    _isPlaying = TRUE;
    if([self numPaths] == 0) {
        [self performSelector:@selector(playHasStopped) withObject:nil afterDelay:0];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"There are no paths to play!" message:@"To make a path, click the \"Paths\" button at the top right of the screen." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [tapGestureRecognizer setEnabled:TRUE];
    for (NSString *pathName in self.paths) {
        [[self path:pathName] play];
    }
}

- (void)pause
{
    _isPlaying = FALSE;
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in self.paths) {
        [[self path:pathName] pause];
    }
    [NotePlayer stopAllNotes];
}

- (void)stop
{
    _isPlaying = FALSE;
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in self.paths) {
        [[self path:pathName] stop];
    }
    [NotePlayer stopAllNotes];
}

- (void)playHasStopped
{
    //Check if the play has stopped for all paths
    bool stillPlaying = false;
    for (NSString *pathName in self.paths) {
        stillPlaying = stillPlaying || [[self path:pathName] isPlaying];
    }
    if(!stillPlaying) {
        _isPlaying = FALSE;
        [NotePlayer stopAllNotes];
        for(NSString *pathName in self.paths) {
            [[self path:pathName] setPlaybackPosition:0];
        }
        [tapGestureRecognizer setEnabled:FALSE];
        [self.grid.viewController setPlayStateToStopped];
    }
}

- (void)setSpeed:(NSTimeInterval)speed
{
    _speed = speed;
    for (NSString *pathName in self.paths) {
        [self path:pathName].shouldChangeSpeed = TRUE;
    }
}

- (void)setGrid:(GridView *)grid
{
    _grid = grid;
    tapDistanceTolerance = [self.grid boxWidth] * [self.grid boxHeight];
}

- (void)deemphasizeCell:(GridCell *)cell
{
    [self.grid setIsBold:FALSE cell:cell];
}

- (void)pulseAt:(CGPoint)pos
{
    //Pulse the grid cell
    GridCell *cell = [self.grid cellAtPos:[self.grid getBoxFromCoords:pos]];
    [self.grid setIsBold:TRUE cell:cell];
    [self performSelector:@selector(deemphasizeCell:) withObject:cell afterDelay:self.speed * .99];
    
    const float width = 40;
    const float height = width;
    
    UIImageView *pulse = [[UIImageView alloc]initWithImage:self.pulseCircle];
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
    NSArray *sortedKeys = [[self.paths allKeys] sortedArrayUsingFunction:comparePaths context:(__bridge void*)self.paths];
    return [sortedKeys objectAtIndex:index];
}

- (void)renamePathFrom:(NSString *)oldName to:(NSString *)newName
{
    NotePath *path = [self path:oldName];
    if(path && ![self pathExists:newName]) {
        [self.paths removeObjectForKey:oldName];
        [self.paths setObject:path forKey:newName];
        if([self.currentPathName compare:oldName] == NSOrderedSame)
            self.currentPathName = [newName copy];
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

- (void)setCurrentPathName:(NSString *)currentPathName
{
    [self setCurrentPathName:currentPathName updateAccessTime:TRUE];
}

- (void)setCurrentPathName:(NSString *)currentPathName updateAccessTime:(BOOL)updateAccessTime
{
    _currentPathName = currentPathName;
    NotePath *path = [self path:currentPathName];
    if(path && updateAccessTime)
        [path setMostRecentAccess:mach_absolute_time()];
    if(self.grid.state == PATH_EDIT_STATE)
        [self setNeedsDisplay];
}

- (void)deletePath:(NSString *)pathName
{
    if([self.currentPathName isEqualToString:pathName])
        self.currentPathName = nil;
    [[self path:pathName] stop];
    [self.paths removeObjectForKey:pathName];
    [self setNeedsDisplay];
    [self projectHasChanged];
}

- (UIImageView *)getPathFollowerAtPos:(CGPoint)pos
{
    const float width = 20;
    const float height = width;
    
    UIImageView *pulse = [[UIImageView alloc]initWithImage:self.pulseCircle];
    [pulse setBackgroundColor:[UIColor clearColor]];
    [pulse setFrame:CGRectMake(pos.x - width/2, pos.y - height/2, width, height)];
    [self addSubview:pulse];
    return pulse;
}

- (void)movePathFollower:(UIImageView *)follower pos:(CGPoint)pos delegate:(id)delegate
{
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"position"];
    theAnimation.duration=self.speed;
    theAnimation.fromValue=[NSValue valueWithCGPoint:follower.center];
    theAnimation.toValue=[NSValue valueWithCGPoint:pos];
    [theAnimation setDelegate:delegate];
    
    [follower.layer addAnimation:theAnimation forKey:@"animatePosition"];
}

- (void)reset
{
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

@end
