#import <AVFoundation/AVFoundation.h>
#import "noteTypes.h"

@interface MidiController : NSObject <AVAudioSessionDelegate>

- (void)noteOn: (midinote)note;
- (void)noteOff:(midinote)note;

@end
