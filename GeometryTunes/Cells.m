//
//  Cells.m
//  GeometryTunes
//
//  Created by Music2 on 4/19/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

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
