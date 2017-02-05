//
//  BWAttributedLabel.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@interface BWAttributedLabel : UIView

@property (nonatomic) NSAttributedString *attributedText;
@property(nonatomic, getter=isHighlighted) BOOL highlighted;

@end
