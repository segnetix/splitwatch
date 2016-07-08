//
//  StopwatchViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitDetailViewController.h"
#import "SettingsViewController.h"
#import "SplitHeaderView.h"

@class StopwatchAppDelegate;

@interface StopwatchViewController : UIViewController
{
	UIView *backgroundView;
	//UIImage *startButtonImage;
	//UIImage *stopButtonImage;
	//UIImage *lapButtonImage;
	//UIImage *resetButtonImage;
	UILabel *runningTimeLabel;
	UILabel *lapTimeLabel;
	UILabel	*lapCountLabel;
	UILabel *intervalDistanceLabel;
	SplitHeaderView *splitHeader;
	UIButton *startStopButton;
	UIButton *lapResetButton;
	UIButton *clearToggleButton;
    UIImageView *topSeparatorImageView;
    UIImageView *middleSeparatorImageView;
    UIImageView *bottomSeparatorImageView;
	SplitDetailViewController *splitDetailViewController;
	SettingsViewController *settingsViewController;
	StopwatchAppDelegate *appDelegate;
	BOOL bTimerRunning;
	int iUnits;
	BOOL bKiloSplits;
	BOOL bFurlongMode;
	
	NSTimer *timer;
	NSTimeInterval startTime;
	NSTimeInterval stopTime;
	NSTimeInterval elapsedTime;
	NSTimeInterval lapTime;
	NSTimeInterval previousLapTime;
	NSInteger lapCount;
	NSInteger intervalDistance;
	
	NSTimer *lapFreezeTimer;
	BOOL bLapFreeze;
	BOOL bFlipTimeDisplay;
    
    // v2.0
    UIColor* GREEN_COLOR;
    UIColor* RED_COLOR;
}

//@property (nonatomic, retain) UIImage *stopButtonImage;
//@property (nonatomic, retain) UIImage *startButtonImage;
//@property (nonatomic, retain) UIImage *lapButtonImage;
//@property (nonatomic, retain) UIImage *resetButtonImage;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, assign) UILabel	*runningTimeLabel;
@property (nonatomic, assign) UILabel	*lapTimeLabel;
@property (nonatomic, assign) UILabel	*lapCountLabel;
@property (nonatomic, assign) UILabel	*intervalDistanceLabel;
@property (nonatomic, assign) SplitHeaderView	*splitHeader;
@property (nonatomic, assign) UIButton	*startStopButton;
@property (nonatomic, assign) UIButton	*lapResetButton;
@property (nonatomic, retain) UIButton	*clearToggleButton;
@property (nonatomic, retain) UIImageView *topSeparatorImageView;
@property (nonatomic, retain) UIImageView *middleSeparatorImageView;
@property (nonatomic, retain) UIImageView *bottomSeparatorImageView;
@property (nonatomic, assign) SplitDetailViewController *splitDetailViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (nonatomic, assign) NSTimer	*timer;
@property (nonatomic, retain) NSTimer *lapFreezeTimer;
@property (nonatomic, retain) UIColor *GREEN_COLOR;
@property (nonatomic, retain) UIColor *RED_COLOR;

@property NSTimeInterval startTime;
@property NSTimeInterval stopTime;
@property NSTimeInterval lapTime;
@property NSTimeInterval elapsedTime;
@property NSTimeInterval previousLapTime;
@property NSInteger lapCount;
@property NSInteger intervalDistance;
@property BOOL bTimerRunning;
@property int iUnits;
@property BOOL bKiloSplits;
@property BOOL bFurlongMode;
@property BOOL bLapFreeze;
@property BOOL bFlipTimeDisplay;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
- (void)resetIntervalUnitsFromCurrentSettings;
- (void)resetIntervalUnitsFromStateData;
- (void)updateTimeDisplays;
- (void)updateButtonState;
- (void)startTimerWithStartTime:(NSTimeInterval)time;
- (void)stopTimer;
- (NSArray *)getSplits;
- (void)setSplitData:(NSArray *)splitData;
- (void)saveStateToFile:(NSString *)rootFilePath;
- (void)loadStateFromFile:(NSString *)rootFilePath;
- (void)flashBackground;
- (void)unflashBackground;
- (void)disableLapButton;
- (void)enableLapButton;
- (void)freezeLapDisplay;
- (void)unfreezeLapDisplay;
- (void)addSplit;
- (void)addSplitWithDelay;

@end
