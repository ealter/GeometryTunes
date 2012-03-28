#import <UIKit/UIKit.h>
#import "NotePath.h"

@interface PathsView : UIView

@property (readonly, retain) NotePath *path;

- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;
@end
