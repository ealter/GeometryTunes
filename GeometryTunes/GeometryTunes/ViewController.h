//
//  ViewController.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"

@interface ViewController : UIViewController

typedef enum STATE
{
    NORMAL_STATE,
    PIANO_STATE,
    PATH_EDIT_STATE
} STATE;

@property STATE state;
@property (retain) IBOutlet GridView* grid;

- (IBAction)playEvent:(id)sender;
- (IBAction)pauseEvent:(id)sender;
- (IBAction)rewindEvent:(id)sender;
- (IBAction)fastForwardEvent:(id)sender;
- (IBAction)editPathEvent:(id)sender;

- (void)changeStateToNormal:(bool)informGrid;

@end
