//
//  BWBookmark.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWBookmark : NSManagedObject

@property (nonatomic) NSNumber *chapter;
@property (nonatomic) NSNumber *paragraph;
@property (nonatomic) NSNumber *character;

@end
