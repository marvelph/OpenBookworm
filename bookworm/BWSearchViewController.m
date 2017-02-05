//
//  BWSearchViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWSearchViewController.h"

#import "BWAppDelegate.h"
#import "BWBookViewController.h"
#import "BWSearchViewCell.h"
#import "BWAttributedLabel.h"
#import "BWLocation.h"
#import "BWSearchResult.h"

@interface BWSearchViewController ()

@end

@implementation BWSearchViewController

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.searchingText = searchBar.text;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate addObserver:self forKeyPath:@"searchResults" options:0 context:NULL];
    
    self.searchBar.text = appDelegate.searchingText;
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate removeObserver:self forKeyPath:@"searchResults"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    switch ([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue]) {
        case NSKeyValueChangeInsertion: {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSKeyValueChangeReplacement: {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case NSKeyValueChangeRemoval: {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Table view data source

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    return [appDelegate.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWSearchResult *searchResult = [appDelegate.searchResults objectAtIndex:indexPath.row];
    NSUInteger prefixLength = searchResult.characterIndex;
    if (prefixLength > 20) {
        prefixLength = 20;
    }
    NSString *prefix = [searchResult.paragraphText substringWithRange:NSMakeRange(searchResult.characterIndex - prefixLength, prefixLength)];
    NSUInteger suffixLength = [searchResult.paragraphText length] - searchResult.characterIndex - searchResult.characterLength;
    if (suffixLength > 20) {
        suffixLength = 20;
    }
    NSString *suffix = [searchResult.paragraphText substringWithRange:NSMakeRange(searchResult.characterIndex + searchResult.characterLength, suffixLength)];
    NSString *searchingText = [searchResult.paragraphText substringWithRange:NSMakeRange(searchResult.characterIndex, searchResult.characterLength)];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    CTFontRef plainFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W3", 14.0, NULL);
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W6", 14.0, NULL);
    
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:prefix attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)plainFont}]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:searchingText attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)boldFont}]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:suffix attributes:@{(NSString *)kCTFontAttributeName: (__bridge id)plainFont}]];
    
    CFRelease(plainFont);
    CFRelease(boldFont);
    
    cell.attributedLabel.attributedText = attributedText;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWSearchResult *searchResult = [appDelegate.searchResults objectAtIndex:indexPath.row];
    BWLocation *location = [[BWLocation alloc] init];
    location.chapterIndex = searchResult.chapterIndex;
    location.paragraphIndex = searchResult.paragraphIndex;
    location.characterIndex = searchResult.characterIndex;
    NSUInteger pageIndex = [appDelegate pageIndexFromLocation:location];
    if (pageIndex == NSNotFound) {
        pageIndex = [appDelegate.pages count] - 1;
    }
    [appDelegate.bookViewController setPageIndex:pageIndex animated:YES];
    
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
