#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PathsView

@synthesize path, delegateGrid, pulseCircle;
@synthesize tapGestureRecognizer;
@synthesize tapDistanceTolerance;

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
        path = [[NotePath alloc] init];
        [path setPathView:self];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self initPulseCircle];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [tapGestureRecognizer setEnabled:FALSE];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapDistanceTolerance = 90 * 90;
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pos = [sender locationOfTouch:0 inView:sender.view];
    int closestNode = [path closestNodeFrom:pos];
    if([path distanceFrom:pos noteIndex:closestNode] <= tapDistanceTolerance)
    {
        [path setPlaybackPosition:closestNode];
    }
}

- (void)drawRect:(CGRect)rect
{
    [path updateAndDisplayPath:UIGraphicsGetCurrentContext()];
}

- (void)addNoteWithPos:(CGPoint)pos
{
    [path addNoteWithPos:pos];
}

- (void)removeAllNotes
{
    [path removeAllNotes];
    [self setNeedsDisplay];
}

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player
{
    [tapGestureRecognizer setEnabled:TRUE];
    [path playWithSpeedFactor:factor notePlayer:player];
}

- (void)pause
{
    [tapGestureRecognizer setEnabled:FALSE];
    [path pause];
}

- (void)stop
{
    [tapGestureRecognizer setEnabled:FALSE];
    [path stop];
}

- (void)playHasStopped:(NotePath *)path
{
    [tapGestureRecognizer setEnabled:FALSE];
    [[delegateGrid delegate] setPlayStateToStopped];
}

- (void)setSpeedFactor:(float)factor
{
    [path setSpeedFactor:factor];
}

- (void)setGrid:(GridView *)grid
{
    [self setDelegateGrid:grid];
    [path setDelegateGrid:grid];
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

@end
