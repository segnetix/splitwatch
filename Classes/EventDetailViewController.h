//
//  EventDetailViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/7/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitDetailViewController.h"
#import "Event.h"
#import "SettingsViewController.h"
#import "SplitHeaderView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <sqlite3.h>

@interface EventDetailViewController : UIViewController <MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>
{
	Event *event;
	
	UITextField *runnerTextEdit;
	UITextField *eventNameTextEdit;
	UILabel *distance;
	UILabel *date;
	UILabel *time;
	
	UILabel *athleteLabel;
	UILabel *distanceLabel;
    SplitHeaderView *splitHeader;
	
	SplitDetailViewController *splitDetailViewController;
	SettingsViewController *settingsViewController;
	StopwatchAppDelegate *appDelegate;
	
	UIButton *pickAthleteButton;
	UIButton *pickEventButton;
	UIButton *editSplitsButton;
	
	UIToolbar *pickerToolbar;
	UIPickerView *pickView;
	NSMutableArray *pickerDataArray;
	sqlite3 *database;
	UITextField *currentEditField;
    UITapGestureRecognizer *tapGesture;
    
	BOOL bEditing;
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) IBOutlet UITextField *runnerTextEdit;
@property (nonatomic, retain) IBOutlet UITextField *eventNameTextEdit;
@property (nonatomic, retain) IBOutlet UILabel *distance;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *athleteLabel;
@property (nonatomic, retain) SplitHeaderView *splitHeader;
@property (nonatomic, retain) IBOutlet SplitDetailViewController *splitDetailViewController;
@property (nonatomic, assign) SettingsViewController *settingsViewController;
@property (nonatomic, retain) IBOutlet UIPickerView *pickView;
@property (nonatomic, retain) IBOutlet UIToolbar *pickerToolbar;
@property (nonatomic, retain) IBOutlet UIButton *pickAthleteButton;
@property (nonatomic, retain) IBOutlet UIButton *pickEventButton;
@property (nonatomic, retain) IBOutlet UIButton *editSplitsButton;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (retain, nonatomic) UITapGestureRecognizer *tapGesture;

- (id)initWithEvent:(Event *)theEvent settingsVC:(SettingsViewController *)theSettingsVC;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)setName:(id)sender;
- (IBAction)editSplitsButtonHit:(id)sender;
- (void)setPickerDataArrayWith:(int)dataType;
- (IBAction)pickerSet;
- (IBAction)pickerCancel;
- (void)setEventFields;

@end
