#import <UIKit/UIKit.h>

@class NotePath;
@class GridView;

@interface PathsView : UIView <NSCoding>

@property (retain) NSMutableDictionary *paths;
@property (retain) GridView *delegateGrid;
@property (retain) UIImage *pulseCircle;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) float tapDistanceTolerance; //Units are pixels^2. This is the maximum distance a touch can be from a node for it to register that the touch was meant for that node
@property (nonatomic) float removeDistanceTolerance;
@property (nonatomic, retain) NSString *currentPathName;
@property (nonatomic) NSTimeInterval speed;
@property (nonatomic, readonly) BOOL isPlaying;

- (void)addPath:(NSString *)pathName; //Adds the new path and sets the current path to it. If a path with that name already exists, this just sets the current path to it.
- (void)deletePath:(NSString *)pathName;

- (void)addNoteWithPos:(CGPoint)pos;
- (bool)removeNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;
- (void)play;
- (void)pause;
- (void)stop;

- (void)setGrid:(GridView*)grid;

- (void)playHasStopped;

- (void)pulseAt:(CGPoint)pos;

- (NSString *)nthPathName:(NSInteger)index;
- (void)renamePathFrom:(NSString *)oldName to:(NSString *)newName;
- (void)setLooping:(BOOL)doesLoop pathName:(NSString*)pathName;
- (BOOL)pathDoesLoop:(NSString*)pathName;

- (UIImageView *)getPathFollowerAtPos:(CGPoint)pos;
- (void)movePathFollower:(UIImageView *)follower pos:(CGPoint)pos delegate:(id)delegate;

- (void)reset;

@end
