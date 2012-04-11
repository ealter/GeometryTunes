#import <UIKit/UIKit.h>

@class NotePath;
@class NotePlayer;
@class GridView;

@interface PathsView : UIView

@property (retain) NotePath *path;
@property (retain) GridView *delegateGrid;
@property (retain) UIImage *pulseCircle;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) float tapDistanceTolerance; //Units are pixels^2. This is the maximum distance a touch can be from a node for it to register that the touch was meant for that node

- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

- (void)setSpeedFactor:(float)factor;

- (void)setGrid:(GridView*)grid;

- (void)playHasStopped:(NotePath *)path;

- (void)pulseAt:(CGPoint)pos;

@end
