//
//  MultiStopwatchRootViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/20/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "MultiStopwatchViewController.h"

@class MultiStopwatchFlipsideViewController;
@class StopwatchAppDelegate;

@interface MultiStopwatchRootViewController : UIViewController
{
    SettingsViewController *settingsViewController;
    StopwatchAppDelegate *appDelegate;
    
    IBOutlet UIButton *setupButton;
    MultiStopwatchViewController *mainViewController;
    MultiStopwatchFlipsideViewController *flipsideViewController;
    UINavigationBar *flipsideNavigationBar;
    
    NSString *stateDataFilePath;
}

@property (nonatomic, assign) SettingsViewController *settingsViewController;

@property (nonatomic, retain) UIButton *setupButton;
@property (nonatomic, retain) MultiStopwatchViewController *mainViewController;
@property (nonatomic, retain) MultiStopwatchFlipsideViewController *flipsideViewController;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, retain) NSString *stateDataFilePath;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
- (IBAction)toggleView;

- (void)addAllEventsToDatabase;
- (void)saveStateToFile:(NSString *)rootFilePath;
- (void)loadStateFromFile:(NSString *)rootFilePath;

@end
