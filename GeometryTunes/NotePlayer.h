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
