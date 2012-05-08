#import "NotePlayer.h"
#import "noteTypes.h"
#import <AudioToolBox/AudioServices.h>
#import "AppDelegate.h"
#import "MidiController.h"

@implementation NotePlayer

static int getPlayerIndex(unsigned pitch, unsigned octave)
{
    assert([noteTypes isValidPitch:pitch octave:octave]);
    return (octave - MIN_OCTAVE) * NOTES_IN_OCTAVE + pitch;
}

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
    [appDelegate.midi noteOn:[note unsignedIntValue]];
    NSLog(@"The note is %d", [note unsignedIntValue]);
    //appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, [note intValue], 0x7F);
}

+ (void)noteOff:(NSNumber *)note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.midi noteOff:[note unsignedIntValue]];
    //appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, [note intValue], 0x00);
}

@end
