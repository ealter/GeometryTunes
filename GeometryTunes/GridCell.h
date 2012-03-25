//
//  GridCell.h
//  GeometryTunes
//
//  Created by Music2 on 3/21/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "noteTypes.h"

@interface GridCell : UIView
{
    pianoNote note;
}

- (void)setNote:(pianoNote)note;
- (pianoNote)getNote;

@end
