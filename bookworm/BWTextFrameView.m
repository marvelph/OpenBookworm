//
//  BWTextFrameView.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWTextFrameView.h"

#import "BWTextFrame.h"

@implementation BWTextFrameView

- (void)setTextFrame:(BWTextFrame *)textFrame
{
    if (_textFrame != textFrame) {
        _textFrame = textFrame;
        
        [self setNeedsDisplay];
    }
}

- (void)setSearchHighlights:(NSArray *)searchHighlights
{
    if (_searchHighlights != searchHighlights) {
        _searchHighlights = searchHighlights;
        
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat layoutWidth = self.textFrame.layoutSize.width;
    CGFloat layoutHeight = self.textFrame.layoutSize.height;
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    if (viewWidth / viewHeight > layoutWidth / layoutHeight) {
        viewWidth = layoutWidth / layoutHeight * viewHeight;
    }
    else {
        viewHeight = viewWidth / layoutWidth * layoutHeight;
    }
    
    CGContextTranslateCTM(context, (CGRectGetWidth(self.bounds) - viewWidth) / 2.0, (CGRectGetHeight(self.bounds) - viewHeight) / 2.0);
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextRotateCTM(context, -M_PI_2);
    CGContextTranslateCTM(context, -CGRectGetHeight(self.bounds), 0.0);
    CGContextScaleCTM(context, viewHeight / layoutHeight, viewWidth / layoutWidth);
    
    if (self.searchHighlights) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
        
        CFRange frameRange = CTFrameGetVisibleStringRange(self.textFrame.ctFrame);
        CFArrayRef lines = CTFrameGetLines(self.textFrame.ctFrame);
        CGPoint origins[CFArrayGetCount(lines)];
        CTFrameGetLineOrigins(self.textFrame.ctFrame, CFRangeMake(0, CFArrayGetCount(lines)), origins);
        for (CFIndex index = 0; index < CFArrayGetCount(lines); index++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, index);
            CFRange lineRange = CTLineGetStringRange(line);
            for (NSValue *searchHighlight in self.searchHighlights) {
                NSRange range = [searchHighlight rangeValue];
                range.location += frameRange.location;
                range = NSIntersectionRange(range, NSMakeRange(lineRange.location, lineRange.length));
                if (range.length > 0) {
                    CGRect bounds = CTLineGetImageBounds(line, context);
                    bounds.origin.x = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                    bounds.size.width = CTLineGetOffsetForStringIndex(line, range.location + range.length, NULL) - bounds.origin.x;
                    
                    CGContextBeginPath(context);
                    CGContextAddRect(context, CGRectOffset(bounds, origins[index].x, origins[index].y));
                    CGContextFillPath(context);
                }
            }
        }
    }
    
    CTFrameDraw(self.textFrame.ctFrame, context);
}

@end
