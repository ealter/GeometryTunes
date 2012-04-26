#import "Cells.h"

@implementation Cells

@dynamic cellId;
@synthesize xCoordinate;
@synthesize yCoordinate;

- (void)setYCoord:(NSNumber *)yCoord
{
    yCoordinate = yCoord;
}
- (void)setXCoord:(NSNumber *)xCoord
{
    xCoordinate = xCoord;
}
- (NSNumber *)getYCoord
{
    return yCoordinate;
}
- (NSNumber *)getXCoord
{
    return xCoordinate;
}

@end
