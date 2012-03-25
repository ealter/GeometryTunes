//
//  PathsView.h
//  GeometryTunes
//
//  Created by Music2 on 3/25/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotePath.h"

@interface PathsView : UIView

@property (readonly, retain) NotePath *path;

- (void)addNoteWithPos:(CGPoint)pos;

@end
