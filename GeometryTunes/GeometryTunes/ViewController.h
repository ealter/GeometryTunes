#import <UIKit/UIKit.h>
#import "GridView.h"

@interface ViewController : UIViewController
{
    IBOutlet UISlider *speedSlider;  
    IBOutlet UILabel *speedTextField;
}

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
@property (nonatomic, retain) IBOutlet UISlider *speedSlider;
@property (nonatomic, retain) IBOutlet UILabel *speedTextField;

- (IBAction)playPauseEvent:(id)sender;
- (IBAction)stopEvent:(id)sender;
- (IBAction)rewindEvent:(id)sender;
- (IBAction)fastForwardEvent:(id)sender;
- (IBAction)editPathEvent:(id)sender;
- (IBAction)clearPathEvent:(id)sender; 
- (void)changeStateToNormal:(bool)informGrid;
- (void)setPlayStateToStopped;
- (IBAction) sliderValueChanged:(id)sender;

@end
