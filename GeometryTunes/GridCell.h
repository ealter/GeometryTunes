#import <UIKit/UIKit.h>
#import "noteTypes.h"
#import <CoreData/CoreData.h>

@interface GridCell : UIView
{
    NSMutableArray *notes; //An array of NSNumber*'s that each represent a midinote
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsContoller;

- (NSMutableArray*)notes;
- (void)setNotes:(NSMutableArray*)notes;
- (void)setLastNote:(midinote)note; //Changes the last note. If there are no notes, it adds one
- (void)addNote:(midinote)note; //Adds a note to the end of the array
- (NSNumber*)getNoteAtIndex:(int)i; //returns midinote type
- (void)clearNotes;

// Core data stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // "Bridge" or connection between your code and the data store

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // Contains your schema; contains methods for deleting/adding data to data store

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // "Bridge" or connection between your application and physical files

//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (bool)saveCellwithXCoordinate:(NSNumber *)xCoord yCoordinate:(NSNumber *)yCoord andColor:(NSNumber *)color andWantRemoved:(bool)wantRemoved;

@end
