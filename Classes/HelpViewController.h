//
//  HelpViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/14/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopwatchAppDelegate;

@interface HelpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	//UIImageView *helpImageView;
	
	UITableViewController *helpTableViewController;
	StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, retain) UITableViewController *helpTableViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

@end
