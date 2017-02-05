//
//  BWSearchResult.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWSearchResult : NSObject

@property (nonatomic) NSUInteger chapterIndex;
@property (nonatomic) NSUInteger paragraphIndex;
@property (nonatomic) NSUInteger characterIndex;
@property (nonatomic) NSUInteger characterLength;
@property (nonatomic) NSString *paragraphText;

@end
