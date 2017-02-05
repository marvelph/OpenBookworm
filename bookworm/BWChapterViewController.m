//
//  BWChapterViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWChapterViewController.h"

#import "BWAppDelegate.h"
#import "BWBookViewController.h"
#import "BWChapter.h"

@interface BWChapterViewController ()

@end

@implementation BWChapterViewController

- (void)cancel:(id)sender
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;    
    return [appDelegate.chapters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWChapter *chapter = [appDelegate.chapters objectAtIndex:indexPath.row];
    cell.textLabel.text = chapter.caption;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWChapter *chapter = [appDelegate.chapters objectAtIndex:indexPath.row];
    [appDelegate.bookViewController setPageIndex:[appDelegate pageIndexFromChapter:chapter] animated:YES];
    
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
