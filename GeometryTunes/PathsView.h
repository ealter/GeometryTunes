#import <UIKit/UIKit.h>

/* Provides a view for the NotePaths. Also provides an abstraction for interacting with the NotePaths */
@class NotePath;
@class GridView;

@interface PathsView : UIView <NSCoding>

@property (nonatomic, weak) GridView *grid; /* The class that makes the PathsView should initialize this */
@property (nonatomic, copy) NSString *currentPathName;
@property (nonatomic) NSTimeInterval speed;
@property (nonatomic, readonly) BOOL isPlaying;

- (BOOL)pathExists:(NSString *)pathName;
- (void)addPath:(NSString *)pathName; //Adds the new path and sets the current path to it. If a path with that name already exists, this just sets the current path to it.
- (void)deletePath:(NSString *)pathName;
- (int)numPaths;

/* The following methods use the current path */
- (void)addNoteWithPos:(CGPoint)pos;
- (bool)removeNoteWithPos:(CGPoint)pos;
- (void)removeAllNotes;

- (void)play;
- (void)pause;
- (void)stop;

- (void)playHasStopped;

- (void)pulseAt:(CGPoint)pos;

- (NSString *)nthPathName:(NSInteger)index;
- (void)renamePathFrom:(NSString *)oldName to:(NSString *)newName;
- (void)setLooping:(BOOL)doesLoop pathName:(NSString*)pathName;
- (BOOL)pathDoesLoop:(NSString*)pathName;

- (UIImageView *)getPathFollowerAtPos:(CGPoint)pos;
- (void)movePathFollower:(UIImageView *)follower pos:(CGPoint)pos delegate:(id)delegate;
- (void)setCurrentPathName:(NSString *)currentPathName updateAccessTime:(BOOL)updateAccessTime;
- (void)reset;

@end
