//
//  MainView.m
//  GeometryTunes
//
//  Created by Music2 on 3/25/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "MainView.h"
#import "GridView.h"

@implementation MainView

- (void)sharedInitWithFrame:(CGRect)frame
{
    GridView *grid = [[GridView alloc]initWithFrame:frame];
    [self addSubview:grid];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInitWithFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self sharedInitWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
