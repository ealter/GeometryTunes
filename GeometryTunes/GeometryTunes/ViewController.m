//
//  ViewController.m
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize state;
@synthesize grid;
@synthesize editPathBtn;

- (IBAction)playEvent:(id)sender
{
    if(state != NORMAL_STATE)
        [self changeStateToNormal:true];
    [grid playPathWithSpeedFactor:1 reversed:false];
}

- (IBAction)pauseEvent:(id)sender
{
    if(state == NORMAL_STATE)
        [grid pausePlayback];
    else
        [self changeStateToNormal:true];
}

- (IBAction)rewindEvent:(id)sender
{
    [grid pausePlayback]; //todo: make this stop playback, not pause
    if(state == NORMAL_STATE)
    {
        [grid playPathWithSpeedFactor:0.5 reversed:true];
    }
    else
        [self changeStateToNormal:true];
}

- (IBAction)fastForwardEvent:(id)sender
{
    if(state != NORMAL_STATE)
        [self changeStateToNormal:true];
    [grid playPathWithSpeedFactor:0.5 reversed:false];
}

- (IBAction)editPathEvent:(id)sender
{
    if(state == PATH_EDIT_STATE)
        [self changeStateToNormal:true];
    else
    {
        [self changeStateToNormal:true];
        [editPathBtn setTitle:@"Stop Path" forState:UIControlStateNormal];
        state = PATH_EDIT_STATE;
    }
}

- (void)changeStateToNormal:(bool)informGrid
{
    if(state == PATH_EDIT_STATE)
        [editPathBtn setTitle:@"Edit Path" forState:UIControlStateNormal];
    if(informGrid)
        [grid changeToNormalState];
    state = NORMAL_STATE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    state = NORMAL_STATE;
    [grid setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
