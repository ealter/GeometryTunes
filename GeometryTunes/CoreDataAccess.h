#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@interface CoreDataAccess : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // "Bridge" or connection between your code and the data store

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // Contains your schema; contains methods for deleting/adding data to data store

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // "Bridge" or connection between your application and physical files


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSMutableArray *) core_data_Content;

@end
