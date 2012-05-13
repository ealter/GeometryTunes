#import <UIKit/UIKit.h>

@class GridView;

@interface Piano : UIView

@property (nonatomic, retain) GridView *grid;
- (void)gridCellHasChanged; //Means that the note the piano is editing has changed

@end
