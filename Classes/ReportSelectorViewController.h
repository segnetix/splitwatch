//
//  ReportSelectorViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <sqlite3.h>

@class StopwatchAppDelegate;

@interface ReportSelectorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate>
{
    NSString *runnerName;
    NSString *eventName;
    NSString *date;
    NSString *distance;
    BOOL bEventCountZero;
    
    UITableViewController *reportSelectorTableViewController;
    SettingsViewController *settingsViewController;
    UIButton *emailButton;
    UIButton *printButton;
    
    sqlite3 *database;
    
    StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, retain) NSString *runnerName;
@property (nonatomic, retain) NSString *eventName;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) UITableViewController *reportSelectorTableViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property (nonatomic, retain) UIButton *emailButton;
@property (nonatomic, retain) UIButton *printButton;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (void)setValue:(NSString*)value forSelector:(int)selector;
- (NSString*)getValueForSelector:(int)selector;
- (NSString*)getReportHTML;
- (void)generateEmailReport;
- (void)printReport;

@end

