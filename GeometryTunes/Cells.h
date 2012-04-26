#import <Foundation/Foundation.h>

@interface Cells : NSObject

@property (nonatomic, retain) NSNumber *cellId;
@property (nonatomic, retain) NSNumber *xCoordinate;
@property (nonatomic, retain) NSNumber *yCoordinate;

- (void)setYCoord:(NSNumber *)yCoord;
- (void)setXCoord:(NSNumber *)xCoord;
- (NSNumber *)getYCoord;
- (NSNumber *)getXCoord;

@end
