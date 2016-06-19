//
//  SettingsViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "HelpViewController.h"
#import "EmailAddressViewController.h"
#import "Utilities.h"

@class StopwatchAppDelegate;

@interface SettingsViewController : UIViewController
{
	UIImageView *backgroundImageView;
	UISegmentedControl *lapIntervalControl;
	UISegmentedControl *unitsControl;
	UISwitch *kiloControl;
	UISwitch *furlongDisplayControl;
	UISwitch *soundControl;
	UISwitch *lapDelayControl;
	UISwitch *touchUpStartControl;
	UISwitch *touchUpLapControl;
	UIButton *aboutButton;
	UIButton *helpButton;
	UIButton *emailSetButton;
	
	AboutViewController *aboutViewController;
	HelpViewController *helpViewController;
	EmailAddressViewController *emailAddressViewController;
	StopwatchAppDelegate *appDelegate;
	NSString *rootDataFilePath;
	BOOL bLoaded;
	
	NSInteger unitsState;
	NSInteger intervalState;
	NSInteger kiloSplitsState;
	NSInteger furlongDisplayState;
	NSInteger soundState;
	NSInteger lapDelayState;
	NSInteger touchUpStartState;
	NSInteger touchUpLapState;
	NSMutableArray *emailAddressItems;
	
	int intervalSelectedSegmentIndex;
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *lapIntervalControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *unitsControl;
@property (nonatomic, retain) IBOutlet UISwitch *kiloControl;
@property (nonatomic, retain) IBOutlet UISwitch *furlongDisplayControl;
@property (nonatomic, retain) IBOutlet UISwitch *soundControl;
@property (nonatomic, retain) IBOutlet UISwitch *lapDelayControl;
@property (nonatomic, retain) IBOutlet UISwitch *touchUpStartControl;
@property (nonatomic, retain) IBOutlet UISwitch *touchUpLapControl;
@property (nonatomic, retain) IBOutlet UIButton *aboutButton;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, retain) IBOutlet UIButton *emailSetButton;
@property (nonatomic, retain) AboutViewController *aboutViewController;
@property (nonatomic, retain) HelpViewController *helpViewController;
@property (nonatomic, retain) IBOutlet EmailAddressViewController *emailAddressViewController;
@property (nonatomic, retain) NSString *rootDataFilePath;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property BOOL bLoaded;

@property NSInteger unitsState;
@property NSInteger intervalState;
@property NSInteger kiloSplitsState;
@property NSInteger furlongDisplayState;
@property NSInteger soundState;
@property NSInteger lapDelayState;
@property NSInteger touchUpStartState;
@property NSInteger touchUpLapState;
@property (nonatomic, retain) NSMutableArray *emailAddressItems;

- (NSInteger)getLapInterval;
- (BOOL)isSetForMetricUnits;
- (BOOL)isSetForEnglishUnits;				// v1.2
- (BOOL)isSetForLapUnits;					// v1.2
- (int)intervalUnits;						// v1.2
- (BOOL)isSetForKiloSplits;
- (BOOL)isSetForFurlongDisplay;				// v1.2
- (BOOL)isSetForSound;
- (BOOL)isSetForLapDelay;
- (BOOL)isSetForTouchUpStart;
- (BOOL)isSetForTouchUpLap;
- (NSArray *)getDefaultEmailAddresses;

- (void)saveStateToFile:(NSString *)rootFilePath;
- (void)loadStateFromFile:(NSString *)rootFilePath;

- (IBAction)clickedUnitsSelector:(id)sender;
- (IBAction)clickedIntervalSelector:(id)sender;
- (IBAction)clickedKiloControl:(id)sender;
- (IBAction)clickedFurlongDisplayControl:(id)sender;
- (IBAction)clickedSoundControl:(id)sender;
- (IBAction)clickedLapDelayControl:(id)sender;
- (IBAction)clickedTouchUpStartControl:(id)sender;
- (IBAction)clickedTouchUpLapControl:(id)sender;
- (IBAction)clickedAboutButton:(id)sender;
- (IBAction)clickedHelpButton:(id)sender;
- (IBAction)clickedEmailSetButton:(id)sender;

@end
