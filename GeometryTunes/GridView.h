#import <UIKit/UIKit.h>
#import "Piano.h"

@class PathsView;
@class ViewController;

@interface GridView : UIView
{
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row
                           //          2nd index is col
    PathsView *pathView;
}

typedef CGPoint CellPos; //Represents a coordinate system for the grid (0,0) is top left. (1,0) is one to the right of that

@property (nonatomic) CellPos numBoxes;

@property (retain) ViewController *delegate;

@property (nonatomic) CellPos currentCell; //Used when editing a square

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapButtonRecognizer; //Not used anymore?
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (void)sharedInit;

- (void) resetPath; 

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave appendNote:(bool)appendNote; //Uses the currentCell
- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave cellPos:(CellPos)cellPos appendNote:(bool)appendNote;
//These set the last note

- (NSMutableArray*)notes;
- (NSMutableArray*)notesAtCell:(CellPos)cellPos;

- (void)clearNote;
- (void)clearNoteForCell:(CellPos)cellPos;

- (void)playNote;
- (void)playNoteForCell:(CellPos)cellPos;

- (float)boxWidth;
- (float)boxHeight;

- (void)drawGrid;

- (CellPos)getBoxFromCoords:(CGPoint)pos;

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse;
- (void)pausePlayback;
- (void)stopPlayback;

- (void)changeToNormalState;

@end