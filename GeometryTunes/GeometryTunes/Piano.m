#import "Piano.h"
#import <QuartzCore/QuartzCore.h>

#define NOTES_IN_KEYBOARD NOTES_IN_OCTAVE

@implementation Piano

#import "noteTypes.h"
#import "noteColor.h"
#import "GridView.h"

@synthesize octave, pitchOffset, numNotes;
@synthesize notePlayer;

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
    octave = INITIAL_PIANO_OCTAVE;
    numNotes = NOTES_IN_KEYBOARD;
    pitchOffset = 0;
    notes = [NSMutableArray arrayWithCapacity:numNotes];
    notePlayer = [[NotePlayer alloc]init];
    [self setBackgroundColor:[UIColor whiteColor]];
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int width = rect.size.width;
    int height = rect.size.height;
    const float octaveButtonRelativeSize = 1.3;
    const float whiteKeyWidth = ((float)width) / ([self numWhiteNotes]+octaveButtonRelativeSize*2);
    float x = 0;
    
    float buttonWidth = whiteKeyWidth*octaveButtonRelativeSize;
    
    for(int i = 0, heightOffset = 0; i < 2; heightOffset += height/2, i++)
    {
        UIButton *octaveBtn = [[UIButton alloc]initWithFrame:CGRectMake(x, heightOffset, buttonWidth, height/2)];
        [octaveBtn setBackgroundColor:[UIColor blueColor]];
        if(i == 0)
        {
            [octaveBtn setTitle:@"+" forState:UIControlStateNormal];
            octaveBtn.tag = 1;
        }
        else
        {
            [octaveBtn setTitle:@"-" forState:UIControlStateNormal];
            octaveBtn.tag = -1;
        }
        octaveBtn.titleLabel.font = [UIFont systemFontOfSize:70];
        octaveBtn.titleLabel.textColor = [UIColor blackColor];
        [octaveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [octaveBtn.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [octaveBtn.layer setBorderWidth:2];
        [octaveBtn addTarget:self action:@selector(OctaveChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
        
        [self addSubview:octaveBtn];
    }
    
    x += buttonWidth;
    
    float blackKeyWidth = whiteKeyWidth/2;
    float blackKeyHeight = height*2/3;
    UIButton *note;
    int whiteKeyNum = 0;
    bool isBlack;

    for(int i=pitchOffset; i<numNotes + pitchOffset; i++)
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
        
        [note setBackgroundColor:[noteColor colorFromNoteWithPitch:i % NOTES_IN_OCTAVE octave:octave + i/NOTES_IN_OCTAVE]];
        note.tag = i;
        [note addTarget:self action:@selector(KeyClicked:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
        [self addSubview:note];
        if(!isBlack)
            [self sendSubviewToBack:note];
        [note.layer setBorderWidth:1];
        [note.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [notes addObject:note];
    }
    
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
    int oct   = note.tag / NOTES_IN_OCTAVE + octave;
    [delegate changeNoteWithPitch:pitch octave:oct appendNote:addNote];
    [delegate playNote];
    addNote = false;
    [self boldNotes:[delegate notes]];
}

- (void)OctaveChanged:(id)sender
{
    UIButton *octaveBtn = sender;
    int newOctave = octave + octaveBtn.tag;
    int maxOctave = MAX_OCTAVE + numNotes / NOTES_IN_OCTAVE;
    if(newOctave > maxOctave)
        octave = maxOctave;
    else if(newOctave < MIN_OCTAVE)
        octave = MIN_OCTAVE;
    else
    {
        octave = newOctave;
        for(int i=0; i<numNotes; i++)
        {
            UIButton *note = [notes objectAtIndex:i];
            [note setBackgroundColor:[noteColor colorFromNoteWithPitch:i % NOTES_IN_OCTAVE octave:octave + i / NOTES_IN_OCTAVE]];
        }
        [delegate setPianoOctave:octave];
    }
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
    return [Piano whiteNotesFromPitch:pitchOffset numNotes:numNotes];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    addNote = false;
}

- (int)indexOfPitch:(unsigned int)pitch octave:(unsigned int)octave_
{
    assert(pitch < NOTES_IN_OCTAVE);
    int i = (octave_ - octave) * NOTES_IN_OCTAVE + pitch - pitchOffset;
    if (i >= 0 && i < numNotes)
        return i;
    else
        return -1;
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
        int index = [self indexOfPitch:[noteTypes pitchOfPianoNote:p] octave:[noteTypes octaveOfPianoNote:p]];
        NSLog(@"index: %d", index);
        if(index != -1)
            [[[notes objectAtIndex:index] layer] setBorderWidth:4];
    }
}

@end
