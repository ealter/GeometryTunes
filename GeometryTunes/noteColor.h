//
//  noteColor.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/12/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface noteColor : UIView

+ (UIColor*)colorFromNoteWithPitch:(int)pitch AndOctave:(int)octave;

@end
