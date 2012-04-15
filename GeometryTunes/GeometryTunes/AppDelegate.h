#import <UIKit/UIKit.h>
#include "crmd.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Core data stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // connection between code and data store
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // contains methods for deleting or adding data
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // connection between app and physical files

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property CRMD_HANDLE handle;
@property CRMD_FUNC *api;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
