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
    const int numWhiteNotes = 7; //an octave
    const int numNotes = 12;
    const float octaveButtonRelativeSize = 1.3;
    const float whiteKeyWidth = ((float)width) / (numWhiteNotes+octaveButtonRelativeSize*2);
    float x = 0;
    
    UIColor *octavesBackground = [UIColor blueColor];
    UIFont  *octavesFont = [UIFont systemFontOfSize:70];
    UIColor *octavesTextColor = [UIColor blackColor];
    
    float buttonWidth = whiteKeyWidth*octaveButtonRelativeSize;
    UIButton *octaveDown = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [octaveDown setBackgroundColor:octavesBackground];
    [octaveDown setTitle:@"-" forState:UIControlStateNormal];
    octaveDown.titleLabel.font = octavesFont;
    octaveDown.titleLabel.textColor = octavesTextColor;
    
    [self addSubview:octaveDown];
    x += buttonWidth;
    
    float blackKeyWidth = whiteKeyWidth/2;
    float blackKeyHeight = height*2/3;
    UIButton *note;
    for(int i=0; i<numNotes; i++)
    {
        int relativeNote = i % 12;
        if(relativeNote == 1 || relativeNote == 4 || relativeNote == 7 || relativeNote == 9 | relativeNote == 11)
        {
            NSLog(@"Black note!");
            //The note is a black note
            note = [[UIButton alloc]initWithFrame:CGRectMake(x+(whiteKeyWidth*2-blackKeyWidth)/2, height-blackKeyHeight, blackKeyWidth, blackKeyHeight)];
            [note setBackgroundColor:[UIColor blackColor]];
        }
        else
        {
            //This note is a white note
            note = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, whiteKeyWidth, height)];
            x += whiteKeyWidth;
            if(i%2 == 0)
                [note setBackgroundColor:[UIColor whiteColor]];
            else
                [note setBackgroundColor:[UIColor greenColor]];
        }
        [self addSubview:note];
    }
    
    buttonWidth = whiteKeyWidth*1.5;
    UIButton *octaveUp = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [octaveUp setBackgroundColor:octavesBackground];
    [octaveUp setTitle:@"+" forState:UIControlStateNormal];
    octaveUp.titleLabel.font = octavesFont;
    octaveUp.titleLabel.textColor = octavesTextColor;
    
    [self addSubview:octaveUp];
}

@end
