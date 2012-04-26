#import <Foundation/Foundation.h>
#import "Cells.h"

@interface DataAccess : NSObject

-(void)saveCell: (Cells *)cells;
-(void)loadCells;

@end
