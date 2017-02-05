//
//  BWAppDelegate.m
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

#import "BWAppDelegate.h"

#import "BWBookViewController.h"
#import "BWTextFrame.h"
#import "BWChapter.h"
#import "BWParagraph.h"
#import "BWStyle.h"
#import "BWPage.h"
#import "BWLocation.h"
#import "BWSearchResult.h"
#import "BWGeometries.h"

@interface BWAppDelegate ()

@end

@implementation BWAppDelegate {
    BOOL _useDocumentDirectory;
}

- (BWBookViewController *)bookViewController
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    return (BWBookViewController *)navigationController.topViewController;
}

- (NSArray *)chapters
{
    if (!_chapters) {
        [self loadContents];
    }
    return _chapters;
}

- (void)loadContents
{
    self.chapters = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"main.txt"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
        _useDocumentDirectory = YES;
    }
    else {
        path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"txt"];
        _useDocumentDirectory = NO;
    }
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSRange range = NSMakeRange(0, [text length]);
    while (range.length > 0) {
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(range.location, 0)];
        NSString *line = [text substringWithRange:lineRange];
        range.location = NSMaxRange(lineRange);
        range.length -= [line length];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        switch ([line length] > 0 ? [line characterAtIndex:0] : 0x0000) {
            case '#': {
                BWChapter *chapter = [[BWChapter alloc] init];
                line = [line substringFromIndex:1];
                chapter.caption = line;
                chapter.paragraphs = [NSMutableArray array];
                [self.chapters addObject:chapter];
                break;
            }
            case '!': {
                BWParagraph *paragraph = [[BWParagraph alloc] init];
                paragraph.type = BWParagraphTypeIllustration;
                line = [line substringFromIndex:1];
                paragraph.imageName = line;
                BWChapter *chapter = [self.chapters lastObject];
                [chapter.paragraphs addObject:paragraph];
                break;
            }
            case '?': {
                BWParagraph *paragraph = [[BWParagraph alloc] init];
                paragraph.type = BWParagraphTypeComic;
                line = [line substringFromIndex:1];
                paragraph.imageName = line;
                BWChapter *chapter = [self.chapters lastObject];
                [chapter.paragraphs addObject:paragraph];
                break;
            }
            case '*': {
                BWParagraph *paragraph = [[BWParagraph alloc] init];
                paragraph.type = BWParagraphTypeText;
                line = [line substringFromIndex:1];
                paragraph.text = line;
                BWStyle *style = [[BWStyle alloc] init];
                style.type = BWStyleTypeHead;
                style.range = NSMakeRange(0, [line length]);
                paragraph.styles = [NSMutableArray arrayWithObject:style];
                BWChapter *chapter = [self.chapters lastObject];
                [chapter.paragraphs addObject:paragraph];
                break;
            }
            default: {
                BWParagraph *paragraph = [[BWParagraph alloc] init];
                paragraph.type = BWParagraphTypeText;
                NSMutableString *plainLine = [NSMutableString string];
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\[.*?\\]" options:0 error:nil];
                __block NSUInteger location = 0;
                [regexp enumerateMatchesInString:line options:0 range:NSMakeRange(0, [line length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    [plainLine appendString:[line substringWithRange:NSMakeRange(location, result.range.location - location)]];
                    NSString *boldLine = [line substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)];
                    BWStyle *style = [[BWStyle alloc] init];
                    style.type = BWStyleTypeBold;
                    style.range = NSMakeRange([plainLine length], [boldLine length]);
                    if (!paragraph.styles) {
                        paragraph.styles = [NSMutableArray array];
                    }
                    [paragraph.styles addObject:style];
                    [plainLine appendString:boldLine];
                    location = result.range.location + result.range.length;
                }];
                [plainLine appendString:[line substringWithRange:NSMakeRange(location, [line length] - location)]];
                paragraph.text = plainLine;
                BWChapter *chapter = [self.chapters lastObject];
                [chapter.paragraphs addObject:paragraph];
                break;
            }
        }
    }
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"%s(%d) %@", __PRETTY_FUNCTION__, __LINE__, error);
            abort();
        }    
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (void)setSearchingText:(NSString *)searchingText
{
    if (_searchingText == searchingText) {
        return;
    }
    _searchingText = searchingText;
    
    [[self mutableArrayValueForKey:@"searchResults"]removeAllObjects];
    
    for (NSUInteger chapterIndex = 0; chapterIndex < [self.chapters count]; chapterIndex++) {
        BWChapter *chapter = [self.chapters objectAtIndex:chapterIndex];
        for (NSUInteger paragraphIndex = 0; paragraphIndex < [chapter.paragraphs count]; paragraphIndex++) {
            BWParagraph *paragraph = [chapter.paragraphs objectAtIndex:paragraphIndex];
            switch (paragraph.type) {
                case BWParagraphTypeText: {
                    NSRange range = NSMakeRange(0, [paragraph.text length]);
                    while (range.location != NSNotFound) {
                        range = [paragraph.text rangeOfString:self.searchingText options:NSCaseInsensitiveSearch range:range];
                        if (range.location != NSNotFound) {
                            BWSearchResult *searchResult = [[BWSearchResult alloc] init];
                            searchResult.chapterIndex = chapterIndex;
                            searchResult.paragraphIndex = paragraphIndex;
                            searchResult.characterIndex = range.location;
                            searchResult.characterLength = range.length;
                            searchResult.paragraphText = paragraph.text;
                            [[self mutableArrayValueForKey:@"searchResults"] addObject:searchResult];
                            
                            range = NSMakeRange(range.location + range.length, [paragraph.text length] - range.location - range.length);
                        }
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)layoutPages
{
    self.pages = [NSMutableArray array];
    
    CGSize layoutSize;
    switch ([UIDevice currentDevice].userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                layoutSize = CGSizeMake(BWTextLayoutWidthForPhone568h, BWTextLayoutHeightForPhone568h);
            } else {
                layoutSize = CGSizeMake(BWTextLayoutWidthForPhone, BWTextLayoutHeightForPhone);
            }
            break;
        case UIUserInterfaceIdiomPad:
            layoutSize = CGSizeMake(BWTextLayoutWidthForPad, BWTextLayoutHeightForPad);
            break;
    }
    CGRect bounds = CGRectMake(0.0, 0.0, layoutSize.height, layoutSize.width);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
    CTFontRef plainFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W3", self.fontSize, NULL);
    CTFontRef headFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W6", self.fontSize * 1.2, NULL);
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W6", self.fontSize, NULL);
    NSDictionary *defaultAttributes = @{(NSString *)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyle, (NSString *)kCTFontAttributeName: (__bridge id)plainFont, (NSString *)kCTVerticalFormsAttributeName: (id)kCFBooleanTrue};
    CFRelease(paragraphStyle);
    
    for (NSUInteger chapterIndex = 0; chapterIndex < [self.chapters count]; chapterIndex++) {
        BWChapter *chapter = [self.chapters objectAtIndex:chapterIndex];
        
        NSMutableAttributedString *text = nil;
        NSUInteger firstParagraphIndex = NSNotFound;
        NSMutableArray *paragraphRanges = nil;
        for (NSUInteger paragraphIndex = 0; paragraphIndex < [chapter.paragraphs count]; paragraphIndex++) {
            BWParagraph *paragraph = [chapter.paragraphs objectAtIndex:paragraphIndex];
            switch (paragraph.type) {
                case BWParagraphTypeText: {
                    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:paragraph.text attributes:defaultAttributes];
                    for (BWStyle *style in paragraph.styles) {
                        switch (style.type) {
                            case BWStyleTypeHead:
                                [line addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)headFont range:style.range];
                                break;
                            case BWStyleTypeBold:
                                [line addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:style.range];
                                break;
                        }
                    }
                    
                    if (!text) {
                        text = [[NSMutableAttributedString alloc] initWithAttributedString:line];
                        firstParagraphIndex = paragraphIndex;
                        NSRange paragraphRange = NSMakeRange(0, [line length] + 1);
                        paragraphRanges = [NSMutableArray arrayWithObject:[NSValue valueWithRange:paragraphRange]];
                    }
                    else {
                        [text appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:defaultAttributes]];
                        NSRange paragraphRange = NSMakeRange([text length], [line length] + 1);
                        [paragraphRanges addObject:[NSValue valueWithRange:paragraphRange]];
                        [text appendAttributedString:line];
                    }
                    break;
                }
                case BWParagraphTypeIllustration: {
                    if (text) {
                        [self layoutText:text caption:chapter.caption chapterIndex:chapterIndex firstParagraphIndex:firstParagraphIndex paragraphRanges:paragraphRanges layoutSize:layoutSize path:path];
                        text = nil;
                    }
                    
                    BWPage *page = [[BWPage alloc] init];
                    page.index = [self.pages count];
                    page.type = BWPageTypeIllustration;
                    page.number = [self.pages count];
                    page.caption = chapter.caption;
                    page.imageName = paragraph.imageName;
                    page.chapterIndex = chapterIndex;
                    page.firstParagraphIndex = paragraphIndex;
                    page.firstCharacterIndex = 0;
                    page.lastParagraphIndex = paragraphIndex;
                    page.lastCharacterIndex = 0;
                    page.characterLengths = @[[NSNumber numberWithUnsignedInteger:1]];
                    [self.pages addObject:page];
                    break;
                }
                case BWParagraphTypeComic: {
                    if (text) {
                        [self layoutText:text caption:chapter.caption chapterIndex:chapterIndex firstParagraphIndex:firstParagraphIndex paragraphRanges:paragraphRanges layoutSize:layoutSize path:path];
                        text = nil;
                    }
                    
                    BWPage *page = [[BWPage alloc] init];
                    page.index = [self.pages count];
                    page.type = BWPageTypeComic;
                    page.number = [self.pages count];
                    page.caption = chapter.caption;
                    page.imageName = paragraph.imageName;
                    page.chapterIndex = chapterIndex;
                    page.firstParagraphIndex = paragraphIndex;
                    page.firstCharacterIndex = 0;
                    page.lastParagraphIndex = paragraphIndex;
                    page.lastCharacterIndex = 0;
                    page.characterLengths = @[[NSNumber numberWithUnsignedInteger:1]];
                    [self.pages addObject:page];
                    break;
                }
            }
        }
        if (text) {
            [self layoutText:text caption:chapter.caption chapterIndex:chapterIndex firstParagraphIndex:firstParagraphIndex paragraphRanges:paragraphRanges layoutSize:layoutSize path:path];
            text = nil;
        }
    }
    if ([self.pages count] % 2 == 1) {
        BWPage *page = [[BWPage alloc] init];
        page.index = [self.pages count];
        page.type = BWPageTypeBlank;
        page.number = [self.pages count];
        BWPage *lastPage = [self.pages lastObject];
        page.caption = lastPage.caption;
        page.chapterIndex = lastPage.chapterIndex;
        page.firstParagraphIndex = lastPage.lastParagraphIndex + 1;
        page.firstCharacterIndex = 0;
        page.lastParagraphIndex = lastPage.lastParagraphIndex + 1;
        page.lastCharacterIndex = 0;
        page.characterLengths = @[[NSNumber numberWithUnsignedInteger:1]];
        [self.pages addObject:page];
    }
    
    CFRelease(plainFont);
    CFRelease(headFont);
    CFRelease(boldFont);
}

- (void)layoutText:(NSAttributedString *)text caption:(NSString *)caption chapterIndex:(NSUInteger)chapterIndex firstParagraphIndex:(NSUInteger)firstParagraphIndex paragraphRanges:(NSArray *)paragraphRanges layoutSize:(CGSize)layoutSize path:(UIBezierPath *)path
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)text);
    CFIndex location = 0;
    CFIndex length = [text length];
    while (length > 0) {
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(location, length), path.CGPath, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        location += range.length;
        length -= range.length;
        
        BWPage *page = [[BWPage alloc] init];
        page.index = [self.pages count];
        page.type = BWPageTypeText;
        page.number = [self.pages count];
        page.caption = caption;
        BWTextFrame *textFrame = [[BWTextFrame alloc] init];
        textFrame.ctFrame = frame;
        textFrame.layoutSize = layoutSize;
        page.textFrame = textFrame;
        page.chapterIndex = chapterIndex;
        
        NSUInteger index = [paragraphRanges indexOfObjectPassingTest:^BOOL(NSValue *value, NSUInteger idx, BOOL *stop) {
            return NSLocationInRange(range.location, [value rangeValue]);
        }];
        page.firstParagraphIndex = firstParagraphIndex + index;
        page.firstCharacterIndex = range.location - [[paragraphRanges objectAtIndex:index] rangeValue].location;
        index = [paragraphRanges indexOfObjectPassingTest:^BOOL(NSValue *value, NSUInteger idx, BOOL *stop) {
            return NSLocationInRange(range.location + range.length - 1, [value rangeValue]);
        }];
        page.lastParagraphIndex = firstParagraphIndex + index;
        page.lastCharacterIndex = range.location + range.length - 1 - [[paragraphRanges objectAtIndex:index] rangeValue].location;
        
        NSMutableArray *characterLengths = [NSMutableArray array];
        for (NSUInteger index = page.firstParagraphIndex - firstParagraphIndex; index <= page.lastParagraphIndex - firstParagraphIndex; index++) {
            NSRange range = [[paragraphRanges objectAtIndex:index] rangeValue];
            if (firstParagraphIndex + index == page.firstParagraphIndex && firstParagraphIndex + index == page.lastParagraphIndex) {
                [characterLengths addObject:[NSNumber numberWithUnsignedInteger:page.lastCharacterIndex - page.firstCharacterIndex]];
            }
            else if (firstParagraphIndex + index == page.firstParagraphIndex) {
                [characterLengths addObject:[NSNumber numberWithUnsignedInteger:range.length - page.firstCharacterIndex]];
            }
            else if (page.firstParagraphIndex < firstParagraphIndex + index && firstParagraphIndex + index < page.lastParagraphIndex) {
                [characterLengths addObject:[NSNumber numberWithUnsignedInteger:range.length]];
            }
            else if (firstParagraphIndex + index == page.lastParagraphIndex) {
                [characterLengths addObject:[NSNumber numberWithUnsignedInteger:page.lastCharacterIndex + 1]];
            }
        }
        page.characterLengths = characterLengths;
        
        [self.pages addObject:page];
        
        CFRelease(frame);
    }
    CFRelease(framesetter);
}

