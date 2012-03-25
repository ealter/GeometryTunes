#import <UIKit/UIKit.h>
#import "NotePlayer.h"
#import "noteTypes.h"

@interface Piano : UIView
{
    NSMutableArray *notes;
    int numNotes;
    int numWhiteNotes;
    id delegate; //A Gridview type
    NotePlayer *notePlayer;
}

@property unsigned octave;

- (id)sharedInit;
- (id)initWithFrame:(CGRect)frame delegate:(id)delagate;

- (void)KeyClicked:(id)sender;
- (void)OctaveChanged:(id)sender;

+ (bool)isBlackNote:(int)pitch;

@end
