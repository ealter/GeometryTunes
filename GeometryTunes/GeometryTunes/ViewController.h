#import <UIKit/UIKit.h>
#import "GridView.h"
#import "PathListController.h"
#import "ProjectList.h"

@interface ViewController : UIViewController

typedef enum STATE
{
    NORMAL_STATE,
    PIANO_STATE,
    PATH_EDIT_STATE
} STATE;

@property STATE state;
@property (nonatomic, copy, readonly) NSString *currentFileName;
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

//Save & Load methods //TODO: put this stuff in its own module
- (IBAction)saveLoadEvent:(id)sender;
- (void)loadGridFromFile:(NSString *)fileName;
- (void)saveGridToFile:  (NSString *)fileName;
- (void)newGrid;
+ (NSString *)sanitizeProjectName:(NSString *)projectName; //Returns a new project name that can be used as part of a filename
+ (NSMutableArray *)gridNameList;
+ (NSString *)nthFileName:(NSInteger)i;

@end