- (BWTextFrame *)sampleTextFrameForLayoutSize:(CGSize)layoutSize fontSize:(CGFloat)fontSize
{
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
    CTFontRef plainFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W3", fontSize, NULL);
    CTFontRef headFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W6", fontSize * 1.2, NULL);
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)@"Hiragino Mincho ProN W6", fontSize, NULL);
    NSDictionary *defaultAttributes = @{(NSString *)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyle, (NSString *)kCTFontAttributeName: (__bridge id)plainFont, (NSString *)kCTVerticalFormsAttributeName: (id)kCFBooleanTrue};
    CFRelease(paragraphStyle);
    
    NSMutableAttributedString *text = nil;
    for (BWChapter *chapter in self.chapters) {
        for (BWParagraph *paragraph in chapter.paragraphs) {
            switch (paragraph.type) {
                case BWParagraphTypeText: {
                    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] initWithString:paragraph.text attributes:defaultAttributes];
                    for (BWStyle *style in paragraph.styles) {
                        switch (style.type) {
                            case BWStyleTypeHead:
                                [line addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)headFont range:style.range];
                                break;
                            case BWStyleTypeBold:
                                [line addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:style.range];
                                break;
                        }
                    }
                    
                    if (!text) {
                        text = [[NSMutableAttributedString alloc] initWithAttributedString:line];
                    }
                    else {
                        [text appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n" attributes:defaultAttributes]];
                        [text appendAttributedString:line];
                    }
                    break;
                }
                default:
                    break;
            }
        }
        if (text) {
            break;
        }
    }
    
    CFRelease(plainFont);
    CFRelease(headFont);
    CFRelease(boldFont);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)text);
    CGRect bounds = CGRectMake(0.0, 0.0, layoutSize.height, layoutSize.width);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [text length]), path.CGPath, NULL);
    BWTextFrame *textFrame = [[BWTextFrame alloc] init];
    textFrame.ctFrame = frame;
    textFrame.layoutSize = layoutSize;
    CFRelease(frame);
    CFRelease(framesetter);
    return textFrame;
}

