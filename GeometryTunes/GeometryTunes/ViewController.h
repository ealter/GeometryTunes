#import <UIKit/UIKit.h>
#import "GridView.h"
#import "PathListController.h"

@interface ViewController : UIViewController

typedef enum STATE
{
    NORMAL_STATE,
    PIANO_STATE,
    PATH_EDIT_STATE
} STATE;

@property STATE state;
@property (nonatomic, retain) IBOutlet GridView *grid; 
@property (nonatomic, retain) IBOutlet UIButton *editPathBtn;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel *tempoTextField;
@property (nonatomic, retain) IBOutlet UIScrollView *helpMenu;
@property (nonatomic, retain) IBOutlet UISegmentedControl *pathModifyType;
@property float tempo;
//@property CGPDFDocumentRef document;

@property (strong, nonatomic) PathListController *pathList;
@property (strong, nonatomic) UIPopoverController *pathListPopover;

//Playback methods
- (IBAction)playPauseEvent:(id)sender;
- (IBAction)stopEvent:(id)sender;
- (void)setPlayStateToStopped;
- (IBAction)sliderValueChanged:(id)sender;

//Path methods
- (IBAction)editPathEvent:(id)sender; 
- (BOOL)pathEditStateIsAdding;
- (void)pathHasBeenSelected;

- (void)changeStateToNormal:(bool)informGrid;

//Save & Load methods
- (void)loadGridFromFile:(NSString *)fileName;
- (void)saveGridToFile:  (NSString *)fileName;
+ (NSMutableArray *)gridNameList;

@end
