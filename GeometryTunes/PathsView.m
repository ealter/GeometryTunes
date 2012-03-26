//
//  PathsView.m
//  GeometryTunes
//
//  Created by Music2 on 3/25/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "PathsView.h"

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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [path updateAndDisplayPath:UIGraphicsGetCurrentContext()];
}

- (void)addNoteWithPos:(CGPoint)pos
{
    [path addNoteWithPos:pos];
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

@end