- (NSUInteger)pageIndexFromChapter:(BWChapter *)chapter
{
    NSUInteger chapterIndex = [self.chapters indexOfObject:chapter];
    for (BWPage *page in self.pages) {
        if (page.chapterIndex == chapterIndex) {
            return page.index;
        }
    }
    return NSNotFound;
}

- (NSUInteger)pageIndexFromLocation:(BWLocation *)location
{
   return [self.pages indexOfObjectPassingTest:^BOOL(BWPage *page, NSUInteger idx, BOOL *stop) {
       if (location.chapterIndex == page.chapterIndex) {
           if (location.paragraphIndex == page.firstParagraphIndex && location.paragraphIndex == page.lastParagraphIndex) {
               if (location.characterIndex >= page.firstCharacterIndex && location.characterIndex <= page.lastCharacterIndex) {
                   return YES;
               }
           }
           else if (location.paragraphIndex == page.firstParagraphIndex) {
               if (location.characterIndex >= page.firstCharacterIndex) {
                   return YES;
               }
           }
           else if (page.firstParagraphIndex < location.paragraphIndex && location.paragraphIndex < page.lastParagraphIndex) {
               return YES;
           }
           else if (location.paragraphIndex == page.lastParagraphIndex) {
               if (location.characterIndex <= page.lastCharacterIndex) {
                   return YES;
               }
           }
       }
       return NO;
   }];
}

