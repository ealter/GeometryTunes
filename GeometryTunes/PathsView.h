#import <UIKit/UIKit.h>

@class NotePath;
@class NotePlayer;
@class GridView;

@interface PathsView : UIView

@property (readonly, retain) NotePath *path;

- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

- (void)setSpeedFactor:(float)factor;

- (void)setDelegateGrid:(GridView*)grid;

@end
