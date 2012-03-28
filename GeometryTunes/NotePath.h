#import <Foundation/Foundation.h>
#import "NotePlayer.h"
@class GridView;

@interface NotePath : NSObject
{
    UIBezierPath* path;
    UIBezierPath* pulse;
    NSTimer *playbackTimer;
}

 //Contains NSValue representations of CGPoints of path vertices
@property (readonly, retain) NSMutableArray *notes;
@property (readonly) int numNotes;
@property int playbackPosition;
@property (retain) NotePlayer *player;
@property (retain) GridView* delegateGrid;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)updateAndDisplayPath:(CGContextRef)context;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

@end
