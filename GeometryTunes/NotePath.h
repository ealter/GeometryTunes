#import <Foundation/Foundation.h>
@class NotePlayer;
@class GridView;

@interface NotePath : NSObject
{
    UIBezierPath* path;
    UIBezierPath* pulse;
    NSTimer *playbackTimer;
    bool shouldChangeSpeed;
}

 //Contains NSValue representations of CGPoints of path vertices
@property (readonly, retain) NSMutableArray *notes;
@property int playbackPosition; //The index in the NSMutableArray. 0 means that we are at the beginning of the path
@property (retain) NotePlayer *player;
@property (retain) GridView* delegateGrid;

@property (nonatomic) float speedFactor;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)removeAllNotes;
- (void)updateAndDisplayPath:(CGContextRef)context;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

@end
