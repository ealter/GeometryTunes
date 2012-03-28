#import <Foundation/Foundation.h>
#import "noteTypes.h"

@class AVAudioPlayer;

@interface NotePlayer : NSObject
{
    AVAudioPlayer *players[(MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE];
}

- (id)init;
- (void)playNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;
- (void)stopAllNotes;

@end
