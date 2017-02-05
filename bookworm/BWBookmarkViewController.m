//
//  BWBookmarkViewController.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWBookmarkViewController.h"

#import "BWAppDelegate.h"
#import "BWBookViewController.h"
#import "BWChapter.h"
#import "BWLocation.h"
#import "BWBookmark.h"

@interface BWBookmarkViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation BWBookmarkViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *chapterSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chapter" ascending:YES];
        NSSortDescriptor *paragraphSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"paragraph" ascending:YES];
        NSSortDescriptor *characterSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"character" ascending:YES];
        NSArray *sortDescriptors = @[chapterSortDescriptor, paragraphSortDescriptor, characterSortDescriptor];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController.delegate = self;
        _fetchedResultsController = fetchedResultsController;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, error);
            abort();
        }
    }
    return _fetchedResultsController;
}

- (void)cancel:(id)sender
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if ([sectionInfo numberOfObjects] > indexPath.row) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            NSError *error = nil;
            if (![appDelegate.managedObjectContext save:&error]) {
                NSLog(@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, error);
                abort();
            }
            break;
        }
        case UITableViewCellEditingStyleInsert:
            [self addBookmark];
            break;
        default:
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if ([sectionInfo numberOfObjects] > indexPath.row) {
        BWLocation *location = [[BWLocation alloc] init];
        BWBookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        location.chapterIndex = [bookmark.chapter unsignedIntegerValue];
        location.paragraphIndex = [bookmark.paragraph unsignedIntegerValue];
        location.characterIndex = [bookmark.character unsignedIntegerValue];
        
        BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
        NSUInteger pageIndex = [appDelegate pageIndexFromLocation:location];
        if (pageIndex == NSNotFound) {
            pageIndex = [appDelegate.pages count] - 1;
        }
        [appDelegate.bookViewController setPageIndex:pageIndex animated:YES];
    }
    else {
        [self addBookmark];
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    }
    
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.popoverController) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)addBookmark
{
    BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
    BWBookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:appDelegate.managedObjectContext];
    
    BWLocation *location = [appDelegate locationFromPageIndex:[appDelegate.bookViewController pageIndex]];
    bookmark.chapter = @(location.chapterIndex);
    bookmark.paragraph = @(location.paragraphIndex);
    bookmark.character = @(location.characterIndex);
    
    NSError *error = nil;
    if (![self.fetchedResultsController.managedObjectContext save:&error]) {
        NSLog(@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, error);
        abort();
    }
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if ([sectionInfo numberOfObjects] > indexPath.row) {
        BWBookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        BWAppDelegate *appDelegate = (BWAppDelegate *)[UIApplication sharedApplication].delegate;
        BWChapter *chapter = [appDelegate.chapters objectAtIndex:[bookmark.chapter unsignedIntegerValue]];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"bookmarkFormat", nil), [bookmark.chapter unsignedIntegerValue] + 1, chapter.caption, [bookmark.paragraph unsignedIntegerValue] + 1];
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"addBookmark", nil);
    }
}

@end
