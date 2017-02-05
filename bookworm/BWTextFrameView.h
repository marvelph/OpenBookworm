//
//  BWTextFrameView.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@class BWTextFrame;

@interface BWTextFrameView : UIView

@property (nonatomic) BWTextFrame *textFrame;
@property (nonatomic) NSArray *searchHighlights;

@end
