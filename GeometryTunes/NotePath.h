#import <Foundation/Foundation.h>
@class GridView;
@class PathsView;

@interface NotePath : NSObject <NSCoding>

@property (nonatomic) int playbackPosition; //The index in the NSMutableArray. 0 means that we are at the beginning of the path
@property (nonatomic, retain) PathsView *pathView;
@property (readonly) BOOL isPlaying;
@property (nonatomic) BOOL doesLoop; //determines whether the path loops. Default is false
@property uint64_t mostRecentAccess;
@property (nonatomic) bool shouldChangeSpeed;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)removeAllNotes;
- (int) numNotes;
- (void)updateAndDisplayPath:(CGContextRef)context dashed:(BOOL)isDashed;
- (void)play;
- (void)pause;
- (void)stop;

- (float)distanceFrom:(CGPoint)pos noteIndex:(int)i; //Returns the sum of the squares
- (int)closestNodeFrom:(CGPoint)pos; //returns the index in the note array of the closest node to that point

@end
