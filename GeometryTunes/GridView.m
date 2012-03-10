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

- (void)drawGridWidth:(float)width Height:(float)height Context:(CGContextRef)context
{
    
    CGRect myRect;
    for (int i = 0; i <= 10; i++) {
        for (int j = 0; j <= 10; j++) {
            myRect = CGRectMake(i * width / 10, j * height / 10, width / 10, height / 10);
            CGContextAddRect(context, myRect);  
        }
    }  
    
}

- (void)drawRect:(CGRect)rect
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Get current graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set line width
    CGContextSetLineWidth(context, 2.0);
    
    // Draw a blue rectangle
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    
    [self drawGridWidth:screenRect.size.width Height:screenRect.size.height Context:context];
    
    CGContextStrokePath(context);

}



@end
