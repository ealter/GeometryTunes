#import "Piano.h"
#import <QuartzCore/QuartzCore.h>
#import "scrollViewWithButtons.h"

#define NOTES_IN_KEYBOARD NOTES_IN_OCTAVE
#define INITIAL_PITCH 0
#define INITIAL_OCTAVE 3
#define BUTTON_RELATIVE_SIZE 1.3

@implementation Piano

#import "noteTypes.h"
#import "noteColor.h"
#import "GridView.h"

@synthesize notePlayer, piano, contentOffset;

- (id)initWithFrame:(CGRect)frame delegate:(GridView*)del
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
        delegate = del;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit
{
    notes = [NSMutableArray arrayWithCapacity:(MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE];
    notePlayer = [[NotePlayer alloc]init];
    [self setBackgroundColor:[UIColor whiteColor]];
    if(piano) {
        [piano setContentOffset:contentOffset];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int width = rect.size.width;
    int height = rect.size.height;
    //const float buttonRelativeSize = 1.3;
    const float whiteKeyWidth = ((float)width) / ([self numWhiteNotes]+BUTTON_RELATIVE_SIZE);
    
    float buttonWidth = whiteKeyWidth*BUTTON_RELATIVE_SIZE;
    float blackKeyWidth = whiteKeyWidth/2;
    float blackKeyHeight = height*2/3;
    UIButton *note;
    int whiteKeyNum = 0;
    bool isBlack;

    CGRect pianoSize = CGRectMake(0, 0, width - buttonWidth, height);
    if(!piano)
    {
        piano = [[scrollViewWithButtons alloc]initWithFrame:pianoSize];
        [piano setContentOffset:CGPointMake(whiteKeyWidth * [Piano whiteNotesFromPitch:0 numNotes:(INITIAL_OCTAVE - MIN_OCTAVE) * NOTES_IN_OCTAVE + INITIAL_PITCH], 0)];
    }
    else
    {
        piano = [piano initWithFrame:pianoSize];
        [piano setContentOffset:contentOffset];
    }
    [piano setCanCancelContentTouches:true];
    [piano setContentSize:CGSizeMake(whiteKeyWidth * ((MAX_OCTAVE - MIN_OCTAVE + 1) * [Piano whiteNotesFromPitch:0 numNotes:NOTES_IN_OCTAVE]), height)];
    [piano setDelaysContentTouches:NO];
    [self addSubview:piano];
    
    float x = 0;
    for(int i=0; i<((MAX_OCTAVE - MIN_OCTAVE + 1) * NOTES_IN_OCTAVE); i++)
    {
        if([Piano isBlackNote:i])
        {
            isBlack = true;
            //The note is a black note                      
            note = [[UIButton alloc]initWithFrame:CGRectMake(x-blackKeyWidth/2, 0, blackKeyWidth, blackKeyHeight)];
        }
        else
        {
            isBlack = false;
            //This note is a white note
            whiteKeyNum++;
            note = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, whiteKeyWidth, height)];
            x += whiteKeyWidth;
        }
        
        
        [note setBackgroundColor:[noteColor colorFromNoteWithPitch:i % NOTES_IN_OCTAVE octave:i/NOTES_IN_OCTAVE + MIN_OCTAVE]];
        note.tag = i;
        [piano addSubview:note];
        [note addTarget:self action:@selector(KeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        if(!isBlack)
            [piano sendSubviewToBack:note];
        [note.layer setBorderWidth:1];
        [note.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [notes addObject:note];
    }
    
    x = width - buttonWidth;
    //Make the "Add note" and "Clear" buttons
    for(int i = 0, heightOffset = 0; i < 2; heightOffset += height/2, i++)
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, heightOffset, buttonWidth, height/2)];
        [btn setBackgroundColor:[UIColor blueColor]];
        SEL eventHandler;
        btn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        btn.titleLabel.textAlignment = UITextAlignmentCenter;
        if(i == 0)
        {
            [btn setTitle:@"Add Note" forState:UIControlStateNormal];
            eventHandler = @selector(noteAddEvent);
        }
        else
        {
            [btn setTitle:@"Clear" forState:UIControlStateNormal];
            eventHandler = @selector(noteClearEvent);
        }
        btn.titleLabel.font = [UIFont systemFontOfSize:20];
        btn.titleLabel.textColor = [UIColor blackColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [btn.layer setBorderWidth:2];
        [btn addTarget:self action:eventHandler forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
        
        [self addSubview:btn];
    }
    
    [self boldNotes:[delegate notes]];
}

- (void)KeyClicked:(id)sender
{
    UIButton *note = sender;
    int pitch = note.tag % NOTES_IN_OCTAVE;
    int oct   = note.tag / NOTES_IN_OCTAVE + MIN_OCTAVE;
    [delegate changeNoteWithPitch:pitch octave:oct appendNote:addNote];
    [delegate playNote];
    addNote = false;
    [self boldNotes:[delegate notes]];
}

- (void)gridCellHasChanged
{
    [self boldNotes:[delegate notes]];
}

- (void)noteAddEvent
{
    addNote = true;
}

- (void)noteClearEvent
{
    [delegate clearNote];
}

+ (bool)isBlackNote:(int)pitch
{
    int n = pitch % NOTES_IN_OCTAVE;
    return n == 1 || n == 3 || n == 6 || n == 8 | n == 10;
}

+ (int)whiteNotesFromPitch:(unsigned int)pitch numNotes:(unsigned int)numNotes
{
    int numWhiteNotes = 0;
    for(int i = 0; i < numNotes; i++)
    {
        if(![self isBlackNote:pitch + i])
            numWhiteNotes++;
    }
    return numWhiteNotes;
}

- (int)numWhiteNotes
{
    return [Piano whiteNotesFromPitch:0 numNotes:NOTES_IN_KEYBOARD];
}

- (void)removeFromSuperview
{
    contentOffset = [piano contentOffset];
    [super removeFromSuperview];
    addNote = false;
}

- (int)indexOfPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(pitch < NOTES_IN_OCTAVE);
    return octave * NOTES_IN_OCTAVE + pitch;
}

- (void)boldNotes:(NSMutableArray *)boldNotes
{
    //First unbold all notes
    for(UIButton *note in notes)
    {
        [note.layer setBorderWidth:1];
    }
    for(NSNumber *note in boldNotes)
    {
        pianoNote p = [note unsignedIntValue];
        int index = [self indexOfPitch:[noteTypes pitchOfPianoNote:p] octave:[noteTypes octaveOfPianoNote:p] - MIN_OCTAVE];
        if(index != -1)
            [[[notes objectAtIndex:index] layer] setBorderWidth:4];
    }

}

@end
