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

- (void)addNoteWithArray:(NSMutableArray*)array pos:(CGPoint)pos 
{
    [array addObject:[NSValue valueWithCGPoint:pos]];
    numNotes++;
}

- (void)removeNoteWithArray:(NSMutableArray*)array index:(NSUInteger)index
{
    [array removeObjectAtIndex:index];
    numNotes--;
}

@end
