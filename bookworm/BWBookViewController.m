//
//  BWBookViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWBookViewController.h"

#import "BWAppDelegate.h"
#import "BWContentViewController.h"
#import "BWPage.h"

@interface BWBookViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@end

@implementation BWBookViewController

- (void)beginPageSlider:(id)sender
{
    self.pageIndicator.alpha = 1.0;
    self.chapterIndicator.alpha = 1.0;
}

- (void)endPageSlider:(id)sender
{
    self.pageIndicator.alpha = 0.0;
    self.chapterIndicator.alpha = 0.0;
}

- (void)seekPageSlider:(id)sender
{
    NSUInteger pageIndex = (NSUInteger)self.pageSlider.maximumValue - (NSUInteger)self.pageSlider.value;
    [self seekToPageIndex:pageIndex animated:YES];
    
    self.pageNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"pageIndicatorFormat", nil), (unsigned long)(self.pageSlider.maximumValue - self.pageSlider.value + 1), (unsigned long)(self.pageSlider.maximumValue + 1)];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWPage *page = [appDelegate.pages objectAtIndex:pageIndex];
    self.chapterCaptionLabel.text = page.caption;
}

- (NSUInteger)pageIndex
{
    BWContentViewController *viewController = [self.viewControllers lastObject];
    return [self pageIndexOfViewController:viewController];
}

- (void)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{
    [self seekToPageIndex:pageIndex animated:animated];
    self.pageSlider.value = (NSUInteger)self.pageSlider.maximumValue - pageIndex;
    
    self.pageNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"pageIndicatorFormat", nil), (unsigned long)(self.pageSlider.maximumValue - self.pageSlider.value + 1), (unsigned long)(self.pageSlider.maximumValue + 1)];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWPage *page = [appDelegate.pages objectAtIndex:pageIndex];
    self.chapterCaptionLabel.text = page.caption;
}

