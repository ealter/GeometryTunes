//
//  Piano.h
//  GeometryTunes
//
//  Created by Music2 on 3/10/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Piano : UIView
{
    NSMutableArray *notes;
    int numNotes;
    int numWhiteNotes;
}

@property unsigned octave;

- (id)sharedInit;
- (void)updateColors; //Sets all of the colors of the piano

@end
