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
        midinote note = [[notes objectAtIndex:0] intValue];
        [self setBackgroundColor:[noteColor colorFromNoteWithPitch:note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE]];
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

- (void)setLastNote:(midinote)note
{
    int numNotes = [notes count];
    NSNumber *n = [NSNumber numberWithUnsignedInt:note];
    if(numNotes == 0)
        [notes addObject:n];
    else
        [notes replaceObjectAtIndex:numNotes - 1 withObject:n];
    [self setNotes:notes];
}

- (void)addNote:(midinote)note
{
    [notes addObject:[NSNumber numberWithUnsignedInt:note]];
    [self setNotes:notes];
}

- (id)getNoteAtIndex:(int)i
{
    return [notes objectAtIndex:i];
}

- (void)clearNotes
{
    [self setNotes:[[NSMutableArray alloc]init]];
}

// Creates a colored rect for each note played from cell
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int numNotes = [notes count];
    float rectHeight = [self bounds].size.height / numNotes;
    for(int i = 1, offset = rectHeight; i < numNotes; i++, offset += rectHeight)
    {
        midinote note = [[notes objectAtIndex:i] unsignedIntValue];
        UIColor *color = [noteColor colorFromNoteWithPitch:note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE];
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, offset, [self bounds].size.width, rectHeight));
    }
}

@end
