//
//  NotePath.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/23/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "NotePath.h"

@implementation NotePath

- (id)init 
{
    self = [super init];
    if (self) {
        notes = [[NSMutableArray alloc] init];
        numNotes = 0;
    }
    return self;
}

- (void)addNoteWithPos:(CGPoint)pos 
{
    [notes addObject:[NSValue valueWithCGPoint:pos]];
    numNotes++;
}

- (void)removeNoteAtIndex:(NSUInteger)index
{
    [notes removeObjectAtIndex:index];
    numNotes--;
}

- (void)buildPathFromArray:(NSMutableArray*)array
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    if (numNotes > 0) {
        [path moveToPoint:[[array objectAtIndex:0] CGPointValue]];
        for (int i = 1; i < numNotes; i++) {
            [path addLineToPoint:[[array objectAtIndex:i] CGPointValue]];
        }
    }
}

@end
