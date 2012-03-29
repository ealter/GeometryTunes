#import <UIKit/UIKit.h>
#import "noteTypes.h"
#import "NotePlayer.h"

@class GridView;

@interface Piano : UIView
{
    NSMutableArray *notes;
    GridView *delegate;
    bool addNote; //True if the next note should be new
}

@property unsigned octave;
@property int pitchOffset;
@property (retain) NotePlayer *notePlayer;
@property (readonly) int numNotes;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;
- (void)OctaveChanged:(id)sender;
- (void)noteClearEvent;
- (void)noteAddEvent;

- (void)removeFromSuperview;

- (int)numWhiteNotes;

- (void)boldNotes:(NSMutableArray*)notes;

- (int)indexOfPitch:(unsigned)pitch octave:(unsigned)octave; //Returns the index in the notes array. If it is not in the array, it returns -1

+ (bool)isBlackNote:(int)pitch;
+ (int)whiteNotesFromPitch:(unsigned)pitch numNotes:(unsigned)numNotes;

@end
