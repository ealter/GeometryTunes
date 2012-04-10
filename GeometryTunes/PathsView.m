#import "PathsView.h"
#import "NotePath.h"
#import "GridView.h"

@implementation PathsView

@synthesize path;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        path = [[NotePath alloc] init];
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

- (void)setSpeedFactor:(float)factor
{
    [path setSpeedFactor:factor];
}

- (void)setDelegateGrid:(GridView *)grid
{
    [path setDelegateGrid:grid];
}

@end
