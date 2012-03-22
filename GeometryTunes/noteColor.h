//
//  noteColor.h
//  GeometryTunes
//
//  Created by Dylan Portelance on 3/12/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

@interface noteColor : NSObject

+ (UIColor*)colorFromNoteWithPitch:(int)pitch octave:(int)octave;

@end
