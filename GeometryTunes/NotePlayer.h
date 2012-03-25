//
//  NotePlayer.h
//  GeometryTunes
//
//  Created by Music2 on 3/20/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "noteTypes.h"

@interface NotePlayer : NSObject
{
    AVAudioPlayer *players[(MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE];
}

- (id)init;
- (void)playNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;
- (void)stopAllNotes;

@end
