//
//  NotePlayer.m
//  GeometryTunes
//
//  Created by Music2 on 3/20/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "NotePlayer.h"

@implementation NotePlayer

#import "Piano.h"
#import "AVFoundation/AVFoundation.h"

static int getPlayerIndex(unsigned pitch, unsigned octave)
{
    assert(pitch <= NOTES_IN_OCTAVE);
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    return (octave - MIN_OCTAVE) * NOTES_IN_OCTAVE - pitch;
}

- (id)init
{
    self = [super init];
    if (self) {
        const int numNotes = (MAX_OCTAVE - MIN_OCTAVE) * NOTES_IN_OCTAVE;
        assert(numNotes >= 0);
        players = [[NSMutableArray alloc]initWithCapacity:numNotes];
        char* pitchNames[] = {"C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"};
        assert(sizeof(pitchNames)/sizeof(pitchNames[0]) == NOTES_IN_OCTAVE);
        for(int i=MIN_OCTAVE; i<=MAX_OCTAVE; i++)
        {
            for(int j=0; j<NOTES_IN_OCTAVE; j++)
            {
                NSString *fname = [fname initWithFormat:@"%s%d", pitchNames[j], i];
                NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:fname ofType:@"wav"];
                assert(soundFilePath);
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
                AVAudioPlayer* p = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
                
                [p prepareToPlay];
                [players addObject:p];
            }
        }
    }
    return self;
}

- (void)playNoteWithPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(octave >= MIN_OCTAVE && octave <= MAX_OCTAVE);
    assert(pitch < NOTES_IN_OCTAVE);
    AVAudioPlayer *note = [players objectAtIndex:getPlayerIndex(pitch, octave)];
    assert(note);
    if([note isPlaying])
        note.currentTime = 0;
    [note play];
}

@end
