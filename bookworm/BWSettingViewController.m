//
//  BWSettingViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWSettingViewController.h"

#import "BWAppDelegate.h"
#import "BWBookViewController.h"
#import "BWTextFrameView.h"
#import "BWTextFrame.h"
#import "BWGeometries.h"

@interface BWSettingViewController ()

@end

@implementation BWSettingViewController

- (void)changeFontSize:(id)sender
{
    [self reloadSampleTextForFontSize:self.stepper.value];
}

- (void)done:(id)sender
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.fontSize = self.stepper.value;
    [appDelegate.bookViewController reloadPages];
    
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)cancel:(id)sender
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)reloadSampleTextForFontSize:(CGFloat)fontSize
{
    CGSize layoutSize;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            layoutSize = CGSizeMake(280.0, 137.0);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            switch ([UIDevice currentDevice].userInterfaceIdiom) {
                case UIUserInterfaceIdiomPhone:
                    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                        CGFloat scale = BWTextLayoutWidthForPhone568h / BWTextRotatedWidthForPhone568h > BWTextLayoutHeightForPhone568h / BWTextRotatedHeightForPhone568h ? BWTextLayoutWidthForPhone568h / BWTextRotatedWidthForPhone568h : BWTextLayoutHeightForPhone568h / BWTextRotatedHeightForPhone568h;
                        layoutSize = CGSizeMake(440.0 * scale, 137.0 * scale);
                    }
                    else {
                        CGFloat scale = BWTextLayoutWidthForPhone / BWTextRotatedWidthForPhone > BWTextLayoutHeightForPhone / BWTextRotatedHeightForPhone ? BWTextLayoutWidthForPhone / BWTextRotatedWidthForPhone : BWTextLayoutHeightForPhone / BWTextRotatedHeightForPhone;
                        layoutSize = CGSizeMake(440.0 * scale, 137.0 * scale);
                    }
                    break;
                case UIUserInterfaceIdiomPad: {
                    CGFloat scale = BWTextLayoutWidthForPad / BWTextRotatedWidthForPad > BWTextLayoutHeightForPad / BWTextRotatedHeightForPad ? BWTextLayoutWidthForPad / BWTextRotatedWidthForPad : BWTextLayoutHeightForPad / BWTextRotatedHeightForPad;
                    layoutSize = CGSizeMake(280.0 * scale, 137.0 * scale);
                    break;
                }
            }
            break;
    }
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWTextFrame *textFrame = [appDelegate sampleTextFrameForLayoutSize:layoutSize fontSize:fontSize];
    self.textView.textFrame = textFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    [self reloadSampleTextForFontSize:appDelegate.fontSize];
    
    self.stepper.value = appDelegate.fontSize;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    [self reloadSampleTextForFontSize:appDelegate.fontSize];
}

@end
