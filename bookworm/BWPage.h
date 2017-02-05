//
//  BWPage.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@class BWTextFrame;

typedef enum {
    BWPageTypeText,
    BWPageTypeIllustration,
    BWPageTypeComic,
    BWPageTypeBlank,
} BWPageType;

@interface BWPage : NSObject

@property (nonatomic) NSUInteger index;
@property (nonatomic) BWPageType type;
@property (nonatomic) NSUInteger number; 
@property (nonatomic) NSString *caption;
@property (nonatomic) BWTextFrame *textFrame;
@property (nonatomic) NSString *imageName;
@property (nonatomic) NSUInteger chapterIndex;
@property (nonatomic) NSUInteger firstParagraphIndex;
@property (nonatomic) NSUInteger firstCharacterIndex;
@property (nonatomic) NSUInteger lastParagraphIndex;
@property (nonatomic) NSUInteger lastCharacterIndex;
@property (nonatomic) NSArray *characterLengths;

@end
