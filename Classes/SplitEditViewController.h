//
//  SplitEditViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 1/10/11.
//  Copyright 2011 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitDetailViewController.h"
#import "SplitPickerViewController.h"
#import "StopwatchAppDelegate.h"
#import "Event.h"
#import <sqlite3.h>

@interface SplitEditViewController : UIViewController
{
    StopwatchAppDelegate *appDelegate;
    Event *event;
    sqlite3 *database;
    
	UISegmentedControl *lapIntervalControl;
	UISegmentedControl *unitsControl;
	UISwitch *kiloControl;
	UISwitch *furlongDisplayControl;
	
    SplitDetailViewController *splitDetailViewController;
    SplitPickerViewController *pickerViewController;
	UIImageView *pickerTopImageView;
	
    UILabel *splitUnitLabel;
    UILabel *kiloSplitLabel;
    UILabel *furlongLabel;
    UILabel *splitViewHeader;
    
    UIView *splitEditLabelView;
	
	int intervalSelectedSegmentIndex;
	bool bLoading;
	int pickerSplitIndex;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *lapIntervalControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *unitsControl;
@property (nonatomic, retain) IBOutlet UISwitch *kiloControl;
@property (nonatomic, retain) IBOutlet UISwitch *furlongDisplayControl;
@property (nonatomic, assign) UILabel *splitViewHeader;
@property (nonatomic, retain) SplitDetailViewController *splitDetailViewController;
@property (nonatomic, retain) SplitPickerViewController *pickerViewController;
@property (nonatomic, retain) UIImageView *pickerTopImageView;
@property (nonatomic, retain) IBOutlet UILabel *splitUnitLabel;
@property (nonatomic, retain) IBOutlet UILabel *kiloSplitLabel;
@property (nonatomic, retain) IBOutlet UILabel *furlongLabel;
@property (nonatomic, retain) IBOutlet UIView *splitEditLabelView;

@property (nonatomic, retain) Event *event;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (id)initWithEvent:(Event *)theEvent;

- (IBAction)clickedUnitsSelector:(id)sender;
- (IBAction)clickedIntervalSelector:(id)sender;
- (IBAction)clickedKiloControl:(id)sender;
- (IBAction)clickedFurlongDisplayControl:(id)sender;

- (void)updateEventWithChanges;
- (void)updateSplitDetailView;
- (void)scrollToTop;
- (void)pushTimePicker:(int)row;

@end
