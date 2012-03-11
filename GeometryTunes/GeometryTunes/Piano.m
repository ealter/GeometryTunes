//
//  Piano.m
//  GeometryTunes
//
//  Created by Music2 on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "Piano.h"

@implementation Piano

@synthesize octave;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit
{
    octave = 5;
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Drawing the rectangle");
    CGRect screenRect = [self bounds];
    int width = screenRect.size.width;
    int height = screenRect.size.height;
    const int numNotes = 8; //an octave
    int whiteKeyWidth = width / (numNotes+3); //The octave up/down have a width of 1.5 notes each
    int x = 0;
    UIButton *octaveDown = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, whiteKeyWidth*1.5, height)];
    [octaveDown setBackgroundColor:[UIColor blueColor]];
    [octaveDown.titleLabel setText:@"-"];
    [self addSubview:octaveDown];
}

@end
