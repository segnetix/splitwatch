//
//  EventDetailViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/7/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "EventDetailViewController.h"
#import "SplitEditViewController.h"
#import "StopwatchAppDelegate.h"
#import "Utilities.h"

#define kAthletes					  1
#define kEvents						  2

@implementation EventDetailViewController

@synthesize event;
@synthesize runnerTextEdit;
@synthesize eventNameTextEdit;
@synthesize distance;
@synthesize date;
@synthesize time;
@synthesize distanceLabel;
@synthesize splitDetailViewController;
@synthesize settingsViewController;
@synthesize pickerToolbar;
@synthesize pickView;
@synthesize pickAthleteButton;
@synthesize pickEventButton;
@synthesize editSplitsButton;
@synthesize athleteLabel;		// v1.2 - to be able to modify the "Athlete:" label for Furlong Mode ("Horse:")
@synthesize splitHeader;
@synthesize appDelegate;
@synthesize tapGesture;

- (id)initWithEvent:(Event *)theEvent settingsVC:(SettingsViewController *)theSettingsVC
{	
	if (self = [super initWithNibName:@"EventDetail" bundle:nil])
	{
		event = theEvent;
		[event retain];
		
		settingsViewController = theSettingsVC;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
        
		if (theEvent.bFurlongMode)
			athleteLabel.text = @"Horse:";
		else
			athleteLabel.text = @"Athlete:";

		// splitHeader
        splitHeader = [[SplitHeaderView alloc] init];
        splitHeader.translatesAutoresizingMaskIntoConstraints = NO;
        splitHeader.tag = @"splitHeader";
        
        splitDetailViewController = [[SplitDetailViewController alloc]
         initWithIntervalDistance:event.lapDistance
         Units:event.iEventType
         KiloSplits:event.bKiloSplits
         FurlongMode:event.bFurlongMode
         Finished:YES
         EditMode:NO];
         splitDetailViewController.splits = (NSMutableArray *)[event getSplitData];
        splitDetailViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        // setup pickView
        pickView = [[UIPickerView alloc] init];
        pickView.delegate = self;
        pickView.showsSelectionIndicator = YES;
        pickView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        pickView.translatesAutoresizingMaskIntoConstraints = NO;
        pickView.tag = @"pickView";
        
        // setup pickerToolbar
        pickerToolbar = [[UIToolbar alloc] init];
        pickerToolbar.backgroundColor = [UIColor groupTableViewBackgroundColor];
        pickerToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        pickerToolbar.tag = @"pickerToolbar";
        
		bEditing = NO;
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = @"Split Detail";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView* splitDetailView = splitDetailViewController.view;
    splitDetailView.tag = @"splitDetailView";
    
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    separatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(pickView, pickerToolbar, splitDetailView, splitHeader, separatorImageView);
    
    // separator line above split view header
    [self.view addSubview:separatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorImageView]|" options:0 metrics:nil views:views]];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-215-[separatorImageView(1)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-195-[separatorImageView(1)]" options:0 metrics:nil views:views]];
    }
    [separatorImageView release];

    
    // splitHeader and splitDetailViewController
    [self.view addSubview:splitHeader];
    [self.view addSubview:splitDetailView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitHeader]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitDetailView]|" options:0 metrics:nil views:views]];
    
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-216-[splitHeader(30)][splitDetailView]-49-|" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-196-[splitHeader(20)][splitDetailView]-49-|" options:0 metrics:nil views:views]];
    }
    
    // pickView and pickerToolbar setup
    [self.view addSubview:pickView];
    [self.view addSubview:pickerToolbar];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerToolbar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickView(162)][pickerToolbar]-49-|" options:0 metrics:nil views:views]];
    [pickView release];
    [pickerToolbar release];
    
    // set the update compose button
    UIBarButtonItem *emailButtonItem = [[[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                        target:self
                                        action:@selector(composeEmail:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = emailButtonItem;
    
    pickerDataArray = [[NSMutableArray alloc] init];
    
    pickView.userInteractionEnabled = YES;
    tapGesture =[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerDoubleTap)] autorelease];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delegate = self;
    [pickView addGestureRecognizer:tapGesture];
    
    UIBarButtonItem *pickerCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(pickerCancel)];
    
    UIBarButtonItem *pickerSetButton = [[UIBarButtonItem alloc] initWithTitle:@"Set"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(pickerSet)];
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    NSArray *items = [[[NSArray alloc] initWithObjects: flexibleSpace, pickerCancelButton, flexibleSpace, pickerSetButton, flexibleSpace, nil] autorelease];
    
    [pickerToolbar setItems:items animated:YES];

    // set other button target and actions
    [pickAthleteButton addTarget:self action:@selector(setName:) forControlEvents:UIControlEventTouchUpInside];
    [pickEventButton   addTarget:self action:@selector(setName:) forControlEvents:UIControlEventTouchUpInside];
    
    // now initialize the split view header
    [splitHeader setup];
    
	[self setEventFields];
}

