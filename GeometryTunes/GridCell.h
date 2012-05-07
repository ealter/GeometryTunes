#import <UIKit/UIKit.h>
#import "noteTypes.h"

/* Represents a cell on the grid */

@interface GridCell : UIView <NSCoding>

@property (nonatomic, readonly, copy) NSMutableArray *notes; //An array of NSNumber*'s that each represent a midinote

- (void)addNote:(midinote)note;
- (void)removeNote:(midinote)note;
- (void)clearNotes;

@end
