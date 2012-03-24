//
//  Piano.m
//  GeometryTunes
//
//  Created by Music2 on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "Piano.h"

@implementation Piano

#import "noteColor.h"
#import "GridView.h"

@synthesize octave;

- (id)initWithFrame:(CGRect)frame delegate:(GridView*)del
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
        delegate = del;
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
    octave = INITIAL_PIANO_OCTAVE;
    numNotes = NOTES_IN_OCTAVE;
    numWhiteNotes = 7;
    notes = [NSMutableArray arrayWithCapacity:numNotes];
    notePlayer = [[NotePlayer alloc]init];
    return self;
}

- (void)drawRect:(CGRect)rect
{
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
    [octaveDown setTitleColor:octavesTextColor forState:UIControlStateNormal];
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
        }
        else
        {
            isBlack = false;
            //This note is a white note
            whiteKeyNum++;
            note = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, whiteKeyWidth, height)];
            x += whiteKeyWidth;
        }
        
        [note setBackgroundColor:[noteColor colorFromNoteWithPitch:i octave:octave]];
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
    [octaveUp setTitleColor:octavesTextColor forState:UIControlStateNormal];
    octaveUp.tag = 1;
    [octaveUp addTarget:self action:@selector(OctaveChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
    
    [self addSubview:octaveUp];
}

- (void)KeyClicked:(id)sender
{
    UIButton *note = sender;
    NSLog(@"Key: %d", note.tag);
    int pitch = note.tag % NOTES_IN_OCTAVE;
    int oct   = note.tag / NOTES_IN_OCTAVE + octave;
    [notePlayer playNoteWithPitch:pitch octave:oct];
    [delegate changeNoteWithPitch:pitch octave:oct];
}

- (void)OctaveChanged:(id)sender
{
    UIButton *octaveBtn = sender;
    int newOctave = octave + octaveBtn.tag;
    if(newOctave > MAX_OCTAVE)
        octave = MAX_OCTAVE;
    else if(newOctave < MIN_OCTAVE)
        octave = MIN_OCTAVE;
    else
    {
        octave = newOctave;
        //TODO: Update the piano colors
        NSLog(@"New octave: %d", octave);
    }
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
    int n = pitch % NOTES_IN_OCTAVE;
    return n == 1 || n == 3 || n == 6 || n == 8 | n == 10;
}

@end
