//
//  GridCell.h
//  GeometryTunes
//
//  Created by Music2 on 3/21/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Piano.h"

@interface GridCell : UIView

@property pianoNote note;
@property (nonatomic) CGRect box;

- (id)initWithRect:(CGRect)r;

@end
