#import <Foundation/Foundation.h>

/* This module handles the save and load capabilities for grids */

@class GridView;
@class ViewController;

@interface GridProjects : NSObject

@property (nonatomic, copy, readonly) NSString *currentFileName;

+ (NSString *)sanitizeProjectName:(NSString *)projectName; //Returns a new project name that can be used as part of a filename
+ (NSMutableArray *)gridNameList; //Returns a list of saved grid names
+ (NSString *)nthFileName:(NSInteger)n; //Returns the nth saved grid name (alphabetical order)
+ (void)deleteProject:(NSString *)projectName;

- (GridView*)loadGridFromFile:(NSString *)fileName viewController:(ViewController *)viewController; //Returns a grid from the saved file. nil on error
- (BOOL)saveToFile:(NSString *)fileName grid:(GridView *)grid tempo:(NSTimeInterval)tempo; //Save the file to the grid. Returns TRUE on success
- (void)newGrid; //Resets the current file name

@end
