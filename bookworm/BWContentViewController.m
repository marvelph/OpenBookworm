//
//  BWContentViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWContentViewController.h"

@interface BWContentViewController ()

@end

@implementation BWContentViewController

- (void)toggleNavigationAndToolbar:(id)sender
{
    if (self.navigationController.navigationBar.alpha == 0.0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationController.navigationBar.alpha = 1.0;
            self.navigationController.toolbar.alpha = 1.0;
        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
