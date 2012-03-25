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
    UIBezierPath* path;
}

@property (readonly, retain) NSMutableArray *notes; //The type of each element is NSValue representation of CGPoint
@property (readonly) int numNotes;

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(unsigned)index;
- (void)updateAndDisplayPath:(CGContextRef)context;

@end
