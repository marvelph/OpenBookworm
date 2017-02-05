//
//  BWBookmarkViewController.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWBookmarkViewController : UITableViewController

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

- (IBAction)cancel:(id)sender;

@end
