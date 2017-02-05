//
//  BWContentViewController.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@class BWPage;

@interface BWContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIControl *control;
@property (nonatomic) BWPage *page;
@property (nonatomic) NSArray *searchHighlights;

- (IBAction)toggleNavigationAndToolbar:(id)sender;

@end
