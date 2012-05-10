#import "NotePlayer.h"
#import "noteTypes.h"
#import <AudioToolBox/AudioServices.h>
#import "AppDelegate.h"

@implementation NotePlayer

+ (void)playNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave duration:(NSTimeInterval)duration
{
    NSNumber *note = [NSNumber numberWithInt:[noteTypes midinoteOfPitch:pitch octave:octave]];
    [self noteOn:note];
    [self performSelector:@selector(noteOff:) withObject:note afterDelay:duration];
}

+ (void)stopAllNotes
{
    for(int octave = MIN_OCTAVE; octave <= MAX_OCTAVE; octave++) {
        for(int pitch = 0; pitch < NOTES_IN_OCTAVE; pitch++) {
            [self noteOff:[NSNumber numberWithInt:[noteTypes midinoteOfPitch:pitch octave:octave]]];
        }
    }
}

+ (void)noteOn:(NSNumber *)note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate noteOn:[note unsignedIntValue]];
}

+ (void)noteOff:(NSNumber *)note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate noteOff:[note unsignedIntValue]];
}

@end
