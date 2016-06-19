//
//  HistoryTableViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 2/13/10.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "HistoryViewController.h"
#import "SettingsViewController.h"
#import <sqlite3.h>

@class StopwatchAppDelegate;

@interface HistoryTableViewController : UITableViewController
{
	HistoryViewController *historyViewController;
	SettingsViewController *settingsViewController;
	StopwatchAppDelegate *appDelegate;
	
	sqlite3 *database;
	NSMutableArray *tableItems;
	
	BOOL bDisplayEvents;
	NSInteger filterSelection;
}

@property (nonatomic, retain) NSMutableArray *tableItems;
@property (nonatomic, assign) HistoryViewController *historyViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property BOOL bDisplayEvents;
@property NSInteger filterSelection;

- (id)initWithHistoryViewController:(HistoryViewController *)theHistoryVC SettingsViewController:(SettingsViewController *)theSettingsVC;
- (void)addEvent:(Event *)event atFront:(BOOL)front reloadData:(BOOL)reload;
- (void)scrollToTop;
- (void)groupEventsBySelection:(NSInteger)selection;

@end
