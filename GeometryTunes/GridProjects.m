#import "GridProjects.h"
#import "ViewController.h"
#import "GridView.h"

@interface GridProjects ()

+ (NSString *)getSavedGridsDirectory;
+ (NSString *)getFilePath:(NSString *)filename;

@end

@implementation GridProjects

@synthesize currentFileName;

#define FILE_EXTENSION @"geotunes"
#define GRID_NAME_KEY  @"filename"
#define GRID_KEY       @"grid"
#define TEMPO_KEY      @"tempo"

+ (NSString *)getSavedGridsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Grids"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    return documentsDirectory;
}

+ (NSString *)getFilePath:(NSString *)filename
{
    return [[[self getSavedGridsDirectory] stringByAppendingPathComponent:filename] stringByAppendingPathExtension:FILE_EXTENSION];
}

+ (void)deleteProject:(NSString *)projectName
{
    NSString *path = [self getFilePath:[self sanitizeProjectName:projectName]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)newGrid
{
    currentFileName = nil;
}

- (GridView *)loadGridFromFile:(NSString *)fileName viewController:(ViewController *)viewController
{
    NSString *dataPath = [GridProjects getFilePath:[GridProjects sanitizeProjectName:fileName]];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    NSString *gridName = [unarchiver decodeObjectForKey:GRID_NAME_KEY];
    if(gridName == nil) return nil;
    GridView *grid = [unarchiver decodeObjectForKey:GRID_KEY];
    assert([unarchiver containsValueForKey:GRID_KEY]);
    if([unarchiver containsValueForKey:TEMPO_KEY]) {
        NSTimeInterval tempo = [unarchiver decodeDoubleForKey:TEMPO_KEY];
        [viewController setTempo:tempo];
    }
    [unarchiver finishDecoding];
    currentFileName = fileName;
    return grid;
}

- (BOOL)saveToFile:(NSString *)fileName grid:(GridView *)grid tempo:(NSTimeInterval)tempo
{
    fileName = [GridProjects sanitizeProjectName:fileName];
    if([fileName length] == 0)
        return FALSE; //failure
    NSString *dataPath = [GridProjects getFilePath:fileName];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:fileName forKey:GRID_NAME_KEY];
    [grid changeToNormalState];
    [grid stopPlayback];
    [archiver encodeObject:grid forKey:GRID_KEY];
    [archiver encodeDouble:tempo forKey:TEMPO_KEY];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    currentFileName = fileName;
    return TRUE; //success
}

+ (NSString *)sanitizeProjectName:(NSString *)projectName
{
    NSString *invalidCharacters[] = {@":", @"/"};
    projectName = [projectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for(int i=0; i < sizeof(invalidCharacters)/sizeof(invalidCharacters[0]); i++) {
        projectName = [projectName stringByReplacingOccurrencesOfString:invalidCharacters[i] withString:@"_"];
    }
    if([projectName length] > 0 && [projectName characterAtIndex:0] == '.')
        projectName = [projectName substringFromIndex:1];
    if([projectName length] + [FILE_EXTENSION length] > NAME_MAX)
        projectName = [projectName substringToIndex:NAME_MAX - [FILE_EXTENSION length]];
    return projectName;
}

+ (NSMutableArray *)gridNameList
{
    NSString *documentsDirectory = [self getSavedGridsDirectory];
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableArray *gridNames = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:FILE_EXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [gridNames addObject:[file stringByDeletingPathExtension]];
        }
    }
    [gridNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return gridNames;
}

+ (NSString *)nthFileName:(NSInteger)i
{
    return [[self gridNameList] objectAtIndex:i];
}

@end
