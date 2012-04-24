//
//  Cells.h
//  GeometryTunes
//
//  Created by Music2 on 4/19/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Cells : NSManagedObject

@property (nonatomic, retain) NSNumber *cellId;
@property (nonatomic, retain) NSNumber *xCoordinate;

@end
