//
//  noteColor.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/12/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "noteColor.h"
#import "noteTypes.h"

@implementation noteColor

#define RED   0
#define GREEN 1
#define BLUE  2
#define ALPHA_MULT (1.0/(MAX_OCTAVE - MIN_OCTAVE + 1))

static const float RGBPitchMap[11][3] =
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

+ (UIColor*)colorFromNoteWithPitch:(int)pitch octave:(int)octave {
    float red = RGBPitchMap[pitch][RED];
    float green = RGBPitchMap[pitch][GREEN];
    float blue = RGBPitchMap[pitch][BLUE];
    return [UIColor colorWithRed:red green:green blue:blue alpha:(1 - ALPHA_MULT * (octave - MIN_OCTAVE))];
}

@end
