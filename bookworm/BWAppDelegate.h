//
//  BWAppDelegate.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@class BWBookViewController;
@class BWTextFrame;
@class BWChapter;
@class BWPage;
@class BWLocation;

@interface BWAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (weak, nonatomic) UIPopoverController *popoverController;
@property (readonly, nonatomic) BWBookViewController *bookViewController;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSMutableArray *chapters;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSString *searchingText;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) NSUInteger initialPageIndex;

- (void)layoutPages;
- (BWTextFrame *)sampleTextFrameForLayoutSize:(CGSize)layoutSize fontSize:(CGFloat)fontSize;
- (NSUInteger)pageIndexFromChapter:(BWChapter *)chapter;
- (NSUInteger)pageIndexFromLocation:(BWLocation *)location;
- (BWLocation *)locationFromPageIndex:(NSUInteger)pageIndex;
- (NSArray *)searchHighlightsFromPageIndex:(NSUInteger)pageIndex;
- (UIImage *)imageFromName:(NSString *)name;

@end
