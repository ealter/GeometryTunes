#import "scrollViewWithButtons.h"

@implementation scrollViewWithButtons

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return ![view isKindOfClass:[UISlider class]];
}

@end
