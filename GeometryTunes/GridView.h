#import <UIKit/UIKit.h>
#import "Piano.h"
#import "PathsView.h"

@interface GridView : UIView
{
    Piano *piano;
    NSMutableArray *cells; //2D array: 1st index is row
                           //          2nd index is col
    PathsView *pathView;
}

@property (nonatomic) int numBoxesX;
@property (nonatomic) int numBoxesY;

@property (retain) id delegate; //A ViewController

@property (nonatomic) int pianoOctave;

@property (nonatomic) unsigned currentX; //These are used when editing a square
@property (nonatomic) unsigned currentY;

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapButtonRecognizer;

- (void)sharedInit;

- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave; //Uses the currentX and currentY
- (void)changeNoteWithPitch:(unsigned)pitch octave:(unsigned)octave x:(unsigned) x y:(unsigned)y;
//These set the last note

- (void)clearNote;
- (void)clearNoteAtX:(unsigned)x y:(unsigned)y;

- (float)getBoxWidth;
- (float)getBoxHeight;

- (void)drawGrid:(CGContextRef)context;

- (CGPoint)getBoxFromCoords:(CGPoint)pos;
- (NSMutableArray*)getNotesFromCoords:(CGPoint)pos;

- (void)playPathWithSpeedFactor:(float)factor reversed:(bool)reverse;
- (void)pausePlayback;
- (void)stopPlayback;

- (void)changeToNormalState;

@end