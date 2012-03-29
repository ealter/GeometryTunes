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

+ (bool)isBlackNote:(int)pitch;
+ (int)whiteNotesFromPitch:(unsigned)pitch numNotes:(unsigned)numNotes;

@end
