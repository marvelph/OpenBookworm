//
//  BWBlankContentViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWBlankContentViewController.h"

#import "BWPage.h"

@interface BWBlankContentViewController ()

@end

@implementation BWBlankContentViewController

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
}

@end
