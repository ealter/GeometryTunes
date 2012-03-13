//
//  noteColor.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/12/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "noteColor.h"

@implementation noteColor

const int RED = 0;
const int GREEN = 1;
const int BLUE = 2;
const int ALPHA_MULT = 0.2;

float RGBPitchMap[11][3] =
{
    {1.0, 0.0, 0.0},
    {0.75, 0.25, 0.0},
    {0.5, 0.5, 0.0},
    {0.25, 0.75, 0.0},
    {0.0, 1.0, 0.0},
    {0.0, 0.75, 0.25},
    {0.0, 0.5, 0.5},
    {0.0, 0.25, 0.75},
    {0.0, 0.0, 1.0},
    {0.25, 0.0, 0.75},
    {0.5, 0.0, 0.5}
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (UIColor*)colorFromNoteWithPitch:(int)pitch AndOctave:(int)octave {
    
    return [UIColor colorWithRed:RGBPitchMap[pitch][RED] green:RGBPitchMap[pitch][GREEN] blue:RGBPitchMap[pitch][BLUE] alpha:ALPHA_MULT * octave];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
