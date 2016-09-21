//
//  SplitPickerViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 3/1/15.
//  Copyright (c) 2015 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopwatchAppDelegate.h"
#import "Event.h"

@interface SplitPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>
{
    StopwatchAppDelegate *appDelegate;
    SplitDetailViewController *splitDetailViewController;
    Event *event;
    sqlite3 *database;
    int pickerSplitIndex;
    
    UIPickerView *pickView;
    UIToolbar *pickerToolbar1;
    UIToolbar *pickerToolbar2;
    UILabel *beforeLabel;
    UILabel *editLabel;
    UILabel *afterLabel;
    UILabel *beforeTimeLabel;
    UILabel *beforeSplitLabel;
    UILabel *editTimeLabel;
    UILabel *editSplitLabel;
    UILabel *afterTimeLabel;
    UILabel *afterSplitLabel;
}

@property (retain, nonatomic) IBOutlet UIPickerView *pickView;
@property (retain, nonatomic) IBOutlet UIToolbar *pickerToolbar1;
@property (retain, nonatomic) IBOutlet UIToolbar *pickerToolbar2;
@property (nonatomic, retain) IBOutlet UILabel *editLabel;
@property (nonatomic, retain) IBOutlet UILabel *beforeLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterLabel;
@property (nonatomic, retain) IBOutlet UILabel *editTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *editSplitLabel;
@property (nonatomic, retain) IBOutlet UILabel *beforeTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *beforeSplitLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterSplitLabel;
@property (assign)   SplitDetailViewController *splitDetailViewController;

- (id)initWithEvent:(Event *)theEvent andRow:(int)row;

- (double)getTimePickerTime;
- (void)setTimePickerTime:(double)editTime;
//- (void)setSplitTimeLabels:(double)editTime beforeTime:(double)beforeTime afterTime:(double)afterTime;
- (void)setSplitTimeLabels:(double)editTime;
- (void)setSplitTimeLabelsFromEvent;
- (void)setSplitTimeLabelsFromPicker;
- (IBAction)changeSplit:(id)sender;
- (IBAction)deleteSplit:(id)sender;
- (IBAction)insertSplit:(id)sender;
- (IBAction)cancelEdit:(id)sender;
//- (void)setPickerDataArrayWith:(NSNumber*)split;

@end
