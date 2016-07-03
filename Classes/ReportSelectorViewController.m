//
//  ReportSelectorViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "ReportSelectorViewController.h"
#import "ReportSelectorCell.h"
#import "ReportSelectionListTableViewController.h"
#import "StopwatchAppDelegate.h"
#import "Utilities.h"

@implementation ReportSelectorViewController

@synthesize reportSelectorTableViewController;
@synthesize runnerName;
@synthesize eventName;
@synthesize date;
@synthesize distance;
@synthesize generateButton;
@synthesize appDelegate;
@synthesize settingsViewController;

#define kSelectPrompt   @"Select events for report:"

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // ReportSelectorTableViewController
    reportSelectorTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UIView* reportSelectorTableView = reportSelectorTableViewController.view;
    reportSelectorTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:reportSelectorTableViewController.tableView];
    
    // Generate button
    generateButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];      // autorelease button
    [generateButton addTarget:self action:@selector(generateEmailReport) forControlEvents:UIControlEventTouchUpInside];
    [generateButton setTitle:@"Generate Report" forState:UIControlStateNormal];
    if (IPAD) {
        [generateButton.titleLabel setFont: [generateButton.titleLabel.font fontWithSize: 24]];
    } else {
        [generateButton.titleLabel setFont: [generateButton.titleLabel.font fontWithSize: 18]];
    }
    [generateButton setTintColor:self.view.tintColor];
    generateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:generateButton];
    
    // separator
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    separatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:separatorImageView];
    [separatorImageView release];
    
    // constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(reportSelectorTableView, generateButton, separatorImageView);
    
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[generateButton(220)]-(>=40)-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorImageView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(440)][separatorImageView(1)]-64-[generateButton(36)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[generateButton(160)]-(>=40)-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorImageView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(310)][separatorImageView(1)]-48-[generateButton(36)]" options:0 metrics:nil views:views]];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:generateButton
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.f constant:0.f]];

    
    reportSelectorTableViewController.tableView.delegate = self;
    reportSelectorTableViewController.tableView.dataSource = self;
    reportSelectorTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    reportSelectorTableViewController.tableView.scrollEnabled = NO;
    reportSelectorTableViewController.tableView.allowsSelection = YES;
    
    self.navigationItem.title = @"Email Report";
}

