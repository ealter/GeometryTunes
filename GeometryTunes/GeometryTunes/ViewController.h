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
@property (nonatomic, retain, readonly) GridProjects *gridProjects;
@property (nonatomic, retain) IBOutlet GridView *grid; 
@property (nonatomic, retain) IBOutlet UIButton *editPathBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel *tempoTextField;
@property NSTimeInterval tempo; /* The amount of time in between notes */

@property (strong, nonatomic) PathListController *pathList;
@property (strong, nonatomic) UIPopoverController *pathListPopover;
@property (strong, nonatomic) ProjectList *projectList;
@property (strong, nonatomic) UIPopoverController *projectListPopover;

//Playback methods
- (IBAction)playPauseEvent:(id)sender;
- (IBAction)stopEvent:(id)sender; /* Fired by the view when the user clicks the stop button */
- (void)setPlayStateToStopped;    /* Call this method when the playback was stopped by the program, rather than the user */
- (IBAction)sliderValueChanged:(id)sender;

//Path methods
- (IBAction)editPathEvent:(id)sender;
- (void)pathHasBeenSelected; /* A callback method indicating that the PathListController has selected a path */

- (void)changeStateToNormal:(bool)informGrid; /* Changes the STATE to NORMAL_STATE. If informGrid is true, this calls the changeStateToNormal method fot the GridView (yes, this is a hacky way of doing it). */

//Save & Load methods
- (IBAction)saveLoadEvent:(id)sender;
- (BOOL)saveGridToFile:(NSString *)fileName; //returns true on success
- (void)loadGridFromFile:(NSString *)fileName;
- (NSString*)currentFileName;
- (void)newGrid;

@end
