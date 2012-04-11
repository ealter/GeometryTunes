//
//  PathListController.m
//  GeometryTunes
//
//  Created by Music2 on 4/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "PathListController.h"
#import "PathsView.h"

@implementation PathListController

@synthesize pathView, pathPicker;
@synthesize hasSelectedPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        hasSelectedPath = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(200, 200);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pathView)
        return [[pathView paths] count] + 1;
    else
        return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return @"New Path";
    }
    else if(pathView)
    {
        return [pathView nthPathName:component - 1];
    }
    else
        return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        //Create a new path
        NSString *pathName = [[NSString alloc]initWithFormat:@"path%d",component];
        [pathView addPath:pathName];
        [pathPicker reloadAllComponents];
    }
    else
    {
        [pathView setCurrentPathName:[pathView nthPathName:component - 1]];
    }
    if(hasSelectedPath != nil)
    {
        [self performSelector:hasSelectedPath];
    }
}

@end
