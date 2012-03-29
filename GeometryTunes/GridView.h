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

@property (nonatomic) int numBoxesX;
@property (nonatomic) int numBoxesY;

@property (retain) ViewController *delegate;

@property (nonatomic) int pianoOctave;

@property (nonatomic) unsigned currentX; //These are used when editing a square
@property (nonatomic) unsigned currentY;

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapButtonRecognizer; //Not used anymore?
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (void)sharedInit;

- (void) resetPath; 

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave appendNote:(bool)appendNote; //Uses the currentX and currentY
- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned) x y:(unsigned)y appendNote:(bool)appendNote;
//These set the last note

- (NSMutableArray*)notes;
- (NSMutableArray*)notesAtX:(unsigned)x y:(unsigned)y;

- (void)clearNote;
- (void)clearNoteAtX:(unsigned)x y:(unsigned)y;

- (void)playNote;
- (void)playNoteAtX:(unsigned)x y:(unsigned)y;

- (float)boxWidth;
- (float)boxHeight;

- (void)drawGrid;

- (CellPos)getBoxFromCoords:(CGPoint)pos;

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse;
- (void)pausePlayback;
- (void)stopPlayback;

- (void)changeToNormalState;

@end