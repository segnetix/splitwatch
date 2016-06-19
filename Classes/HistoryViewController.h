//
//  HistoryViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "SettingsViewController.h"
#import "StopwatchAppDelegate.h"

@class HistoryTableViewController;

@interface HistoryViewController : UIViewController
{
	HistoryTableViewController *historyTableViewController;
	SettingsViewController *settingsViewController;
	UISegmentedControl *sortSegmentedControl;
	StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, assign) UISegmentedControl *sortSegmentedControl;
@property (nonatomic, assign) HistoryTableViewController *historyTableViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
- (void)addEvent:(Event *)event atFront:(BOOL)front reloadData:(BOOL)reload;
- (void)eventSelected:(Event *)event;

@end
