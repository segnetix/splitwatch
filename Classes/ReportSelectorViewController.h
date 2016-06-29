//
//  ReportSelectorViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopwatchAppDelegate;

@interface ReportSelectorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSString *athlete;
    NSString *event;
    NSString *date;
    NSString *distance;
    
    UITableViewController *reportSelectorTableViewController;
    UIButton *generateButton;
    
    StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, retain) NSString *athlete;
@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) UITableViewController *reportSelectorTableViewController;
@property (nonatomic, retain) UIButton *generateButton;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (void)setValue:(NSString*)value forSelector:(int)selector;
- (NSString*)getValueForSelector:(int)selector;
- (void)generate;

@end

