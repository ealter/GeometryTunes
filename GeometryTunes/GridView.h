//
//  GridView.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView

@property int gridWidth;
@property int gridHeight;
@property int numBoxesX;
@property int numBoxesY; 

@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;

- (void)handleTap:(UITapGestureRecognizer *)sender;
- (int)getBoxWidth;
- (int)getBoxHeight;
- (void)drawGrid:(CGContextRef)context;
- (CGPoint)getBoxFromCoords:(CGPoint)pos;

@end
