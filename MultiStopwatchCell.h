//
//  MultiStopwatchCell.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/15/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stopwatch.h"

@class StopwatchAppDelegate;

@interface MultiStopwatchCell : UITableViewCell
{
	UIView *backgroundView;
	UIButton *startStopButton;
	UIButton *lapResetButton;
	UILabel *runnersNameLabel;
	UILabel *runningTimeLabel;
	UILabel *lapTimeLabel;
	UILabel *lapCountLabel;
	
	Stopwatch *watch;
	NSTimeInterval lastLapButtonPressTime;
	StopwatchAppDelegate *appDelegate;
	
	NSTimer *lapFreezeTimer;
	BOOL bLapFreeze;
    
    // v2.0
    UIColor* GREEN_COLOR;
    UIColor* RED_COLOR;
}

@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UIButton *startStopButton;
@property (nonatomic, retain) IBOutlet UIButton *lapResetButton;
@property (nonatomic, retain) IBOutlet UILabel *runnersNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *runningTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *lapTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *lapCountLabel;
@property (nonatomic, retain) Stopwatch *watch;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property NSTimeInterval lastLapButtonPressTime;
@property (nonatomic, retain) NSTimer *lapFreezeTimer;
@property BOOL bLapFreeze;
@property (nonatomic, retain) UIColor *GREEN_COLOR;
@property (nonatomic, retain) UIColor *RED_COLOR;

- (void)initialize;
- (IBAction)startStopButtonPressed:(id)sender;
- (IBAction)lapResetButtonPressed:(id)sender;
- (void)updateTimeDisplays;
- (void)updateButtonState;
- (void)additionalSetup;
- (void)disableLapButton;
- (void)enableLapButton;
- (void)setWatchButtonBehavior;
- (void)flashBackground;
- (void)unflashBackground;
- (void)freezeLapDisplay;
- (void)unfreezeLapDisplay;

@end
