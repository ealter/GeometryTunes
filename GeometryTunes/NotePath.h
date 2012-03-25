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
}

- (id)init;
- (void)addNoteWithPos:(CGPoint)pos;
- (void)removeNoteAtIndex:(NSUInteger)index;

@end
