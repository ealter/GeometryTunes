#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PathsView

@synthesize delegateGrid, pulseCircle;
@synthesize paths, currentPathName;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance;

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
        paths = [[NSDictionary alloc]init];
        currentPathName = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self initPulseCircle];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [tapGestureRecognizer setEnabled:FALSE];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapDistanceTolerance = 90 * 90;
    }
    return self;
}

- (void)addPath:(NSString *)pathName
{
    NotePath *path = [paths objectForKey:pathName];
    if(path == NULL)
    {
        path = [[NotePath alloc]init];
        [path setPathView:self];
        [paths setValue:path forKey:pathName];
    }
    [self setCurrentPathName:pathName];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    NotePath *path = [self currentPath];
    if(!path)
        return;
    int closestNode = [path closestNodeFrom:pos];
    if([path distanceFrom:pos noteIndex:closestNode] <= tapDistanceTolerance)
    {
        [path setPlaybackPosition:closestNode];
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
}

- (void)stop
{
    [tapGestureRecognizer setEnabled:FALSE];
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] stop];
    }
}

- (void)playHasStopped:(NotePath *)path
{
    [tapGestureRecognizer setEnabled:FALSE];
    [[delegateGrid delegate] setPlayStateToStopped];
}

- (void)setSpeedFactor:(float)factor
{
    for (NSString *pathName in paths)
    {
        [[paths objectForKey:pathName] setSpeedFactor:factor];
    }
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

- (void)pulseAt:(CGPoint)pos
{
    assert(pulseCircle);
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

- (NSString*)nthPathName:(NSInteger)index
{
    return currentPathName; //TODO: implement this
}

@end
