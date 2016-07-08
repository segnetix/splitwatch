//
//  MultiwatchCell.h
//  Stopwatch
//
//  Created by Steven Gentry on 7/7/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stopwatch.h"

@class StopwatchAppDelegate;

@interface MultiwatchCell : UITableViewCell
{
    UIView *backgroundView;
    UIButton *startStopButton;
    UIButton *lapResetButton;
    UILabel *runnersNameLabel;
    UILabel *completedDistanceLabel;
    UILabel *completedDistanceTime;
    UILabel *lapTimeLabel;
    UILabel *runningTimeLabel;
    
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
@property (nonatomic, retain) IBOutlet UILabel *completedDistanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *completedDistanceTime;
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
