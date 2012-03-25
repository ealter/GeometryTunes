//
//  NotePlayer.m
//  GeometryTunes
//
//  Created by Music2 on 3/20/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "NotePlayer.h"
#import "noteTypes.h"

@implementation NotePlayer

static int getPlayerIndex(unsigned pitch, unsigned octave)
{
    assert(pitch <= NOTES_IN_OCTAVE);
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    return (octave - MIN_OCTAVE) * NOTES_IN_OCTAVE + pitch;
}

- (void)loadSoundWithPitch:(unsigned)pitch octave:(unsigned)octave
{
    assert(pitch < NOTES_IN_OCTAVE);
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    char* pitchNames[] = {"C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"};
    assert(sizeof(pitchNames)/sizeof(pitchNames[0]) == NOTES_IN_OCTAVE);
    
    NSString *fname = [[NSString alloc]initWithFormat:@"%s%d", pitchNames[pitch], octave];
    NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:fname ofType:@"mp3"];
    assert(soundFilePath);
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    AVAudioPlayer* p = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    
    players[getPlayerIndex(pitch, octave)] = p;
}

- (id)init
{
    self = [super init];
    if (self) {
        for(int i=MIN_OCTAVE; i<=MAX_OCTAVE; i++)
        {
            for(int j=0; j<NOTES_IN_OCTAVE; j++)
            {
                [self loadSoundWithPitch:j octave:i];
            }
        }
    }
    return self;
}

- (void)playNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    assert(pitch < NOTES_IN_OCTAVE);
    AVAudioPlayer *note = players[getPlayerIndex(pitch, octave)];
    assert(note);
    if([note isPlaying])
        note.currentTime = 0;
    [note play];
}

- (void)stopAllNotes
{
    for(int i=0; i<(MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE; i++)
    {
        AVAudioPlayer *p = players[i];
        if([p isPlaying])
        {
            [p pause];
            p.currentTime = 0;
        }
    }
}

@end
