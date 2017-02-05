//
//  BWBookViewController.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWBookViewController : UIPageViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *chapterBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBarItem;
@property (weak, nonatomic) IBOutlet UISlider *pageSlider;
@property (weak, nonatomic) IBOutlet UIView *pageIndicator;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *chapterIndicator;
@property (weak, nonatomic) IBOutlet UILabel *chapterCaptionLabel;

- (IBAction)beginPageSlider:(id)sender;
- (IBAction)seekPageSlider:(id)sender;
- (IBAction)endPageSlider:(id)sender;

- (NSUInteger)pageIndex;
- (void)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)reloadPages;

@end
