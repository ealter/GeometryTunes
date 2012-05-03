#import <UIKit/UIKit.h>
#import "noteTypes.h"

/* Represents a cell on the grid */

@interface GridCell : UIView <NSCoding>
{
    NSMutableArray *notes; //An array of NSNumber*'s that each represent a midinote
}

- (NSMutableArray*)notes;
- (void)setNotes:(NSMutableArray*)notes;
- (void)setLastNote:(midinote)note; //Changes the last note. If there are no notes, it adds one
- (void)addNote:(midinote)note; //Adds a note to the end of the array
- (NSNumber*)getNoteAtIndex:(int)i; //returns midinote type
- (void)clearNotes;

@end
