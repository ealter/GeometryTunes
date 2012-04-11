#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PathsView

@synthesize path, delegateGrid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        path = [[NotePath alloc] init];
        [path setPathView:self];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
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
    [path playWithSpeedFactor:factor notePlayer:player];
}

- (void)pause
{
    [path pause];
}

- (void)stop
{
    [path stop];
}

- (void)playHasStopped:(NotePath *)path
{
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
}

- (void)pulseAt:(CGPoint)pos
{
    const float width = 30;
    const float height = width;
    
    CALayer *pulse = [[CALayer alloc]init];
    [pulse setFrame:CGRectMake(pos.x - width/2, pos.y - height/2, width, height)];
    [pulse setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.layer addSublayer:pulse];
    
    const float duration = 1.0;
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=duration;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    
    [pulse addAnimation:theAnimation forKey:@"animateOpacity"];
    [pulse performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:duration];
}

@end
