//
//  GridView.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "GridView.h"

@implementation GridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Get current graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set line width
    CGContextSetLineWidth(context, 2.0);
    
    // Draw a blue rectangle
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(60, 170, 200, 80);
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}


@end
