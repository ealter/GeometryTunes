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

- (void)sharedInit
{
    note = NO_PIANO_NOTE;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    /* Set UIView Border */
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 0.0, 1.0);
    CGContextStrokeRect(contextRef, rect);
}

- (void)setNote:(pianoNote)n
{
    note = n;
    if(n != NO_PIANO_NOTE)
        [self setBackgroundColor:[noteColor colorFromNoteWithPitch:[Piano pitchOfPianoNote:note] octave:[Piano octaveOfPianoNote:note]]];
}

@end
