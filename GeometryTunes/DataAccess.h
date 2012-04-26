#import <Foundation/Foundation.h>
#import "Cells.h"

@interface CoreDataAccess : NSObject

-(void)saveCell: (Cells *)cells;
-(void)loadCells;

@end
