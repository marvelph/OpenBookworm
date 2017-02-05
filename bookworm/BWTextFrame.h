//
//  BWTextFrame.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWTextFrame : NSObject

@property (nonatomic) CTFrameRef ctFrame;
@property (nonatomic) CGSize layoutSize;

@end
