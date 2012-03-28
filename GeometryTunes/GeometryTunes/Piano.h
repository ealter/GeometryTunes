#import <UIKit/UIKit.h>
#import "NotePlayer.h"
#import "noteTypes.h"

@interface Piano : UIView
{
    NSMutableArray *notes;
    int numNotes;
    int numWhiteNotes;
    id delegate; //A Gridview type
    bool addNote; //True if the next note should be new
}

@property unsigned octave;
@property (retain) NotePlayer *notePlayer;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;
- (void)OctaveChanged:(id)sender;
- (void)noteClearEvent;
- (void)noteAddEvent;

+ (bool)isBlackNote:(int)pitch;
- (void)removeFromSuperview;

@end
