//
//  BWParagraph.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

typedef enum {
    BWParagraphTypeText,
    BWParagraphTypeIllustration,
    BWParagraphTypeComic,
} BWParagraphType;

@interface BWParagraph : NSObject

@property (nonatomic) BWParagraphType type;
@property (nonatomic) NSString *text;
@property (nonatomic) NSMutableArray *styles;
@property (nonatomic) NSString *imageName;

@end
