//
//  PathsView.m
//  GeometryTunes
//
//  Created by Music2 on 3/25/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "PathsView.h"

@implementation PathsView

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

@end
