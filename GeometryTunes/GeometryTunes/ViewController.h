#import <UIKit/UIKit.h>

@class GridProjects;
@class GridView;
@class ProjectList;
@class PathListController;

@interface ViewController : UIViewController

typedef enum STATE
{
    NORMAL_STATE,   /* The default state of the application. This includes playback. */
    PIANO_STATE,    /* When the piano is visible and a cell is being edited */
    PATH_EDIT_STATE /* When the paths are being edited (i.e. adding or removing nodes) */
} STATE;

@property STATE state;
@property (nonatomic, retain) IBOutlet GridView *grid;
@property (nonatomic, retain) IBOutlet UILabel *pathLabel;
@property NSTimeInterval tempo; /* The amount of time in between notes */

//Playback methods
- (void)setPlayStateToStopped;    /* Call this method when the playback was stopped by the program, rather than the user */

//Path methods
- (void)pathHasBeenSelected; /* A callback method indicating that the PathListController has selected a path */
- (BOOL)pathEditStateIsAdding;
- (void)changePathLabel:(NSString *)pathName;

- (void)changeStateToNormal:(bool)informGrid; /* Changes the STATE to NORMAL_STATE. If informGrid is true, this calls the changeStateToNormal method fot the GridView (yes, this is a hacky way of doing it). */

//Save & Load methods
- (IBAction)saveLoadEvent:(id)sender;
- (BOOL)saveGridToFile:(NSString *)fileName; //returns true on success
- (void)loadGridFromFile:(NSString *)fileName;
- (NSString*)currentFileName;
- (void)newGrid;

@end