- (void)setEventFields
{
	distance.text = [Utilities stringFromDistance:event.distance
											Units:event.iEventType
										ShowMiles:YES
									 ShowSplitTag:NO
										 Interval:(int)event.lapDistance
							   FurlongDisplayMode:event.bFurlongMode];
	date.text = [Utilities formatDate:event.date];
	time.text = [Utilities shortFormatTime:event.finalTime precision:2];
	
	// v1.2
	if (event.bFurlongMode)
		athleteLabel.text = @"Horse:";
	else
		athleteLabel.text = @"Athlete:";
	
	if (event.iEventType == kLap)
		distanceLabel.text = @"Splits:";
	else
		distanceLabel.text = @"Distance:";
		
	NSMutableArray *headerArray = [Utilities getSplitViewHeaderArray:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongDisplayMode:event.bFurlongMode];
    [splitHeader setTextWithArray:headerArray];
	
	[splitDetailViewController resetLapInterval:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongMode:event.bFurlongMode];
	[splitDetailViewController refreshSplitView:NO];
}

- (void)dealloc
{
	//[splitHeader release];
	//splitHeader = nil;
	
	[splitDetailViewController release];
	[runnerTextEdit release];
	[eventNameTextEdit release];
	[distance release];
	[date release];
	[time release];
	[distanceLabel release];
	[athleteLabel release];
    [splitHeader release];
	[pickAthleteButton release];
	[pickEventButton release];
	[editSplitsButton release];
	[pickerDataArray release];
	[event release];
	
	splitDetailViewController = nil;
	runnerTextEdit = nil;
	eventNameTextEdit = nil;
	distance = nil;
	date = nil;
	time = nil;
	distanceLabel = nil;
	athleteLabel = nil;
    splitHeader = nil;
	pickAthleteButton = nil;
	pickEventButton = nil;
    editSplitsButton = nil;
	pickerToolbar = nil;
	pickView = nil;
	pickerDataArray = nil;
	event = nil;
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    // set event tag fields
    runnerTextEdit.text = event.runnerName;
    eventNameTextEdit.text = event.eventName;
    
    [self.view bringSubviewToFront:pickView];
    [self.view bringSubviewToFront:pickerToolbar];
    
    pickView.hidden = YES;
    pickerToolbar.hidden = YES;
    
    [self setEventFields];
    
    //[self requestLayout];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	// enable manual split view scrolling if we have more splits than can be held at one time
	if (splitDetailViewController.splits.count > kEventDetailMaxRows - kSummaryLineCount)
	{
		splitDetailViewController.tableView.scrollEnabled = YES;
		[splitDetailViewController.tableView flashScrollIndicators];
	}
	else
		splitDetailViewController.tableView.scrollEnabled = NO;
    
	[super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Text Field Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{	
	//if (setAthleteButton.enabled == NO)
	//	return NO;
	bEditing = YES;
	
	pickAthleteButton.enabled = NO;
	pickEventButton.enabled = NO;
	editSplitsButton.enabled = NO;
    
	//[appDelegate playClickSound];
	
	return YES;
}

- (IBAction)textFieldDoneEditing:(id)sender
{
	//[appDelegate playClickSound];
	
	bEditing = NO;
	
	// trim any long strings
	if (runnerTextEdit.text.length > 50)
		event.runnerName = [runnerTextEdit.text substringToIndex:50];
	else
		event.runnerName = runnerTextEdit.text;

	if (eventNameTextEdit.text.length > 50)
		event.eventName = [eventNameTextEdit.text substringToIndex:50];
	else
		event.eventName = eventNameTextEdit.text;
	
	pickAthleteButton.enabled = YES;
	pickEventButton.enabled = YES;
	editSplitsButton.enabled = YES;
    
	[event updateSelfInDatabase];
	
	[sender resignFirstResponder];
}

- (IBAction)editSplitsButtonHit:(id)sender
{	
	//[appDelegate playClickSound];
	
	SplitEditViewController *splitEditViewController = [[SplitEditViewController alloc] initWithEvent:event];
	
	[self.navigationController pushViewController:splitEditViewController animated:YES];
	[splitEditViewController release];
}

#pragma mark -
#pragma mark Athlete/Event Picker Methods

- (IBAction)setName:(id)sender
{	
	//[appDelegate playClickSound];
	
	bEditing = YES;
	pickView.hidden = NO;
	pickerToolbar.hidden = NO;
	
	//[pickView selectRow:0 inComponent:0 animated:NO];
	
	if (sender == pickAthleteButton)
		currentEditField = runnerTextEdit;
	else if (sender == pickEventButton)
		currentEditField = eventNameTextEdit;
	
	if (sender == pickEventButton)
		[self setPickerDataArrayWith:kEvents];
	else
		[self setPickerDataArrayWith:kAthletes];
	
	pickAthleteButton.enabled = NO;
	pickEventButton.enabled = NO;
	editSplitsButton.enabled = NO;
}

- (IBAction)pickerSet
{
    [self pickerDoubleTap];
}

- (IBAction)pickerCancel
{
	//[appDelegate playClickSound];
	
	pickView.hidden = YES;
	pickerToolbar.hidden = YES;
	
	pickAthleteButton.enabled = YES;
	pickEventButton.enabled = YES;
	editSplitsButton.enabled = YES;
	
	bEditing = NO;
}

- (void)pickerDoubleTap
{
    // get picker selection
    NSInteger row = [pickView selectedRowInComponent: 0];
    
    // set picker text in current edit field with current picker selection
    if (row < pickerDataArray.count)
        currentEditField.text = (NSString *)[pickerDataArray objectAtIndex:row];
    
    // dismiss the picker and make sure picker buttons are enabled
    pickAthleteButton.enabled = YES;
    pickEventButton.enabled = YES;
    editSplitsButton.enabled = YES;
    pickView.hidden = YES;
    pickerToolbar.hidden = YES;
    
    [self textFieldDoneEditing:nil];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == tapGesture)
        return YES;
    
    return NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [pickerDataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [pickerDataArray objectAtIndex:row];
}

- (void)setPickerDataArrayWith:(int)dataType
{
	[pickerDataArray removeAllObjects];
	
	char sql[250];
	sqlite3_stmt *statement;
	
	switch (dataType)
	{
		case kAthletes:	// RunnerName - populate with groups
			strcpy(sql, "SELECT DISTINCT RunnerName FROM Event ORDER BY RunnerName");
			break;
		case kEvents:	// EventName - populate with groups
			strcpy(sql, "SELECT DISTINCT EventName FROM Event ORDER BY EventName");
			break;
		default:
			NSLog(@"ERROR: Filter selection out of range.");
			return;
			break;
	}
	
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		//NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
	}
	
	// step through the result set rows (one per event)
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		NSString *rowText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		
		[pickerDataArray addObject:rowText];
	}
	
	sqlite3_finalize(statement);
	
	[pickView reloadAllComponents];
}

