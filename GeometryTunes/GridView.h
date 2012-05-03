#import <UIKit/UIKit.h>

@class PathsView;
@class ViewController;
@class GridCell;
@class Piano;

@interface GridView : UIView <NSCoding>
{
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row
                           //          2nd index is col
}

//typedef CGPoint CellPos; //Represents a coordinate system for the grid (0,0) is top left. (1,0) is one to the right of that
typedef struct CellPos {
    unsigned x;
    unsigned y;
} CellPos;

+ (CellPos)cellPosMakeX:(unsigned)x y:(unsigned) y;

@property (nonatomic) CellPos numBoxes;

@property (nonatomic, retain) ViewController *delegate;
@property (nonatomic, retain) PathsView *pathView;

@property (nonatomic, readonly) CellPos currentCell; //Used when editing a square

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (void)addNoteWithPitch:   (unsigned)pitch octave:(unsigned)octave;
- (void)removeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;

- (NSMutableArray*)notes;
- (NSMutableArray*)notesAtCell:(CellPos)cellPos;

- (void)updateDisplayAtCurrentCell;

- (void)clearNote;
- (void)clearNoteForCell:(CellPos)cellPos;

- (void)playNoteForDuration:(NSTimeInterval)duration;
- (void)playNoteForCell:(CellPos)cellPos duration:(NSTimeInterval)duration;

- (float)boxWidth;
- (float)boxHeight;

- (CellPos)getBoxFromCoords:(CGPoint)pos;

- (void)play;
- (void)setSpeed:(NSTimeInterval)speed;
- (void)pausePlayback;
- (void)stopPlayback;
- (void)playbackHasStopped;

- (void)changeToNormalState;

- (void)changeCell:(GridCell *)cell isBold:(bool)isBold;
- (GridCell*)cellAtPos:(CellPos)cellPos;

- (void)reset;

@end