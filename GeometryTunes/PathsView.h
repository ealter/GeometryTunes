#import <UIKit/UIKit.h>
#import "NotePath.h"
@class NotePlayer;

@interface PathsView : UIView

@property (readonly, retain) NotePath *path;

- (void)addNoteWithPos:(CGPoint)pos;

- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;
@end
