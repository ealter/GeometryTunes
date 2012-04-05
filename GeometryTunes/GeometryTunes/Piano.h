#import <UIKit/UIKit.h>
#import "noteTypes.h"
#import "NotePlayer.h"

@class GridView;
@class scrollViewWithButtons;

@interface Piano : UIView
{
    NSMutableArray *notes;
    GridView *delegate;
    bool addNote; //True if the next note should be new
}

@property (retain) NotePlayer *notePlayer;
@property (readonly, retain) scrollViewWithButtons *piano;
@property (readonly) CGPoint contentOffset;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;
- (void)noteClearEvent;
- (void)noteAddEvent;

- (void)gridCellHasChanged; //Means that the note the piano is editing has changed

- (void)removeFromSuperview;

- (int)numWhiteNotes;

- (void)boldNotes:(NSMutableArray*)notes;

- (int)indexOfPitch:(unsigned)pitch octave:(unsigned)octave; //Returns the index in the notes array. If it is not in the array, it returns -1

+ (bool)isBlackNote:(int)pitch;
+ (int)whiteNotesFromPitch:(unsigned)pitch numNotes:(unsigned)numNotes;


@end
