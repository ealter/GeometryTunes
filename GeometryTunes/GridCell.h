#import <UIKit/UIKit.h>
#import "noteTypes.h"

@interface GridCell : UIView
{
    pianoNote note;
}

- (void)setNote:(pianoNote)note;
- (pianoNote)note;

@end
