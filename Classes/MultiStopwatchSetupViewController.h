//
//  MultiStopwatchSetupViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/19/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "StopwatchAppDelegate.h"

@class MultiStopwatchViewController;

@interface MultiStopwatchSetupViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	MultiStopwatchViewController *mainViewController;
	
	UITextField *athleteField;
	UITextField *eventField;
	
	UILabel *athleteLabel;
	UILabel *eventLabel;
	
	UIButton *pickAthleteButton;
	UIButton *pickEventButton;
	UIButton *clearAllButton;
    
    UITableView *nameTable;
    
	UIToolbar *pickerToolbar;
	UIPickerView *pickView;
    UIImageView *pickerSeparatorImageView;
	NSMutableArray *pickerDataArray;
    NSMutableArray *nameArray;
	sqlite3 *database;
	UITextField *currentEditField;
    UITapGestureRecognizer *tapGesture;
    
	BOOL bCurrentlyEditing;
    int keyboardHeight;
	
	StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, assign) MultiStopwatchViewController *mainViewController;
@property (nonatomic, assign) UIPickerView *pickView;
@property (nonatomic, assign) UIToolbar *pickerToolbar;
@property (nonatomic, retain) UIImageView *pickerSeparatorImageView;
@property (nonatomic, retain) IBOutlet UITextField *athleteField;
@property (nonatomic, retain) IBOutlet UITextField *eventField;
@property (nonatomic, retain) IBOutlet UILabel *athleteLabel;
@property (nonatomic, retain) IBOutlet UILabel *eventLabel;
@property (nonatomic, retain) IBOutlet UITableView *nameTable;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (retain, nonatomic) IBOutlet UIButton *clearAllButton;
@property (retain, nonatomic) IBOutlet UIButton *pickEventButton;
@property (retain, nonatomic) IBOutlet UIButton *pickAthleteButton;
@property (retain, nonatomic) NSMutableArray *nameArray;
@property (retain, nonatomic) UITapGestureRecognizer *tapGesture;
@property int keyboardHeight;
@property BOOL bCurrentlyEditing;

- (id)initWithMainViewController:(MultiStopwatchViewController *)mainVC;
- (IBAction)textFieldBeginEditing:(UITextField *)textField;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)openPicker:(id)sender;
- (void)doneWithSetup;
- (void)setPickerDataArrayWith:(int)dataType;
- (void)pickerDoubleTap;
- (IBAction)pickerAdd;
- (IBAction)pickerCancel;
- (IBAction)clearAll:(id)sender;

@end