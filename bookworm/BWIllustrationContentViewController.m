//
//  BWIllustrationContentViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWIllustrationContentViewController.h"

#import "BWAppDelegate.h"
#import "BWPage.h"

@interface BWIllustrationContentViewController ()

@end

@implementation BWIllustrationContentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    UIImage *image = [appDelegate imageFromName:self.page.imageName];
    self.imageView.image = image;
}

@end
