//
//  NotePath.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/23/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotePath : NSObject
{
    NSMutableArray *notes;
    int numNotes;
    UIBezierPath* path;
}

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)updateAndDisplayPath:(CGContextRef)context;

@end
