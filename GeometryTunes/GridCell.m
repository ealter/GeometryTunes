#import "GridCell.h"
#import "noteColor.h"
#import "Piano.h"

@implementation GridCell

- (void)sharedInit
{
    note = NO_PIANO_NOTE;
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

- (void)setNote:(pianoNote)n
{
    note = n;
    if(n != NO_PIANO_NOTE)
        [self setBackgroundColor:[noteColor colorFromNoteWithPitch:[noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]]];
}

- (pianoNote)note
{
    return note;
}

@end