- (void)reloadPages
{
    BWContentViewController *viewController = [self.viewControllers lastObject];
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWLocation *location = [appDelegate locationFromPageIndex:[self pageIndexOfViewController:viewController]];
    
    [appDelegate layoutPages];
    
    self.pageSlider.maximumValue = [appDelegate.pages count] - 1;
    
    NSUInteger pageIndex = [appDelegate pageIndexFromLocation:location];
    if (pageIndex == NSNotFound) {
        pageIndex = [appDelegate.pages count] - 1;
    }
    
    viewController = [self viewControllerAtPageIndex:pageIndex storyboard:self.storyboard];
    NSArray *viewControllers;
    if (!self.doubleSided) {
        viewControllers = @[viewController];
    }
    else {
        if (pageIndex % 2 == 0) {
            UIViewController *nextViewController = [self pageViewController:self viewControllerBeforeViewController:viewController];
            viewControllers = @[nextViewController, viewController];
        } else {
            UIViewController *previousViewController = [self pageViewController:self viewControllerAfterViewController:viewController];
            viewControllers = @[viewController, previousViewController];
        }
    }
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)seekToPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    for (BWContentViewController *viewController in self.viewControllers) {
        NSUInteger index = [self pageIndexOfViewController:viewController];
        if (index == pageIndex) {
            return;
        }
        else {
            if (index < pageIndex) {
                direction = UIPageViewControllerNavigationDirectionReverse;
            }
        }
    }
    
    BWContentViewController *viewController = [self viewControllerAtPageIndex:pageIndex storyboard:self.storyboard];
    NSArray *viewControllers;
    if (!self.doubleSided) {
        viewControllers = @[viewController];
    }
    else {
        if (pageIndex % 2 == 0) {
            UIViewController *nextViewController = [self pageViewController:self viewControllerBeforeViewController:viewController];
            viewControllers = @[nextViewController, viewController];
        } else {
            UIViewController *previousViewController = [self pageViewController:self viewControllerAfterViewController:viewController];
            viewControllers = @[viewController, previousViewController];
        }
    }
    [self setViewControllers:viewControllers direction:direction animated:animated completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    self.navigationItem.rightBarButtonItems = @[self.chapterBarItem, self.bookmarkBarItem, self.searchBarItem];
    
    self.pageSlider.minimumValue = 0;
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    self.pageSlider.maximumValue = [appDelegate.pages count] - 1;
    
    NSUInteger pageIndex = appDelegate.initialPageIndex;
    if (pageIndex >= [appDelegate.pages count]) {
        pageIndex = [appDelegate.pages count] - 1;
    }
    [self seekToPageIndex:pageIndex animated:NO];
    self.pageSlider.value = (NSUInteger)self.pageSlider.maximumValue - pageIndex;
    
    self.pageNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"pageIndicatorFormat", nil), (unsigned long)(self.pageSlider.maximumValue - self.pageSlider.value + 1), (unsigned long)(self.pageSlider.maximumValue + 1)];
    
    BWPage *page = [appDelegate.pages objectAtIndex:pageIndex];
    self.chapterCaptionLabel.text = page.caption;
    
    CGRect frame = self.pageIndicator.frame;
    frame.origin.x = (NSInteger)((self.navigationController.view.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = (NSInteger)((self.navigationController.view.bounds.size.height - frame.size.height) * 2.0 / 3.0);
    self.pageIndicator.frame = frame;
    self.pageIndicator.layer.cornerRadius = 4.0;
    
    frame = self.chapterIndicator.frame;
    frame.origin.x = (NSInteger)((self.navigationController.view.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = (NSInteger)((self.navigationController.view.bounds.size.height - frame.size.height) / 3.0);
    self.chapterIndicator.frame = frame;
    self.chapterIndicator.layer.cornerRadius = 4.0;
    
    self.navigationController.navigationBar.alpha = 0.0;
    self.navigationController.toolbar.alpha = 0.0;
    self.pageIndicator.alpha = 0.0;
    self.chapterIndicator.alpha = 0.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.view addSubview:self.pageIndicator];
    [self.navigationController.view addSubview:self.chapterIndicator];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.pageIndicator removeFromSuperview];
    [self.chapterIndicator removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.popoverController) {
            [appDelegate.popoverController dismissPopoverAnimated:YES];
        }
        appDelegate.popoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        BWContentViewController *viewController = [self.viewControllers lastObject];
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (BWContentViewController *)viewControllerAtPageIndex:(NSUInteger)pageIndex storyboard:(UIStoryboard *)storyboard
{   
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (([appDelegate.pages count] == 0) || (pageIndex >= [appDelegate.pages count])) {
        return nil;
    }
    
    BWPage *page = [appDelegate.pages objectAtIndex:pageIndex];
    NSString *identifier = nil;
    switch (page.type) {
        case BWPageTypeText:
            identifier = @"TextContentViewController";
            break;
        case BWPageTypeIllustration:
            identifier = @"IllustrationContentViewController";
            break;
        case BWPageTypeComic:
            identifier = @"ComicContentViewController";
            break;
        case BWPageTypeBlank:
            identifier = @"BlankContentViewController";
            break;
    }
    BWContentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    viewController.page = page;
    viewController.searchHighlights = [appDelegate searchHighlightsFromPageIndex:pageIndex];
    return viewController;
}

- (NSUInteger)pageIndexOfViewController:(BWContentViewController *)viewController
{   
    return viewController.page.index;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexOfViewController:(BWContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (index == [appDelegate.pages count]) {
        return nil;
    }
    return [self viewControllerAtPageIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self pageIndexOfViewController:(BWContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtPageIndex:index storyboard:viewController.storyboard];
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!self.navigationController.navigationBarHidden) {
        [UIView animateWithDuration:0.5 animations:^{
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        }];
    }
    
    BWContentViewController *viewController = [pageViewController.viewControllers lastObject];
    NSUInteger pageIndex =  [self pageIndexOfViewController:viewController];
    self.pageSlider.value = (NSUInteger)self.pageSlider.maximumValue - pageIndex;
    
    self.pageNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"pageIndicatorFormat", nil), (unsigned long)(self.pageSlider.maximumValue - self.pageSlider.value + 1), (unsigned long)(self.pageSlider.maximumValue + 1)];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWPage *page = [appDelegate.pages objectAtIndex:pageIndex];
    self.chapterCaptionLabel.text = page.caption;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation) || ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)) {
        BWContentViewController *viewController = [pageViewController.viewControllers lastObject];
        NSArray *viewControllers = @[viewController];
        [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        
        pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMax;
    }
    else {
        BWContentViewController *viewController = [pageViewController.viewControllers lastObject];
        NSArray *viewControllers = nil;
        
        NSUInteger pageIndex = [self pageIndexOfViewController:viewController];
        if (pageIndex % 2 == 0) {
            UIViewController *nextViewController = [self pageViewController:pageViewController viewControllerBeforeViewController:viewController];
            viewControllers = @[nextViewController, viewController];
        } else {
            UIViewController *previousViewController = [self pageViewController:pageViewController viewControllerAfterViewController:viewController];
            viewControllers = @[viewController, previousViewController];
        }
        [pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        
        return UIPageViewControllerSpineLocationMid;
    }
}

@end
