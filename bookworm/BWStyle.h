//
//  BWStyle.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

typedef enum {
    BWStyleTypeHead,
    BWStyleTypeBold,
} BWStyleType;

@interface BWStyle : NSObject

@property (nonatomic) BWStyleType type;
@property (nonatomic) NSRange range;

@end
