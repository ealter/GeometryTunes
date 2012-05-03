#import <UIKit/UIKit.h>

@class GridView;

#define TOTAL_NUM_KEYS ((MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE)

@interface Piano : UIView

@property (nonatomic, retain) GridView *grid;
- (void)gridCellHasChanged; //Means that the note the piano is editing has changed

@end