#pragma mark -
#pragma mark E-Mail Methods

- (void)composeEmail:(id)sender
{
	if (bEditing)
		return;
	
	//[appDelegate playClickSound];
	
	if ([MFMailComposeViewController canSendMail])
	{
        // init mail view controller
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.barStyle = UIBarStyleDefault;
        
		// subject and title string
		NSString *subjectStr;
		
		// v1.2 - subject string doesn't have distance for lap mode events
		if (event.iEventType != kLap)
		{
			subjectStr = [NSString stringWithFormat:@"%@  %@  %@",
									event.runnerName,
						  [Utilities stringFromDistance:(int)event.distance Units:event.iEventType ShowMiles:YES ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode],
									[Utilities shortFormatTime:event.finalTime precision:2]];
		}
		else
		{
			subjectStr = [NSString stringWithFormat:@"%@  %@",
						  event.runnerName,
						  [Utilities shortFormatTime:event.finalTime precision:2]];
		}
		
		[mailViewController setSubject:subjectStr];
        
		/*
		// Set up recipients
		NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
		NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
		NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
		
		[mailViewController setToRecipients:toRecipients];
		[mailViewController setCcRecipients:ccRecipients];
		[mailViewController setBccRecipients:bccRecipients];
		*/
				
		[mailViewController setToRecipients:[settingsViewController getDefaultEmailAddresses]];
		
		// Attach an image to the email
		//NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
		//NSData *myData = [NSData dataWithContentsOfFile:path];
		//[mailViewController addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
		
		/*
		// TEXT version
		// Fill out the email body text
		NSString *emailBody = [NSString stringWithFormat:@"\nSplitwatch Report\n\nRunner: %@\nEvent Location: %@\nDate: %@\n Event: %@ Time: %@\n\n%@\n%@",
							   event.runnerName,
							   event.location,
							   [TimerUtilities formatDate:event.date],
							   [TimerUtilities formatDistance:event.distance],
							   [TimerUtilities shortFormatTime:event.finalTime precision:2],
							   [TimerUtilities getSplitViewHeaderText:event.lapDistance],
							   [splitDetailViewController getSplitDataString:NO]];
		*/
		
		// HTML version
		NSString *emailBody = @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' ";
		emailBody = [emailBody stringByAppendingString:@"'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "];
		emailBody = [emailBody stringByAppendingString:@"<html xmlns='http://www.w3.org/1999/xhtml'>"];
		emailBody = [emailBody stringByAppendingString:@"<head><title>Test</title><link rel='stylesheet' type='text/css' href='./style.css' /> </head>"];
		emailBody = [emailBody stringByAppendingString:@"<body><div id='container' style='font-family:arial; font-size:14px;'>"];
		emailBody = [emailBody stringByAppendingString:@"<div id='title' style='margin-bottom:15px; font-weight:bold;'>"];
		emailBody = [emailBody stringByAppendingString:@"Split Report by <a href='http://www.segnetix.com'>SPLITWATCH</a></div>"];
		emailBody = [emailBody stringByAppendingString:@"<div style='margin-bottom:30px;'>"];
		emailBody = [emailBody stringByAppendingString:@"<table id='split data' cellpadding-right='3'>"];
		
		if (event.bFurlongMode)
			emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Horse:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];
		else
			emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Athlete:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];

		emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Event Name:</td><td>&nbsp;</td><td>%@</td></tr>", event.eventName];
		emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Date:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities formatDate:event.date]];
		
		if (event.iEventType != kLap)
			emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Distance:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities stringFromDistance:event.distance Units:event.iEventType ShowMiles:YES ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode]];
				
		emailBody = [emailBody stringByAppendingFormat:@"<tr><td>Time:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities shortFormatTime:event.finalTime precision:2]];
		emailBody = [emailBody stringByAppendingString:@"<tr style='height:10px;'/></table>"];
		emailBody = [emailBody stringByAppendingString:[splitDetailViewController getSplitHTMLDataString]];
		emailBody = [emailBody stringByAppendingString:@"</div></div></body></html>"];

		[mailViewController setMessageBody:emailBody isHTML:YES];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
		// undocumented feature --- DO NOT USE!!!
		//[[[[mailViewController viewControllers] lastObject] navigationItem] setTitle:@"Send E-mail"];
		
		//[mailViewController release];
    }
	else
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't Send Email!"
															message:@"This device is not configured for sending email."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];	
	}
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	//[appDelegate playClickSound];

	NSString *message;
	
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = @"Email Canceled";
            break;
        case MFMailComposeResultSaved:
            message = @"Email Saved";
            break;
        case MFMailComposeResultSent:
            message = @"Email Sent";
            break;
        case MFMailComposeResultFailed:
            message = @"Email Failed";
            break;
        default:
            message = @"Email Not Sent";
            break;
    }
	
	if (result != MFMailComposeResultCancelled)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
															message:nil
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

