#import <Foundation/Foundation.h>
@class NotePlayer;
@class GridView;
@class PathsView;

@interface NotePath : NSObject
{
    UIBezierPath* path;
    UIBezierPath* pulse;
    NSTimer *playbackTimer;
    bool shouldChangeSpeed;
}

 //Contains NSValue representations of CGPoints of path vertices
@property (readonly, retain) NSMutableArray *notes;
@property (nonatomic) int playbackPosition; //The index in the NSMutableArray. 0 means that we are at the beginning of the path
@property (retain) NotePlayer *player;
@property (retain) GridView* delegateGrid;
@property (retain) PathsView *pathView;
@property (readonly) BOOL isPlaying;
@property (nonatomic, retain) UIImageView *pathFollower;
@property uint64_t mostRecentAccess;

@property (nonatomic) float speedFactor;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)removeAllNotes;
- (void)updateAndDisplayPath:(CGContextRef)context;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

- (float)distanceFrom:(CGPoint)pos noteIndex:(int)i; //Returns the sum of the squares
- (int)closestNodeFrom:(CGPoint)pos; //returns the index in the note array of the closest node to that point

@end
