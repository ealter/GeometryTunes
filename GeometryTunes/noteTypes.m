//
//  noteTypes.m
//  GeometryTunes
//
//  Created by Lion User on 3/24/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "noteTypes.h"

@implementation noteTypes

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

@end
