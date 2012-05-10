#import "noteTypes.h"

@implementation noteTypes

#if MIN_OCTAVE > MAX_OCTAVE
    #warning "The minimum octave is greater that the maximum octave"
#endif

+ (BOOL)isValidPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    return (pitch < NOTES_IN_OCTAVE) && (octave >= MIN_OCTAVE) && (octave <= MAX_OCTAVE);
}

+ (midinote)midinoteOfPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert([self isValidPitch:pitch octave:octave]);
    return pitch + octave * NOTES_IN_OCTAVE;
}

@end
