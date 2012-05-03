#import <UIKit/UIKit.h>

/* Represents a grid of GridCells. Provides functionality to modify the cells and delegates out various other tasks. Rather than being a module, this class acts as a singular class that moderates the interactions between other classes. */

@class PathsView;
@class ViewController;
@class GridCell;
@class Piano;

@interface GridView : UIView <NSCoding>

//Represents a coordinate system for the grid (0,0) is top left. (1,0) is one to the right of that
typedef struct CellPos {
    unsigned x;
    unsigned y;
} CellPos;

@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain, readonly) PathsView *pathView;
@property (nonatomic, readonly) CellPos currentCell; //Used when editing a square

//The following methods use the currentCell
- (void)addNoteWithPitch:   (unsigned)pitch octave:(unsigned)octave;
- (void)removeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave;
- (NSMutableArray*)notes;
- (void)updateDisplayAtCurrentCell;
- (void)clearNote;

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