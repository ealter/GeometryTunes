#import "Piano.h"
#import <QuartzCore/QuartzCore.h>
#import "scrollViewWithButtons.h"
#import "noteTypes.h"
#import "noteColor.h"
#import "GridView.h"

#define NOTES_IN_KEYBOARD NOTES_IN_OCTAVE
#define INITIAL_PITCH 0
#define INITIAL_OCTAVE 5
#define BUTTON_RELATIVE_SIZE 0.8

//How long a note is played when it is clicked on the piano
#define NOTE_DURATION 1

@implementation Piano

@synthesize piano, contentOffset;

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
    [self setBackgroundColor:[UIColor whiteColor]];
    if(piano) {
        [piano setContentOffset:contentOffset];
    }
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 5;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 3;
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int width = rect.size.width;
    int height = rect.size.height;
    
    const float whiteKeyWidth = ((float)width) / ([Piano whiteNotesFromPitch:0 numNotes:NOTES_IN_KEYBOARD] + BUTTON_RELATIVE_SIZE);
    
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
        [piano setBackgroundColor:[UIColor blackColor]];
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
    for(int i=0; i<TOTAL_NUM_KEYS; i++)
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
        if([Piano isBlackNote:i])
        {
            note.layer.shadowColor = [UIColor blackColor].CGColor;
            note.layer.shadowOpacity = 0.8;
            note.layer.shadowRadius = 7;
        }
        note.tag = i;
        [piano addSubview:note];
        [note addTarget:self action:@selector(KeyClicked:) forControlEvents:UIControlEventTouchUpInside];

        if(!isBlack)
            [piano sendSubviewToBack:note];
        [note.layer setBorderWidth:1];
        [note.layer setBorderColor:[[UIColor blackColor] CGColor]];
        notes[i] = note;
    }
    
    x = width - buttonWidth;
    //Make "clear" button
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, buttonWidth, height)];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    btn.titleLabel.textAlignment = UITextAlignmentCenter;
    [btn setTitle:@"Clear" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:25];
    btn.titleLabel.textColor = [UIColor blackColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [btn.layer setBorderWidth:2];
    [btn addTarget:self action:@selector(noteClearEvent) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btn];
    
    //Add the cancel button
    /*width = 40;
    height = width;
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(rect.size.width - width, 0, width, height)];
    [cancelBtn setBackgroundColor:[UIColor blackColor]];
    [cancelBtn addTarget:delegate action:@selector(changeToNormalState) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];*/
    
    [self boldNotes:[delegate notes]];
}

//Determines whether the cell being edited already contains the note
- (BOOL)containsNote:(midinote)note
{
    NSMutableArray *cellNotes = [delegate notes];
    for(NSNumber *n in cellNotes)
    {
        if([n unsignedIntValue] == note)
            return TRUE;
    }
    return FALSE;
}

- (void)KeyClicked:(id)sender
{
    UIButton *note = sender;
    int pitch = note.tag % NOTES_IN_OCTAVE;
    int oct   = note.tag / NOTES_IN_OCTAVE + MIN_OCTAVE;
    midinote n = pitch + oct * NOTES_IN_OCTAVE;
    if([self containsNote:n])
        [delegate removeNoteWithPitch:pitch octave:oct];
    else
        [delegate addNoteWithPitch:pitch octave:oct];
    [delegate playCurrentCellForDuration:NOTE_DURATION];
    [self boldNotes:[delegate notes]];
}

- (void)gridCellHasChanged
{
    [self boldNotes:[delegate notes]];
}

- (void)noteClearEvent
{
    [delegate clearNote];
    [self gridCellHasChanged];
}

+ (bool)isBlackNote:(int)pitch
{
    int n = pitch % NOTES_IN_OCTAVE;
    return n == 1 || n == 3 || n == 6 || n == 8 || n == 10;
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

- (void)removeFromSuperview
{
    contentOffset = [piano contentOffset];
    [super removeFromSuperview];
}

- (int)indexOfPitch:(unsigned int)pitch octave:(unsigned int)octave
{
    assert(pitch < NOTES_IN_OCTAVE);
    return octave * NOTES_IN_OCTAVE + pitch;
}

- (void)boldNotes:(NSMutableArray *)boldNotes
{
    //First unbold all notes
    for(int i=0; i<TOTAL_NUM_KEYS; i++)
    {
        [notes[i].layer setBorderWidth:1];
    }
    for(NSNumber *note in boldNotes)
    {
        midinote p = [note unsignedIntValue];
        int index = [self indexOfPitch:p % NOTES_IN_OCTAVE octave:p / NOTES_IN_OCTAVE - MIN_OCTAVE];
        if(index != -1)
            [[notes[index] layer] setBorderWidth:4];
    }

}

@end
