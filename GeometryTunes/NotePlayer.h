#import <Foundation/Foundation.h>

@interface NotePlayer : NSObject

+ (void)playNoteWithPitch:(unsigned)pitch octave:(unsigned)octave duration:(NSTimeInterval)duration;
+ (void)stopAllNotes;

+ (void)noteOn:(NSNumber *)midiNote;
+ (void)noteOff:(NSNumber *)midiNote;

@end
