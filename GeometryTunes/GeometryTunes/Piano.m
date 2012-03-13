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
    numNotes = 12;
    numWhiteNotes = 7;
    notes = [NSMutableArray arrayWithCapacity:numNotes];
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
    octaveDown.tag = -1;
    [octaveDown addTarget:self action:@selector(OctaveChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
    
    [self addSubview:octaveDown];
    x += buttonWidth;
    
    float blackKeyWidth = whiteKeyWidth/2;
    float blackKeyHeight = height*2/3;
    UIButton *note;
    int whiteKeyNum = 0;
    bool isBlack;

    for(int i=0; i<numNotes; i++)
    {
        if([Piano isBlackNote:i])
        {
            isBlack = true;
            //The note is a black note
            note = [[UIButton alloc]initWithFrame:CGRectMake(x-blackKeyWidth/2, 0, blackKeyWidth, blackKeyHeight)];
            [note setBackgroundColor:[UIColor blackColor]];
        }
        else
        {
            isBlack = false;
            //This note is a white note
            whiteKeyNum++;
            note = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, whiteKeyWidth, height)];
            x += whiteKeyWidth;
            if(whiteKeyNum%2 == 0)
                [note setBackgroundColor:[UIColor whiteColor]];
            else
                [note setBackgroundColor:[UIColor greenColor]];
        }
        
        note.tag = i;
        [note addTarget:self action:@selector(KeyClicked:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
        [self addSubview:note];
        if(!isBlack)
            [self sendSubviewToBack:note];
        [notes addObject:note];
    }
    
    buttonWidth = whiteKeyWidth*1.5;
    UIButton *octaveUp = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [octaveUp setBackgroundColor:octavesBackground];
    [octaveUp setTitle:@"+" forState:UIControlStateNormal];
    octaveUp.titleLabel.font = octavesFont;
    octaveUp.titleLabel.textColor = octavesTextColor;
    octaveUp.tag = 1;
    [octaveUp addTarget:self action:@selector(OctaveChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
    
    [self addSubview:octaveUp];
}

- (void)KeyClicked:(id)sender
{
    UIButton *note = sender;
    NSLog(@"Key: %d", note.tag);
}

- (void)OctaveChanged:(id)sender
{
    UIButton *octaveBtn = sender;
    octave += octaveBtn.tag;
    //TODO: Update the piano colors
    NSLog(@"New octave: %d", octave);
}

+ (int)octaveOfPianoNote:(pianoNote)p
{
    assert(p < (1 << 16));
    return p >> 8;
}

+ (int)pitchOfPianoNote: (pianoNote)p
{
    assert(p < (1 << 16));
    return p & ((1 << 8) - 1);
}

+ (pianoNote)getPianoNoteOfPitch:(int)pitch Octave:(int)octave
{
    assert(pitch < (1 << 7) && octave < (1 << 7));
    return pitch | octave << 8;
}

+ (bool)isBlackNote:(int)pitch
{
    int n = pitch % 12;
    return n == 1 || n == 3 || n == 6 || n == 8 | n == 10;
}

@end
