#import "NotePlayer.h"
#import "noteTypes.h"
#import <AudioToolBox/AudioServices.h>

@implementation NotePlayer

@synthesize api, handle;

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

- (void)initMidiPlayer
{
    // Override point for customization after application launch.
    
	AudioSessionInitialize(NULL, NULL, NULL, NULL); //TODO: maybe make the last parameter self?
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    
	AudioSessionSetActive(true);
    
	Float32 bufferSize = 0.005;
	SInt32 size = sizeof(bufferSize);
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, size, &bufferSize);
    
    
	api = crmdLoad ();
    
	CRMD_ERR err = CRMD_OK;
	
	if (err == CRMD_OK) {
		// initialize
		NSString *path = [[NSBundle mainBundle] pathForResource:@"crsynth" ofType:@"dlsc"];
		const char *lib = [path cStringUsingEncoding:NSASCIIStringEncoding];
        const unsigned char key[64] = {
            0xE1, 0xF1, 0x4B, 0xF9, 0x39, 0xA7, 0x6C, 0x32,
            0x65, 0x73, 0x1B, 0xF5, 0xD0, 0x00, 0xD8, 0xAD,
            0x70, 0x07, 0x52, 0xF3, 0x22, 0x68, 0x52, 0xF2,
            0x6B, 0xE6, 0x4A, 0x54, 0x0E, 0xE4, 0xA6, 0xE6,
            0x4B, 0xF0, 0x81, 0x82, 0x33, 0xE7, 0xF9, 0xA3,
            0xB1, 0x39, 0xFE, 0xB1, 0x7D, 0xAA, 0xA9, 0x44,
            0x74, 0x68, 0xF7, 0x79, 0xD0, 0xF2, 0xED, 0x2D,
            0xE4, 0x62, 0x89, 0x45, 0x9F, 0xC7, 0xA5, 0x62,
		};
        err = api->initializeWithSoundLib (&handle, nil, nil, lib, NULL, key);
	}
    
	if (err == CRMD_OK) {
		// revweb on
		int value = 1;
		err = api->ctrl (handle, CRMD_CTRL_SET_REVERB, &value, sizeof (value));
	}
    
	if (err == CRMD_OK) {
		// open wave output device
		err = api->open (handle, NULL, NULL);
	}
    
	if (err == CRMD_OK) {
		// start realtime MIDI
		err = api->start (handle);
	}

}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initMidiPlayer];
    }
    return self;
}

- (void)playNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave duration:(NSTimeInterval)duration
{
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    assert(pitch < NOTES_IN_OCTAVE);
    NSNumber *note = [NSNumber numberWithInt:midiNote(pitch, octave)];
    [self noteOn:note];
    [self performSelector:@selector(noteOff:) withObject:note afterDelay:duration];
}

- (void)stopAllNotes
{
    for(int i=0; i<(MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE; i++)
    {
        //TODO: implement this
    }
}

- (void)noteOn:(NSNumber *)note
{
    api->setChannelMessage (handle, 0x00, 0x90, [note intValue], 0x7F);
}

- (void)noteOff:(NSNumber *)note
{
    api->setChannelMessage (handle, 0x00, 0x90, [note intValue], 0x00);
}

@end
