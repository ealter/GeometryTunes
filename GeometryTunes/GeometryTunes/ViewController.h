#import <UIKit/UIKit.h>

@class GridProjects;
@class GridView;
@class ProjectList;
@class PathListController;

@interface ViewController : UIViewController

typedef enum STATE
{
    NORMAL_STATE,
    PIANO_STATE,
    PATH_EDIT_STATE
} STATE;

@property STATE state;
@property (nonatomic, retain, readonly) GridProjects *gridProjects;
@property (nonatomic, retain) IBOutlet GridView *grid; 
@property (nonatomic, retain) IBOutlet UIButton *editPathBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel *tempoTextField;
@property float tempo;
//@property CGPDFDocumentRef document;

@property (strong, nonatomic) PathListController *pathList;
@property (strong, nonatomic) UIPopoverController *pathListPopover;
@property (strong, nonatomic) ProjectList *projectList;
@property (strong, nonatomic) UIPopoverController *projectListPopover;

//Playback methods
- (IBAction)playPauseEvent:(id)sender;
- (IBAction)stopEvent:(id)sender;
- (void)setPlayStateToStopped;
- (IBAction)sliderValueChanged:(id)sender;

//Path methods
- (IBAction)editPathEvent:(id)sender; 
- (void)pathHasBeenSelected;

- (void)changeStateToNormal:(bool)informGrid;

//Save & Load methods
- (IBAction)saveLoadEvent:(id)sender;
- (BOOL)saveGridToFile:(NSString *)fileName; //returns true on success
- (void)loadGridFromFile:(NSString *)fileName;
- (NSString*)currentFileName;
- (void)newGrid;

@end
