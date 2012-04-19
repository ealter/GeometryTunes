#import <UIKit/UIKit.h>

@class NotePath;
@class NotePlayer;
@class GridView;

@interface PathsView : UIView

@property (retain) NSMutableDictionary *paths;
@property (retain) GridView *delegateGrid;
@property (retain) UIImage *pulseCircle;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) float tapDistanceTolerance; //Units are pixels^2. This is the maximum distance a touch can be from a node for it to register that the touch was meant for that node
@property (nonatomic, retain) NSString *currentPathName;
@property (nonatomic) float speedFactor;

- (void)addPath:(NSString *)pathName; //Adds the new path and sets the current path to it. If a path with that name already exists, this just sets the current path to it.
- (void)deletePath:(NSString *)pathName;

- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;
- (void)playWithSpeedFactor:(float)factor notePlayer:(NotePlayer*)player;
- (void)pause;
- (void)stop;

- (void)setGrid:(GridView*)grid;

- (void)playHasStopped:(NotePath *)path;

- (void)pulseAt:(CGPoint)pos;

- (NSString *)nthPathName:(NSInteger)index;

- (UIImageView *)getPathFollowerAtPos:(CGPoint)pos;
- (void)movePathFollower:(UIImageView *)follower pos:(CGPoint)pos delegate:(id)delegate;

@end
