#import "NotePlayer.h"
#import "noteTypes.h"
#import <AudioToolBox/AudioServices.h>
#import "AppDelegate.h"

@implementation NotePlayer

static int getPlayerIndex(unsigned pitch, unsigned octave)
{
    assert(pitch <= NOTES_IN_OCTAVE);
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    return (octave - MIN_OCTAVE) * NOTES_IN_OCTAVE + pitch;
}

static unsigned midiNote(unsigned pitch, unsigned octave)
{
    return octave * NOTES_IN_OCTAVE + pitch;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //put initialization code here
    }
    return self;
}

- (void)playNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave duration:(NSTimeInterval)duration
{
    NSLog(@"   play octave %u", octave);
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    assert(pitch < NOTES_IN_OCTAVE);
    NSNumber *note = [NSNumber numberWithInt:midiNote(pitch, octave)];
    [self noteOn:note];
    [self performSelector:@selector(noteOff:) withObject:note afterDelay:duration];
}

- (void)stopAllNotes
{
    for(int octave = MIN_OCTAVE; octave <= MAX_OCTAVE; octave++)
    {
        for(int pitch = 0; pitch < NOTES_IN_OCTAVE; pitch++)
        {
            [self noteOff:[NSNumber numberWithInt:midiNote(pitch, octave)]];
        }
    }
}

- (void)noteOn:(NSNumber *)note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, [note intValue], 0x7F);
}

- (void)noteOff:(NSNumber *)note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.api->setChannelMessage (appDelegate.handle, 0x00, 0x90, [note intValue], 0x00);
}

@end
