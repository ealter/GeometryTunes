//
//  PathListController.h
//  GeometryTunes
//
//  Created by Music2 on 4/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PathsView;

@interface PathListController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong) PathsView *pathView;

@end
