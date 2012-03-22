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
const float ALPHA_MULT = 0.2;

static float RGBPitchMap[11][3] =
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
    return [UIColor colorWithRed:RGBPitchMap[pitch][RED] green:RGBPitchMap[pitch][GREEN] blue:RGBPitchMap[pitch][BLUE] alpha:ALPHA_MULT * octave];
    
}

@end
