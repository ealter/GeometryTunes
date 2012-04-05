#import <Foundation/Foundation.h>
#import "noteTypes.h"
#import "crmd.h"

@interface NotePlayer : NSObject

- (id)init;
- (void)playNoteWithPitch:(unsigned)pitch octave:(unsigned)octave duration:(NSTimeInterval)duration;
- (void)stopAllNotes;

- (void)noteOn:(NSNumber *)midiNote;
- (void)noteOff:(NSNumber *)midiNote;

@property CRMD_HANDLE handle;
@property CRMD_FUNC *api;

@end
