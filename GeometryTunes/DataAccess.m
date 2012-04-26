    
#import "DataAccess.h"
#import "Cells.h"


@implementation DataAccess

-(void)saveCell: (Cells *)cell {
    NSLog(@"Saving cell at x:%i and y:%i", [cell.getXCoord intValue], [cell.getYCoord intValue]);
    if(!cell) NSLog(@"Cell is nil!!!");
    NSData *dataRep;
    NSString *errorString = nil;
    NSDictionary *propertyList;
      
    propertyList = [NSDictionary dictionaryWithObjectsAndKeys:@"xCoord", [cell getXCoord], @"yCoord", [cell getYCoord], nil];
    if(!propertyList) {
        NSLog(@"ERROR: CoreDataAccess.m savecell()");
    }
    dataRep = [NSPropertyListSerialization dataFromPropertyList:propertyList format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
    
    
    [dataRep writeToFile:@"UserData.plist" atomically:YES];
    
}

-(void)loadCells {
    /*
    NSError *errorString = nil;
    NSDictionary *propertyList;
    NSPropertyListFormat format;
    NSData *data = [[NSData alloc]initWithContentsOfFile:@"UserData.plist"];
    
    if(!data) NSLog(@"data is nil!!!"); //// True!!!! ////
        propertyList = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&errorString];
    if (!propertyList) {
        // Handle error
    }
    
    NSLog(@"%@", propertyList);
     */
}

@end
