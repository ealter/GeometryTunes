#import <UIKit/UIKit.h>
#import "noteTypes.h"

@class ViewController;
@class MidiController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) MidiController *midi;

- (void)noteOn: (midinote)note;
- (void)noteOff:(midinote)note;

@end
