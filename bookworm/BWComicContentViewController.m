//
//  BWComicContentViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWComicContentViewController.h"

#import "BWAppDelegate.h"
#import "BWPage.h"

@interface BWComicContentViewController ()

@end

@implementation BWComicContentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    UIImage *image = [appDelegate imageFromName:self.page.imageName];
    self.imageView.image = image;
    
    [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.0];
    [self.scrollView flashScrollIndicators];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        CGRect frame = self.view.bounds;
        UIImage *image = self.imageView.image;
        frame.size.height = frame.size.width * image.size.height / image.size.width;
        self.scrollView.contentSize = frame.size;
        self.control.frame = frame;
        self.imageView.frame = frame;
    }
}

@end
