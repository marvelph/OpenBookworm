//
//  BWTextFrame.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWTextFrame.h"

@implementation BWTextFrame

- (void)dealloc
{
    if (_ctFrame) {
        CFRelease(_ctFrame);
    }
}

- (void)setCtFrame:(CTFrameRef)ctFrame
{
    if (_ctFrame != ctFrame) {
        if (_ctFrame) {
            CFRelease(_ctFrame);
        }
        _ctFrame = ctFrame;
        if (_ctFrame) {
            CFRetain(_ctFrame);
        }
    }
}

@end
