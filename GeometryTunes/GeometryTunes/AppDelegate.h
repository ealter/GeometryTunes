#import <UIKit/UIKit.h>
#include "crmd.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property CRMD_HANDLE handle;
@property CRMD_FUNC *api;

@end
