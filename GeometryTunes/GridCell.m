#import "GridCell.h"
#import "noteColor.h"
#import "Piano.h"

@implementation GridCell

@synthesize notes;

- (void)sharedInit
{
    notes = [[NSMutableArray alloc] init];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
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
    notes = n;
    if([notes count] >= 1)
    {
        pianoNote note = [[notes objectAtIndex:0] unsignedIntValue];
        assert(note != NO_PIANO_NOTE);
        [self setBackgroundColor:[noteColor colorFromNoteWithPitch:[noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]]];
    }
    [self.layer needsDisplay];
}

- (void)setLastNote:(pianoNote)note
{
    assert(note != NO_PIANO_NOTE);
    int numNotes = [notes count];
    NSNumber *n = [NSNumber numberWithUnsignedInt:note];
    if(numNotes == 0)
        [notes addObject:n];
    else
        [notes replaceObjectAtIndex:numNotes - 1 withObject:n];
    [self setNotes:notes];
}

- (void)addNote:(pianoNote)note
{
    assert(note != NO_PIANO_NOTE);
    [notes addObject:[NSNumber numberWithUnsignedInt:note]];
    [self setNotes:notes];
}

- (void)clearNotes
{
    [self setNotes:[[NSMutableArray alloc]init]];
}

//TODO: display the extra colors with drawrect

@end
