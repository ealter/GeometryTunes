#import <UIKit/UIKit.h>

@class PathsView;
@class PathListController;

@interface PathEditorController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic, copy) NSString *pathName;
@property (nonatomic, retain) PathsView *pathsView;
@property (nonatomic, retain) PathListController *pathList;

@end
