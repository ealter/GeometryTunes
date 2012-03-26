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

#define HUE 0
#define SAT 1
#define BRIGHT 2
#define ALPHA 3
#define BRIGHTNESS_FACTOR 0.1

static const float HSBAPitchMap[12][4] =
{
    {0.0,   1.0, 1.0, 1.0},
    {0.077, 1.0, 1.0, 1.0},   
    {0.122, 1.0, 1.0, 1.0},   
    {0.160, 1.0, 1.0, 1.0},
    {0.198, 1.0, 1.0, 1.0},
    {0.343, 1.0, 1.0, 1.0},
    {0.449, 1.0, 1.0, 1.0},
    {0.54,  1.0, 1.0, 1.0},
    {0.594, 1.0, 1.0, 1.0},
    {0.758, 1.0, 1.0, 1.0},
    {0.835, 1.0, 1.0, 1.0},
    {0.995, 0.4, 1.0, 1.0}
};

+ (UIColor*)colorFromNoteWithPitch:(int)pitch octave:(int)octave {
    float hue = HSBAPitchMap[pitch][HUE];
    float sat = HSBAPitchMap[pitch][SAT];
    float bright = HSBAPitchMap[pitch][BRIGHT];
    float alpha = HSBAPitchMap[pitch][ALPHA];
    bright -= BRIGHTNESS_FACTOR * (MAX_OCTAVE - octave);
    UIColor *color = [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
    return color;
}

@end
