//
//  noteTypes.h
//  GeometryTunes
//
//  Created by Lion User on 3/23/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#ifndef GeometryTunes_noteTypes_h
#define GeometryTunes_noteTypes_h

#define MIN_OCTAVE 1
#define MAX_OCTAVE 7
#define INITIAL_PIANO_OCTAVE 4
#define NOTES_IN_OCTAVE 12
#define NO_PIANO_NOTE (-1)

typedef unsigned pianoNote; //The least-significant byte is the pitch in the scale (C=0, B=11).
                            //The next least-significant byte is the octave number
                            //The rest of the integer should be 0's
                            //A value of all 1's (i.e. -1) signifies a non-existant note

#endif