- (BWLocation *)locationFromPageIndex:(NSUInteger)pageIndex
{
    BWPage *page = [self.pages objectAtIndex:pageIndex];
    BWLocation *location = [[BWLocation alloc] init];
    location.chapterIndex = page.chapterIndex;
    location.paragraphIndex = page.firstParagraphIndex;
    location.characterIndex = page.firstCharacterIndex;
    return location;
}

- (NSArray *)searchHighlightsFromPageIndex:(NSUInteger)pageIndex
{
    BWPage *page = [self.pages objectAtIndex:pageIndex];
    NSMutableArray *searchHighlights = [NSMutableArray array];
    for (BWSearchResult *searchResult in self.searchResults) {
        if (searchResult.chapterIndex == page.chapterIndex) {
            if (searchResult.paragraphIndex == page.firstParagraphIndex && searchResult.paragraphIndex == page.lastParagraphIndex) {
                NSRange range = NSIntersectionRange(NSMakeRange(searchResult.characterIndex, searchResult.characterLength), NSMakeRange(page.firstCharacterIndex, [[page.characterLengths objectAtIndex:0] unsignedIntegerValue]));
                if (range.length > 0) {
                    range.location -= page.firstCharacterIndex;
                    [searchHighlights addObject:[NSValue valueWithRange:range]];
                }
            }
            else if (searchResult.paragraphIndex == page.firstParagraphIndex) {
                NSRange range = NSIntersectionRange(NSMakeRange(searchResult.characterIndex, searchResult.characterLength), NSMakeRange(page.firstCharacterIndex, [[page.characterLengths objectAtIndex:0] unsignedIntegerValue]));
                if (range.length > 0) {
                    range.location -= page.firstCharacterIndex;
                    [searchHighlights addObject:[NSValue valueWithRange:range]];
                }
            }
            else if (page.firstParagraphIndex < searchResult.paragraphIndex && searchResult.paragraphIndex < page.lastParagraphIndex) {
                NSRange range = NSIntersectionRange(NSMakeRange(searchResult.characterIndex, searchResult.characterLength), NSMakeRange(0, [[page.characterLengths objectAtIndex:searchResult.paragraphIndex - page.firstParagraphIndex] unsignedIntegerValue]));
                if (range.length > 0) {
                    for (NSUInteger index = 0; index < searchResult.paragraphIndex - page.firstParagraphIndex; index++) {
                        range.location += [[page.characterLengths objectAtIndex:index] unsignedIntegerValue];
                    }
                    [searchHighlights addObject:[NSValue valueWithRange:range]];
                }
            }
            else if (searchResult.paragraphIndex == page.lastParagraphIndex) {
                NSRange range = NSIntersectionRange(NSMakeRange(searchResult.characterIndex, searchResult.characterLength), NSMakeRange(0, [[page.characterLengths objectAtIndex:searchResult.paragraphIndex - page.firstParagraphIndex] unsignedIntegerValue]));
                if (range.length > 0) {
                    for (NSUInteger index = 0; index < searchResult.paragraphIndex - page.firstParagraphIndex; index++) {
                        range.location += [[page.characterLengths objectAtIndex:index] unsignedIntegerValue];
                    }
                    [searchHighlights addObject:[NSValue valueWithRange:range]];
                }
            }
        }
    }
    return searchHighlights;
}

