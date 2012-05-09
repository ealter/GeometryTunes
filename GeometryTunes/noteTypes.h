#import <Foundation/Foundation.h>

@interface noteTypes : NSObject

#define MIN_OCTAVE 2
#define MAX_OCTAVE 7
#define NOTES_IN_OCTAVE 12

//Only one of the following should be active
#define MIDI_PIANO
//#define MIDI_TROMBONE

typedef UInt32 midinote;

+ (BOOL)isValidPitch:(unsigned)pitch octave:(unsigned)octave;
+ (midinote)midinoteOfPitch:(unsigned)pitch octave:(unsigned)octave;

@end
