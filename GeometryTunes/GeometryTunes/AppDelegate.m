#import "AppDelegate.h"

#import "ViewController.h"
#import <AudioToolBox/AudioServices.h>
#import <CoreData/CoreData.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize api, handle;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)initMidiPlayer
{
    // Override point for customization after application launch.
    
	AudioSessionInitialize(NULL, NULL, NULL, NULL); //TODO: maybe make the last parameter self?
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    
	AudioSessionSetActive(true);
    
	Float32 bufferSize = 0.005;
	SInt32 size = sizeof(bufferSize);
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, size, &bufferSize);
    
    
	api = crmdLoad ();
    
	CRMD_ERR err = CRMD_OK;
	
	if (err == CRMD_OK) {
		// initialize
		NSString *path = [[NSBundle mainBundle] pathForResource:@"crsynth" ofType:@"dlsc"];
		const char *lib = [path cStringUsingEncoding:NSASCIIStringEncoding];
        const unsigned char key[64] = {
            0xE1, 0xF1, 0x4B, 0xF9, 0x39, 0xA7, 0x6C, 0x32,
            0x65, 0x73, 0x1B, 0xF5, 0xD0, 0x00, 0xD8, 0xAD,
            0x70, 0x07, 0x52, 0xF3, 0x22, 0x68, 0x52, 0xF2,
            0x6B, 0xE6, 0x4A, 0x54, 0x0E, 0xE4, 0xA6, 0xE6,
            0x4B, 0xF0, 0x81, 0x82, 0x33, 0xE7, 0xF9, 0xA3,
            0xB1, 0x39, 0xFE, 0xB1, 0x7D, 0xAA, 0xA9, 0x44,
            0x74, 0x68, 0xF7, 0x79, 0xD0, 0xF2, 0xED, 0x2D,
            0xE4, 0x62, 0x89, 0x45, 0x9F, 0xC7, 0xA5, 0x62,
		};
        err = api->initializeWithSoundLib (&handle, nil, nil, lib, NULL, key);
	}
    
	if (err == CRMD_OK) {
		// revweb on
		int value = 1;
		err = api->ctrl (handle, CRMD_CTRL_SET_REVERB, &value, sizeof (value));
	}
    
	if (err == CRMD_OK) {
		// open wave output device
		err = api->open (handle, NULL, NULL);
	}
    
	if (err == CRMD_OK) {
		// start realtime MIDI
		err = api->start (handle);
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [self initMidiPlayer];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataTest" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataTest.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


/*
- (void)saveCellwithXCoordinate:(NSNumber *)xCoord yCoordinate:(NSNumber *)yCoord andColor:(NSNumber *)color andWantRemoved:(_Bool)wantRemoved {
    if(!wantRemoved){ 
        //check if cell exists first
        NSError *error; 
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *searchEntity = [NSEntityDescription entityForName:@"Cell" inManagedObjectContext:self.managedObjectContext]; //add x and y coordinates into search
        [request setEntity:searchEntity];
        NSMutableArray *results = [[self.managedObjectContext executeFetchRequest: request error:&error]mutableCopy];
        
        NSLog(@"%d", [results count]);
        if([results count] != 0){
            //change color array within cell
            for(NSPropertyDescription *property in results){
                NSLog(@"Name: %@", property.name);
            }
        } else {
            //add cell and color to stored data
            NSManagedObject *cellObject = [NSEntityDescription insertNewObjectForEntityForName:@"Cells" inManagedObjectContext:self.managedObjectContext];
            [cellObject setValue:xCoord forKey:@"xCoordinate"];
            [cellObject setValue:yCoord forKey:@"yCoordinate"];
            
            NSManagedObject *colorObject = [NSEntityDescription insertNewObjectForEntityForName:@"Colors" inManagedObjectContext:self.managedObjectContext];
            [colorObject setValue:color forKey:@"color"];
            
            //add color to cell
            [cellObject setValue:color forKey:@"Colors"];
            NSLog(@"Added cell and color");
        }
        
    } else {
        //remove color from cell
    }
}
 */
@end
