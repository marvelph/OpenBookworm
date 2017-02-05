//
//  BWTextContentViewController.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWContentViewController.h"

@class BWTextFrameView;

@interface BWTextContentViewController : BWContentViewController

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet BWTextFrameView *textView;

@end
