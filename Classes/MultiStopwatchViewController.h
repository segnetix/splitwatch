//
//  MultiStopwatchViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiStopwatchTableViewController.h"
#import "Stopwatch.h"

@class MultiStopwatchSetupViewController;
@class SettingsViewController;
@class StopwatchAppDelegate;

@interface MultiStopwatchViewController : UIViewController <UIAlertViewDelegate, UINavigationBarDelegate>
{
    UILabel *runningTimeLabel;
    UILabel *intervalDistanceLabel;
    UIButton *startStopButton;
    UIButton *clearResetButton;
    UIButton *setupButton;
    UIImageView *topSeparatorImageView;
    UIImageView *bottomSeparatorImageView;
    
    MultiStopwatchSetupViewController *setupViewController;
    MultiStopwatchTableViewController *multiStopwatchTableViewController;
    SettingsViewController *settingsViewController;
    StopwatchAppDelegate *appDelegate;
    
    BOOL bTimerRunning;
    int  iUnits;
    BOOL bKiloSplits;
    BOOL bFurlongMode;
    
    NSTimer *timer;
    NSTimeInterval startTime;
    NSTimeInterval stopTime;
    NSTimeInterval elapsedTime;
    NSInteger intervalDistance;
    
    // v2.0
    UIColor* GREEN_COLOR;
    UIColor* RED_COLOR;
}

@property (nonatomic, retain) UILabel	*runningTimeLabel;
@property (nonatomic, retain) UILabel	*intervalDistanceLabel;
@property (nonatomic, retain) UIButton	*startStopButton;
@property (nonatomic, retain) UIButton	*clearResetButton;
@property (nonatomic, retain) UIButton  *setupButton;
@property (nonatomic, retain) UIImageView *topSeparatorImageView;
@property (nonatomic, retain) UIImageView *bottomSeparatorImageView;
@property (nonatomic, assign) IBOutlet MultiStopwatchSetupViewController *setupViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (nonatomic, retain) MultiStopwatchTableViewController *multiStopwatchTableViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property BOOL bTimerRunning;
@property int  iUnits;
@property BOOL bKiloSplits;
@property BOOL bFurlongMode;

@property (nonatomic, retain) NSTimer *timer;
@property NSTimeInterval startTime;
@property NSTimeInterval stopTime;
@property NSTimeInterval elapsedTime;
@property NSInteger intervalDistance;
@property (nonatomic, retain) UIColor *GREEN_COLOR;
@property (nonatomic, retain) UIColor *RED_COLOR;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;

- (void)resetIntervalUnitsFromCurrentSettings;
- (void)resetIntervalUnitsFromStateData;
- (void)resetIntervalUnitsIfWatchIsReset;
- (NSArray *)getNames;
- (NSString *)getEventName;
- (void)updateTimeDisplays;

- (void)updateFromSetupWithNames:(NSMutableArray *)nameArray andEvent:(NSString *)event;
- (void)startMainWatch;
- (void)stopMainWatch;

- (void)saveStateToFile:(NSString *)rootFilePath;
- (void)loadStateFromFile:(NSString *)rootFilePath;

- (void)resetMultiwatch;
- (void)addAllEventsToDatabase;

- (void)resetMainClock;
- (void)setWatchButtonBehavior;


@end
