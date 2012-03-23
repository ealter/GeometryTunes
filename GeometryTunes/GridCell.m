//
//  GridCell.m
//  GeometryTunes
//
//  Created by Music2 on 3/21/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "GridCell.h"
#import "noteColor.h"

@implementation GridCell

@synthesize note;
@synthesize box;

- (id)initWithRect:(CGRect)r
{
    self = [super init];
    if (self)
    {
        self.box = r;
        self.note = NO_PIANO_NOTE;
    }
    return self;
}

@end
