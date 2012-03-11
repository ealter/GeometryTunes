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
    float whiteKeyWidth = ((float)width) / (numNotes+3); //The octave up/down have a width of 1.5 notes each
    float x = 0;
    
    UIColor *octavesBackground = [UIColor blueColor];
    UIFont  *octavesFont = [UIFont systemFontOfSize:70];
    UIColor *octavesTextColor = [UIColor blackColor];
    
    float buttonWidth = whiteKeyWidth*1.5;
    UIButton *octaveDown = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [octaveDown setBackgroundColor:octavesBackground];
    [octaveDown setTitle:@"-" forState:UIControlStateNormal];
    octaveDown.titleLabel.font = octavesFont;
    octaveDown.titleLabel.textColor = octavesTextColor;
    
    [self addSubview:octaveDown];
    x += buttonWidth;
    
    buttonWidth = whiteKeyWidth*1.5;
    UIButton *octaveUp = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [octaveUp setBackgroundColor:octavesBackground];
    [octaveUp setTitle:@"+" forState:UIControlStateNormal];
    octaveUp.titleLabel.font = octavesFont;
    octaveUp.titleLabel.textColor = octavesTextColor;
    
    [self addSubview:octaveUp];
}

@end
