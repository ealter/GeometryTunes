//
//  Piano.h
//  GeometryTunes
//
//  Created by Music2 on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Piano : UIView
{
    NSMutableArray *notes;
    int numNotes;
    int numWhiteNotes;
}
typedef unsigned pianoNote; //The least-significant byte is the pitch in the scale (C=0, B=11).
                            //The next least-significant byte is the octave number
                            //The rest of the integer should be 0's
                            //A value of all 1's (i.e. -1) signifies a non-existant note

#define MIN_OCTAVE 5
#define MAX_OCTAVE 5
#define NOTES_IN_OCTAVE 12

#define NO_PIANO_NOTE (-1)

@property unsigned octave;

- (id)sharedInit;

- (void)KeyClicked:(id)sender;
- (void)OctaveChanged:(id)sender;

+ (int)octaveOfPianoNote:(pianoNote)p;
+ (int)pitchOfPianoNote: (pianoNote)p;
+ (pianoNote)getPianoNoteOfPitch:(int)pitch Octave:(int)octave;

+ (bool)isBlackNote:(int)pitch;

@end
