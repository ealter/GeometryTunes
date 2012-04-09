#import <UIKit/UIKit.h>
#import "noteTypes.h"
#import "NotePlayer.h"

@class GridView;
@class scrollViewWithButtons;

#define TOTAL_NUM_KEYS ((MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE)

@interface Piano : UIView
{
    UIButton *notes[TOTAL_NUM_KEYS];
    GridView *delegate;
}

@property (retain) NotePlayer *notePlayer;
@property (readonly, retain) scrollViewWithButtons *piano;
@property (readonly) CGPoint contentOffset;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;

- (void)noteClearEvent;

- (void)gridCellHasChanged; //Means that the note the piano is editing has changed

- (void)boldNotes:(NSMutableArray*)notes;

- (int)indexOfPitch:(unsigned)pitch octave:(unsigned)octave; //Returns the index in the notes array. If it is not in the array, it returns -1

+ (bool)isBlackNote:(int)pitch;
+ (int)whiteNotesFromPitch:(unsigned)pitch numNotes:(unsigned)numNotes;


@end