- (void)dealloc
{
    [reportSelectorTableViewController release];
    [generateButton release];
    
    reportSelectorTableViewController = nil;
    generateButton = nil;
    
    [super dealloc];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if (section == 1) {
        rows = 4;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return kSelectPrompt;
    } else if (section == 2) {
        return [NSString stringWithFormat:@"Selected event count:  %lu", [self getEventCount]];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //header.textLabel.textColor = self.view.tintColor;
    
    if (bEventCountZero && [header.textLabel.text caseInsensitiveCompare:kSelectPrompt] != NSOrderedSame) {
        header.textLabel.textColor = [UIColor redColor];
    } else  {
        header.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    if (IPAD) {
        header.textLabel.font = [UIFont fontWithName:@"Avenir Book" size:21];
    } else {
        header.textLabel.font = [UIFont fontWithName:@"Avenir Book" size:15];
    }
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IPAD) {
        return 72;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IPAD) {
        if (section == 0)
            return 40;
        else
            return 32;
    } else {
        if (section == 0)
            return 30;
        else
            return 20;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReportSelectorCellIdentifier = @"ReportSelectorCellIdentifier";
    
    // create an Event cell (HistoryCell) for the history table
    ReportSelectorCell *cell = (ReportSelectorCell *)[tableView dequeueReusableCellWithIdentifier:ReportSelectorCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReportSelectorCell" owner:self options:nil];
        
        for (id obj in nib) {
            if ([obj isKindOfClass:[ReportSelectorCell class]]) {
                cell = (ReportSelectorCell *)obj;
                // NOTE: The reuse identifier for a nib-based cell is set in IB in the Identifier field.
                // perform any set up common to all cells
            }
        }
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.selectorLabel.text = @"Athlete";
            cell.selectionLabel.text = self.runnerName;
            break;
        case 1:
            cell.selectorLabel.text = @"Event";
            cell.selectionLabel.text = self.eventName;
            break;
        case 2:
            cell.selectorLabel.text = @"Date";
            cell.selectionLabel.text = self.date;
            break;
        case 3:
            cell.selectorLabel.text = @"Distance";
            cell.selectionLabel.text = self.distance;
            break;
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate playClickSound];
    
    NSString *selectedValue = [self getValueForSelector:(int)indexPath.row+1];
    
    // push the help detail view controller
    ReportSelectionListTableViewController *rsltvc = [[ReportSelectionListTableViewController alloc] initWithMode:indexPath.row+1 selection:selectedValue ReportSelectorViewController:self];
    
    [self.navigationController pushViewController:rsltvc animated:YES];
    [rsltvc release];
}

- (void)setValue:(NSString*)value forSelector:(int)selector
{
    switch (selector) {
        case kAthleteSelectorMode:
            self.runnerName = value;
            break;
        case kEventSelectorMode:
            self.eventName = value;
            break;
        case kDateSelectorMode:
            self.date = value;
            break;
        case kDistanceSelectorMode:
            self.distance = value;
            break;
    }
    
    [reportSelectorTableViewController.tableView reloadData];
}

- (NSString*)getValueForSelector:(int)selector
{
    switch (selector) {
        case kAthleteSelectorMode:
            return self.runnerName;
            break;
        case kEventSelectorMode:
            return self.eventName;
            break;
        case kDateSelectorMode:
            return self.date;
            break;
        case kDistanceSelectorMode:
            return self.distance;
            break;
    }
    
    return @"";
}

- (long)getEventCount
{
    NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnAthlete:self.runnerName Event:self.eventName Date:self.date Distance:self.distance];
    
    if (eventInfoArray.count == 0) {
        generateButton.enabled = NO;
        bEventCountZero = YES;
    } else {
        generateButton.enabled = YES;
        bEventCountZero = NO;
    }
    
    return eventInfoArray.count;
}

- (void)generateEmailReport
{
    //NSLog(@"generate report for %@ %@ %@ %@", self.runnerName, self.eventName, self.date, self.distance);
    
    NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnAthlete:self.runnerName Event:self.eventName Date:self.date Distance:self.distance];
    
    if (eventInfoArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Report"
                                                            message:@"There are no events that match all of your selections."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    if ([MFMailComposeViewController canSendMail])
    {
        // init mail view controller
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.barStyle = UIBarStyleDefault;
        
        // subject and title string
        NSString *subjectStr;
        
        if (eventInfoArray.count == 1) {
            NSNumber *eventNum = [eventInfoArray[0] objectAtIndex:0];
            
            // create an Event using the EventNum
            Event *event = [[[Event alloc] initWithEventNum:[eventNum intValue]] autorelease];
            
            if (event.iEventType != kLap) {
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
        } else {
            subjectStr = @"Splitwatch Report";
        }
        
        [mailViewController setSubject:subjectStr];
        [mailViewController setToRecipients:[settingsViewController getDefaultEmailAddresses]];
        
        // Attach an image to the email
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
        //NSData *myData = [NSData dataWithContentsOfFile:path];
        //[mailViewController addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
        
        // HTML version
        NSMutableString *emailBody = [NSMutableString stringWithString:@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' "];
        [emailBody appendString:@"'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "];
        [emailBody appendString:@"<html xmlns='http://www.w3.org/1999/xhtml'>"];
        [emailBody appendString:@"<head><title>Report</title><link rel='stylesheet' type='text/css' href='./style.css' /> </head>"];
        [emailBody appendString:@"<body><div id='container' style='font-family:arial; font-size:14px;'>"];
        [emailBody appendString:@"<div id='title' style='margin-bottom:15px; font-weight:bold;'>"];
        [emailBody appendString:@"Split Report by <a href='http://www.segnetix.com/splitwatch'>SPLITWATCH</a></div>"];
        [emailBody appendString:@"<div style='margin-bottom:30px;'>"];
        
        // cycle each event
        for (NSArray *eventArray in eventInfoArray)
        {
            NSNumber *eventNum = [eventArray objectAtIndex:0];
            
            // create an Event using the EventNum
            Event *event = [[[Event alloc] initWithEventNum:[eventNum intValue]] autorelease];
            NSMutableArray *splits = [event getSplitData];
            
            [emailBody appendString:@"<table id='split data' cellpadding-right='3'>"];
            
            if (event.bFurlongMode)
                [emailBody appendFormat:@"<tr><td>Horse:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];
            else
                [emailBody appendFormat:@"<tr><td>Athlete:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];
            
            [emailBody appendFormat:@"<tr><td>Event Name:</td><td>&nbsp;</td><td>%@</td></tr>", event.eventName];
            [emailBody appendFormat:@"<tr><td>Date:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities formatDate:event.date]];
            
            if (event.iEventType != kLap)
                [emailBody appendFormat:@"<tr><td>Distance:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities stringFromDistance:event.distance Units:event.iEventType ShowMiles:YES ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode]];
            [emailBody appendFormat:@"<tr><td>Distance:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities stringFromDistance:(int)event.distance Units:event.iEventType ShowMiles:YES ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode]];
            [emailBody appendFormat:@"<tr><td>Time:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities shortFormatTime:event.finalTime precision:2]];
            [emailBody appendString:@"<tr style='height:10px;'/></table>"];
            [emailBody appendString:[Utilities getSplitHTMLDataString:splits forIntervalDistance:event.lapDistance forUnits:event.iEventType  forKiloSplits:event.bKiloSplits forFurlongMode:event.bFurlongMode]];
            [emailBody appendString:@"--------------------------------------------------------------------<p></p>"];
        }
        
        [emailBody appendString:@"</div></div></body></html>"];
        
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
