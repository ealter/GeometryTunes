#import <Foundation/Foundation.h>

@interface noteTypes : NSObject

#define MIN_OCTAVE 2
#define MAX_OCTAVE 7
#define NOTES_IN_OCTAVE 12

/* True means to use the proprietary midi library that expires at the end of May */
#define MIDI_PIANO false

typedef UInt32 midinote;

+ (BOOL)isValidPitch:(unsigned)pitch octave:(unsigned)octave;
+ (midinote)midinoteOfPitch:(unsigned)pitch octave:(unsigned)octave;

@end
