//
//  NotePlayer.h
//  GeometryTunes
//
//  Created by Music2 on 3/20/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotePlayer : NSObject
{
    NSMutableArray *players;
}

- (id)init;
- (void)playNoteWithPitch:(unsigned) pitch octave: (unsigned) octave;
- (void)stopAllNotes;

@end
