#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"
#import "Cells.h"

@interface CoreDataAccess : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // "Bridge" or connection between your code and the data store

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // Contains your schema; contains methods for deleting/adding data to data store

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // "Bridge" or connection between your application and physical files


-(void)saveCell: (Cells *)cells;
-(void)loadCells;

- (void)saveCellWithXCoordinate: (int)xCoordinate andYCoordinate: (int)yCoordinate;
- (void)saveColor:(int)color toCellWithXCoordiante:(int)xCoordinate andYCoordinate:(int)yCoordinate;
- (NSURL *)applicationDocumentsDirectory;
- (NSMutableArray *) core_data_Content;

@end
