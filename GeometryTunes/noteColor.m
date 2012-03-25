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

static const float HSBAPitchMap[12][4] =
{
    {0.0, 1.0, 1.0, 1.0},
    {0.055, 1.0, 0.75, 1.0},
    {0.166, 1.0, 0.5, 1.0},   
    {0.277, 1.0, 0.75, 1.0},
    {0.333, 1.0, 1.0, 1.0},
    {0.388, 1.0, 0.75, 1.0},
    {0.5, 1.0, 0.5, 1.0},
    {0.583, 1.0, 0.5, 1.0},
    {0.666, 1.0, 1.0, 1.0},
    {0.722, 1.0, 0.75, 1.0},
    {0.833, 1.0, 0.5, 1.0},
    {0.9, 1.0, 0.75, 1.0}
};

+ (UIColor*)colorFromNoteWithPitch:(int)pitch octave:(int)octave {
    float hue = HSBAPitchMap[pitch][HUE];
    float sat = HSBAPitchMap[pitch][SAT];
    float bright = HSBAPitchMap[pitch][BRIGHT];
    float alpha = HSBAPitchMap[pitch][ALPHA];
    UIColor *color = [[UIColor alloc] init];
    color = [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
    return color;
}

@end
