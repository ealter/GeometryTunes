#import <UIKit/UIKit.h>
#import "noteTypes.h"

/* Represents a cell on the grid */

@interface GridCell : UIView <NSCoding>

@property (nonatomic, retain) NSMutableArray *notes; //An array of NSNumber*'s that each represent a midinote

- (void)addNote:(midinote)note;
- (void)removeNote:(midinote)note;
- (NSNumber*)getNoteAtIndex:(int)i; //returns midinote type
- (void)clearNotes;

@end
