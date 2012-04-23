//
//  PathListController.m
//  GeometryTunes
//
//  Created by Music2 on 4/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "PathListController.h"
#import "PathsView.h"
#import "ViewController.h"

@implementation PathListController

@synthesize pathView, pathPicker, editPathBtn;
@synthesize mainViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    assert(pathPicker);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    assert(pathView);
    return [[pathView paths] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Path cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [pathView nthPathName:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *pathName = [pathView nthPathName:indexPath.row];
    [pathView deletePath:pathName];
    [pathPicker reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(pathView);
    [pathView setCurrentPathName:[pathView nthPathName:indexPath.row]];
    if(mainViewController)
        [mainViewController pathHasBeenSelected];
}

- (IBAction)newPath
{
    int pathNum = [[pathView paths] count];
    NSString *pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum];
    for(; [[pathView paths] objectForKey:pathName] != nil; pathNum++, pathName = [[NSString alloc]initWithFormat:@"path%d", pathNum]);
    [pathView addPath:pathName];
    [pathPicker reloadData];
    if(mainViewController)
        [mainViewController pathHasBeenSelected];
}

- (IBAction)editPath
{
    [pathPicker setEditing:![pathPicker isEditing]];
    //TODO: change the button text
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(mainViewController && ![pathView currentPathName])
        [mainViewController changeStateToNormal:true];
}

@end
