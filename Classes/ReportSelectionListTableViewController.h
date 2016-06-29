//
//  ReportSelectionListTableViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define	kAthleteSelectorMode		1
#define kEventSelectorMode          2
#define kDateSelectorMode           3
#define kDistanceSelectorMode		4

@class StopwatchAppDelegate;
@class ReportSelectorViewController;

@interface ReportSelectionListTableViewController : UITableViewController
{
    long selectorMode;
    NSString *selection;
    StopwatchAppDelegate *appDelegate;
    ReportSelectorViewController *reportSelectorVC;
    NSMutableArray *selections;
    sqlite3 *database;
}

@property long selectorMode;
@property (nonatomic, assign) NSString *selection;
@property (nonatomic, assign) NSMutableArray *selections;
@property (nonatomic, assign) ReportSelectorViewController *reportSelectorVC;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (id)initWithMode:(NSInteger)mode selection:(NSString*)listSelection ReportSelectorViewController:(ReportSelectorViewController *)rsvc;
- (void)populateSelections;

@end
