//
//  BWSettingViewController.h
//  bookworm
//
//  Copyright 2012 Kenji Nishishiro. All rights reserved.
//  Written by Kenji Nishishiro <marvel@programmershigh.org>.
//

@class BWTextFrameView;

@interface BWSettingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet BWTextFrameView *textView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

- (IBAction)changeFontSize:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
