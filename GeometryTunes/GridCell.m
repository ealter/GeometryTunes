#import "GridCell.h"
#import "noteColor.h"
#import "Piano.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

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
    if (self) {
        [self sharedInit];
    }
    return self;
}

#define NOTES_ENCODE_KEY @"notes"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
        NSMutableArray *_notes = [aDecoder decodeObjectForKey:NOTES_ENCODE_KEY];
        if(_notes)
            notes = _notes;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:notes forKey:NOTES_ENCODE_KEY];
}

- (void)addNote:(midinote)note
{
    [notes addObject:[NSNumber numberWithUnsignedInt:note]];
    [self setNeedsDisplay];
}

- (void)removeNote:(midinote)note
{
    [notes removeObject:[NSNumber numberWithUnsignedInt:note]];
    [self setNeedsDisplay];
}

- (void)clearNotes
{
    notes = [[NSMutableArray alloc]init];
    [self setNeedsDisplay];
}

// Creates a colored rect for each note played from cell
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int numNotes = [notes count];
    float rectHeight = rect.size.height / numNotes;
    float offset = 0;
    for(int i = 0; i < numNotes; i++, offset += rectHeight) {
        midinote note = [[notes objectAtIndex:i] unsignedIntValue];
        UIColor *color = [noteColor colorFromNoteWithPitch:note % NOTES_IN_OCTAVE octave:note / NOTES_IN_OCTAVE];
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGRect rect = CGRectMake(0, offset, [self bounds].size.width, rectHeight);
        CGContextFillRect(context, rect);
    }
}

@end
