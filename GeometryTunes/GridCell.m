#import "GridCell.h"
#import "noteColor.h"
#import "Piano.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Cells.h"

@implementation GridCell

@synthesize fetchedResultsContoller;
//Core Data
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize cellID = _cellID;


- (void)sharedInit
{
    NSLog(@"shared init");
    notesArray = [[NSMutableArray alloc] init];
    [self setBackgroundColor:[UIColor clearColor]];
}
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
        //add cell to data
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        //NSNumber* xCoord = [[NSNumber alloc]initWithFloat:frame.origin.x];
        //NSNumber* yCoord = [[NSNumber alloc]initWithFloat:frame.origin.y];
        //[appDelegate saveCellwithXCoordinate:xCoord yCoordinate:yCoord andColor:0 andWantRemoved:false];
    }
    return self;
}
*/
- (id)initWithFrame:(CGRect)frame andXCoord:(int)x andYCoord:(int)y
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
        //add cell to data
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        //NSNumber* xCoord = [[NSNumber alloc]initWithInt:x];
        //NSNumber* yCoord = [[NSNumber alloc]initWithInt:y];
        //[self saveCellwithXCoordinate:xCoord yCoordinate:yCoord andColor:0 andWantRemoved:false];
    }
    notesArray = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)setNotes:(NSMutableArray *)n
{
    notesArray = n;
    [self setNeedsDisplay];
}

- (NSMutableArray*)notes
{
    return notesArray;
}

- (void)setLastNote:(midinote)note
{
    int numNotes = [notesArray count];
    NSNumber *n = [NSNumber numberWithUnsignedInt:note];
    if(numNotes == 0)
        [notesArray addObject:n];
    else
        [notesArray replaceObjectAtIndex:numNotes - 1 withObject:n];
    [self setNotes:notesArray];
}

- (void)addNote:(midinote)note
{
    if(!notesArray) {
        NSLog(@"notesArray is null");
        notesArray = [[NSMutableArray alloc] init];
    }
    [notesArray addObject:[NSNumber numberWithUnsignedInt:note]];
    [self setNotes:notesArray];
    //Add midinote (unsigned int) to cell as color
}

- (NSNumber*)getNoteAtIndex:(int)i
{
    return [notesArray objectAtIndex:i];
}

- (void)clearNotes
{
    [self setNotes:[[NSMutableArray alloc]init]];
}

// Creates a colored rect for each note played from cell
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int numNotes = [notesArray count];
    float rectHeight = rect.size.height / numNotes;
    for(int i = 0, offset = 0; i < numNotes; i++, offset += rectHeight)
    {
        midinote note = [[notesArray objectAtIndex:i] unsignedIntValue];
        UIColor *color = [noteColor colorFromNoteWithPitch:note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE];
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGRect rect = CGRectMake(0, offset, [self bounds].size.width, rectHeight);
        CGContextFillRect(context, rect);
    }
}

// Core Data 

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSLog(@"here");
    if (coordinator != nil) {
        NSLog(@"what");
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    else
    {
        NSLog(@"Coordinator is nil");
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
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

- (bool) saveCellwithXCoordinate:(NSNumber *)xCoord yCoordinate:(NSNumber *)yCoord andColor:(NSNumber *)color andWantRemoved:(_Bool)wantRemoved
{
    Cells *e = (Cells *)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:self.managedObjectContext];
    
    [e setXCoord:[xCoord floatValue]];
    [e setXCoord:[yCoord floatValue]];
    
    NSError * error;
    (void)error;
    
    if (![self.managedObjectContext save:&error]) {
        return false;
    }
    else {
        return true;
    }
    
}
@end
