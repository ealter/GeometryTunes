#import <UIKit/UIKit.h>
#import "noteTypes.h"

@interface GridCell : UIView
{
    NSMutableArray *notes; //An array of NSNumber*'s that each represent a pianoNote
}

- (NSMutableArray*)notes;
- (void)setNotes:(NSMutableArray*)notes;
- (void)setLastNote:(pianoNote)note; //Changes the last note. If there are no notes, it adds one
- (void)addNote:(pianoNote)note; //Adds a note to the end of the array
- (id)getNoteAtIndex:(int)i; //returns pianoNote type
- (void)clearNotes;

@end
