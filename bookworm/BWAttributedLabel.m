//
//  BWAttributedLabel.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWAttributedLabel.h"

@implementation BWAttributedLabel

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (_attributedText != attributedText) {
        _attributedText = attributedText;
        
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    if (self.highlighted) {
        [attributedText addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor whiteColor].CGColor range:NSMakeRange(0, [attributedText length])];
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path.CGPath, NULL);
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CTFrameDraw(frame, context);
    
    CFRelease(framesetter);
    CFRelease(frame);
}

@end
