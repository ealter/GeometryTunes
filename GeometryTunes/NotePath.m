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
        path = nil;
    }
    return self;
}

- (void)addNoteWithPos:(CGPoint)pos 
{
    [notes addObject:[NSValue valueWithCGPoint:pos]];
    numNotes++;
}

- (void)removeNoteAtIndex:(unsigned)index
{
    [notes removeObjectAtIndex:index];
    numNotes--;
}

- (void)buildPath
{
    path = [UIBezierPath bezierPath];
    if (numNotes > 0) {
        [path moveToPoint:[[notes objectAtIndex:0] CGPointValue]];
        for (int i = 1; i < numNotes; i++) {
            [path addLineToPoint:[[notes objectAtIndex:i] CGPointValue]];
        }
    }
}

- (void)updateAndDisplayPath:(CGContextRef)context
{
    [self buildPath];
    CGContextSaveGState(context);
    
    path.lineWidth = 5;
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

@end
