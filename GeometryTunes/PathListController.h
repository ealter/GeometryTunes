//
//  PathListController.h
//  GeometryTunes
//
//  Created by Music2 on 4/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PathsView;
@class ViewController;

@interface PathListController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong) PathsView *pathView;
@property (nonatomic, strong) ViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UIPickerView *pathPicker;

@end
