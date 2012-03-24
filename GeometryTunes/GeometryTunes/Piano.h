//
//  Piano.h
//  GeometryTunes
//
//  Created by Music2 on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotePlayer.h"
#include "noteTypes.h"

@interface Piano : UIView
{
    NSMutableArray *notes;
    int numNotes;
    int numWhiteNotes;
    id delegate;
    NotePlayer *notePlayer;
}

@property unsigned octave;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;
- (void)OctaveChanged:(id)sender;

+ (int)octaveOfPianoNote:(pianoNote)p;
+ (int)pitchOfPianoNote: (pianoNote)p;
+ (pianoNote)getPianoNoteOfPitch:(int)pitch Octave:(int)octave;

+ (bool)isBlackNote:(int)pitch;

@end
