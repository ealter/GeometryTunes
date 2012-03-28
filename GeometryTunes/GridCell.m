#import "GridCell.h"
#import "noteColor.h"
#import "Piano.h"
#import <QuartzCore/QuartzCore.h>

@implementation GridCell

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
    else {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    [self.layer setNeedsDisplay];
}

- (NSMutableArray*)notes
{
    return notes;
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
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int numNotes = [notes count];
    float rectHeight = [self bounds].size.height / numNotes;
    for(int i = 1, offset = rectHeight; i < numNotes; i++, offset += rectHeight)
    {
        pianoNote note = [[notes objectAtIndex:i] unsignedIntValue];
        UIColor *color = [noteColor colorFromNoteWithPitch:[noteTypes pitchOfPianoNote:note] octave:[noteTypes octaveOfPianoNote:note]];
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, offset, [self bounds].size.width, rectHeight));
    }
}

@end
