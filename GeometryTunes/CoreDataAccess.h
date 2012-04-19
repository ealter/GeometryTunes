//
//  CoreDataAccess.h
//  GeometryTunes
//
//  Created by Music2 on 4/19/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

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