- (UIImage *)imageFromName:(NSString *)name
{
    if (_useDocumentDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:name];
        switch ([UIDevice currentDevice].userInterfaceIdiom) {
            case UIUserInterfaceIdiomPhone:
                path = [[[path stringByDeletingPathExtension] stringByAppendingString:@"~iphone"] stringByAppendingPathExtension:[path pathExtension]];
                break;
            case UIUserInterfaceIdiomPad:
                path = [[[path stringByDeletingPathExtension] stringByAppendingString:@"~ipad"] stringByAppendingPathExtension:[path pathExtension]];
                break;
        }
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            path = [documentsDirectory stringByAppendingPathComponent:name];
            image = [UIImage imageWithContentsOfFile:path];
        }
        return image;
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
        return [UIImage imageWithContentsOfFile:path];
    }
}

- (void)stopSearching
{
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef USE_TESTFLIGHT
    [TestFlight takeOff:@"9e815434c5ffc502258520a909aaa0eb_OTE3NzEyMDEyLTA1LTIwIDAyOjQ3OjIxLjk2NzY2MQ"];
    [TestFlight setDeviceIdentifier:[UIDevice currentDevice].uniqueIdentifier];
#endif
    
    [self loadConfig];
    [self layoutPages];
    self.SearchResults = [NSMutableArray array];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self stopSearching];
    [self saveConfig];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self stopSearching];
    [self saveConfig];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

- (void)loadConfig
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CGFloat fontSize = [userDefaults floatForKey:@"fontSize"];
    if (fontSize == 0.0) {
        switch ([UIDevice currentDevice].userInterfaceIdiom) {
            case UIUserInterfaceIdiomPhone:
                fontSize = BWDefaultFontSizeForPhone;
                break;
            case UIUserInterfaceIdiomPad:
                fontSize = BWDefaultFontSizeForPad;
                break;
        }
    }
    self.fontSize = fontSize;
    self.initialPageIndex = [userDefaults integerForKey:@"initialPageIndex"];
}

- (void)saveConfig
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:self.fontSize forKey:@"fontSize"];
    [userDefaults setInteger:[self.bookViewController pageIndex] forKey:@"initialPageIndex"];
}

@end
