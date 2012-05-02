#import <Foundation/Foundation.h>

@class GridView;

@interface GridProjects : NSObject

@property (nonatomic, copy, readonly) NSString *currentFileName;

+ (NSString *)sanitizeProjectName:(NSString *)projectName; //Returns a new project name that can be used as part of a filename
+ (NSMutableArray *)gridNameList;
+ (NSString *)nthFileName:(NSInteger)i;
+ (void)deleteProject:(NSString *)projectName;

- (GridView*)loadGridFromFile:(NSString *)fileName;
- (void)saveToFile:(NSString *)fileName grid:(GridView *)grid;
- (void)newGrid;

@end
