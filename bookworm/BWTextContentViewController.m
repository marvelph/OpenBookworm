//
//  BWTextContentViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWTextContentViewController.h"

#import "BWTextFrameView.h"
#import "BWPage.h"

@interface BWTextContentViewController ()

@end

@implementation BWTextContentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.numberLabel.text = [NSString stringWithFormat:@"P. %lu", (unsigned long)self.page.number + 1];
    if ((self.page.number + 1) % 2 == 1) {
        self.numberLabel.textAlignment = UITextAlignmentRight;
    }
    else {
        self.numberLabel.textAlignment = UITextAlignmentLeft;
    }
    self.captionLabel.text = self.page.caption;
    self.textView.textFrame = self.page.textFrame;
    self.textView.searchHighlights = self.searchHighlights;
}

@end
