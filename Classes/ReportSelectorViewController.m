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
@synthesize emailButton;
@synthesize printButton;
@synthesize appDelegate;
@synthesize settingsViewController;

#define kSelectPrompt   @"Select events for report:"
#define POINTS_PER_INCH 72

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
    
    // button images (with tint)
    UIImage *emailImage = [UIImage imageNamed:@"email.png"];
    UIImage *printImage = [UIImage imageNamed:@"print"];
    
    emailImage = [emailImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    printImage = [printImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    // Email button
    emailButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];      // autorelease button
    emailButton.contentMode = UIViewContentModeScaleToFill;
    emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    emailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [emailButton setImage:emailImage forState:UIControlStateNormal];
    [emailButton addTarget:self action:@selector(generateEmailReport) forControlEvents:UIControlEventTouchUpInside];
    if (IPAD) {
        [emailButton.titleLabel setFont: [emailButton.titleLabel.font fontWithSize: 26]];
    } else {
        [emailButton.titleLabel setFont: [emailButton.titleLabel.font fontWithSize: 18]];
    }
    [emailButton setTintColor:self.view.tintColor];
    emailButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:emailButton];
    
    // Print button
    printButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];      // autorelease button
    printButton.contentMode = UIViewContentModeScaleToFill;
    printButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    printButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [printButton setImage:printImage forState:UIControlStateNormal];
    [printButton addTarget:self action:@selector(printReport) forControlEvents:UIControlEventTouchUpInside];
    if (IPAD) {
        [printButton.titleLabel setFont: [printButton.titleLabel.font fontWithSize: 26]];
    } else {
        [printButton.titleLabel setFont: [printButton.titleLabel.font fontWithSize: 18]];
    }
    [printButton setTintColor:self.view.tintColor];
    printButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:printButton];

    
    // separator
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *topSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    topSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topSeparatorImageView];
    [self.view addSubview:bottomSeparatorImageView];
    [topSeparatorImageView release];
    [bottomSeparatorImageView release];
    
    // constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(reportSelectorTableView, emailButton, printButton, topSeparatorImageView, bottomSeparatorImageView);
    
    if (IPAD) {
        //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[generateButton(100)]-(>=40)-|" options:0 metrics:nil views:views]];
        //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[printButton(100)]-(>=40)-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-200-[emailButton(52)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[printButton(52)]-200-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(440)][topSeparatorImageView(1)]-60-[emailButton(52)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[printButton(52)]" options:0 metrics:nil views:views]];
    } else {
        //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[emailButton(80)]-(>=40)-|" options:0 metrics:nil views:views]];
        //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=40)-[printButton(80)]-(>=40)-|" options:0 metrics:nil views:views]];
        
        if (self.view.frame.size.height <= 568) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[emailButton(44)]" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[printButton(44)]-60-|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
            if (self.view.frame.size.height < 500) {
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(310)][topSeparatorImageView(1)]-20-[emailButton(44)]" options:0 metrics:nil views:views]];
            } else {
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(310)][topSeparatorImageView(1)]-60-[emailButton(44)]" options:0 metrics:nil views:views]];
            }
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[printButton(44)]" options:0 metrics:nil views:views]];
        } else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[emailButton(52)]" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[printButton(52)]-80-|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[reportSelectorTableView(310)][topSeparatorImageView(1)]-48-[emailButton(52)]" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[printButton(52)]" options:0 metrics:nil views:views]];
        }
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    
    /*
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:generateButton
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.f constant:0.f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:printButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
     */
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:emailButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:printButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f constant:0.f]];
    
    reportSelectorTableViewController.tableView.delegate = self;
    reportSelectorTableViewController.tableView.dataSource = self;
    reportSelectorTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    reportSelectorTableViewController.tableView.scrollEnabled = NO;
    reportSelectorTableViewController.tableView.allowsSelection = YES;
    
    self.navigationItem.title = NSLocalizedString(@"Report", nil);
}

- (void)dealloc
{
    [reportSelectorTableViewController release];
    [emailButton release];
    [printButton release];
    [date release];
    [distance release];
    [eventName release];
    [runnerName release];
    
    reportSelectorTableViewController = nil;
    emailButton = nil;
    printButton = nil;
    date = nil;
    distance = nil;
    eventName = nil;
    runnerName = nil;
    
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
            cell.selectorLabel.text = NSLocalizedString(@"Athlete", nil);
            cell.selectionLabel.text = self.runnerName;
            break;
        case 1:
            cell.selectorLabel.text = NSLocalizedString(@"Event", nil);
            cell.selectionLabel.text = self.eventName;
            break;
        case 2:
            cell.selectorLabel.text = NSLocalizedString(@"Date", nil);
            cell.selectionLabel.text = self.date;
            break;
        case 3:
            cell.selectorLabel.text = NSLocalizedString(@"Distance", nil);
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
    
    // don't leave the selected row highlighted on return
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
    
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
        emailButton.enabled = NO;
        printButton.enabled = NO;
        bEventCountZero = YES;
    } else {
        emailButton.enabled = YES;
        printButton.enabled = YES;
        bEventCountZero = NO;
    }
    
    return eventInfoArray.count;
}

- (NSString*)getReportHTML
{
    // HTML version
   // NSMutableString *reportHTML = [NSMutableString stringWithString:@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' "];
    //[reportHTML appendString:@"'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "];
    //[reportHTML appendString:@"<html xmlns='http://www.w3.org/1999/xhtml'>"];
    //[reportHTML appendString:@"<head><title>Report</title><link rel='stylesheet' type='text/css' href='./style.css' /> </head>"];
    //NSMutableString *reportHTML = [NSMutableString stringWithString:@"<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Report</title></head><body>"];
      NSMutableString *reportHTML = [NSMutableString stringWithString:@"<!DOCTYPE html><style></style><html><head><meta charset='UTF-8'><title>Title</title></head>"];
    [reportHTML appendString:@"<div id='container' style='font-family:arial; font-size:14px;'>"];
    [reportHTML appendString:@"<div id='title' style='margin-bottom:15px; font-weight:bold;'>"];
    [reportHTML appendString:@"Split Report by <a href='http://www.segnetix.com/splitwatch'>SPLITWATCH</a></div>"];
    [reportHTML appendString:@"<div style='margin-bottom:30px;'>"];
    
    // cycle each event
    NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnAthlete:self.runnerName Event:self.eventName Date:self.date Distance:self.distance];

    for (NSArray *eventArray in eventInfoArray)
    {
        NSNumber *eventNum = [eventArray objectAtIndex:0];
        
        // create an Event using the EventNum
        Event *event = [[[Event alloc] initWithEventNum:[eventNum intValue]] autorelease];
        NSMutableArray *splits = [event getSplitData];
        
        [reportHTML appendString:@"<table id='split data' cellpadding-right='3'>"];
        
        if (event.bFurlongMode)
            [reportHTML appendFormat:@"<tr><td>Horse:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];
        else
            [reportHTML appendFormat:@"<tr><td>Athlete:</td><td>&nbsp;</td><td>%@</td></tr>", event.runnerName];
        
        [reportHTML appendFormat:@"<tr><td>Event Name:</td><td>&nbsp;</td><td>%@</td></tr>", event.eventName];
        [reportHTML appendFormat:@"<tr><td>Date:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities formatDate:event.date]];
        
        if (event.iEventType != kLap)
            [reportHTML appendFormat:@"<tr><td>Distance:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities stringFromDistance:event.distance Units:event.iEventType ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode]];
        [reportHTML appendFormat:@"<tr><td>Distance:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities stringFromDistance:(int)event.distance Units:event.iEventType ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode]];
        [reportHTML appendFormat:@"<tr><td>Time:</td><td>&nbsp;</td><td>%@</td></tr>", [Utilities shortFormatTime:event.finalTime precision:2]];
        [reportHTML appendString:@"<tr style='height:10px;'/></table>"];
        [reportHTML appendString:[Utilities getSplitHTMLDataString:splits forIntervalDistance:event.lapDistance forUnits:event.iEventType  forKiloSplits:event.bKiloSplits forFurlongMode:event.bFurlongMode]];
        [reportHTML appendString:@"--------------------------------------------------------------------<p></p>"];
    }
    
    [reportHTML appendString:@"</div></div></body></html>"];
    
    return reportHTML;
}

- (void)generateEmailReport
{
    //NSLog(@"generate report for %@ %@ %@ %@", self.runnerName, self.eventName, self.date, self.distance);
    
    NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnAthlete:self.runnerName Event:self.eventName Date:self.date Distance:self.distance];
    
    if (eventInfoArray.count == 0) {
        // shouldn't get here as we disable the Generate button in this case
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Report"
                                                            message:@"There are no events that match all of your selections."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        */
        return;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
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
                              [Utilities stringFromDistance:(int)event.distance Units:event.iEventType ShowSplitTag:YES Interval:(int)event.lapDistance FurlongDisplayMode:event.bFurlongMode],
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
        
        // HTML version
        NSString* emailBody = [self getReportHTML];
        
        [mailViewController setMessageBody:emailBody isHTML:YES];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't Send Email!", nil)
                                                            message:@"This device is not configured for sending email."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];	
    }

}

- (void)printReport
{
    NSLog(@"printReport");
    
    if ([UIPrintInteractionController isPrintingAvailable]) {
        UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
        
        if (printController == nil) {
            return;
        }
        
        NSString* report = [self getReportHTML];
        
        UIMarkupTextPrintFormatter *htmlFormatter = [[[UIMarkupTextPrintFormatter alloc] initWithMarkupText:report] autorelease];
        htmlFormatter.perPageContentInsets = UIEdgeInsetsMake(POINTS_PER_INCH * 0.75f,  // 3/4 inch top margin
                                                              POINTS_PER_INCH * 0.75f,  // 3/4 inch left margin
                                                              POINTS_PER_INCH * 0.75f,  // 3/4 inch bottom margin
                                                              POINTS_PER_INCH * 0.75f); // 3/4 inch right margin
        
        printController.printFormatter = htmlFormatter;
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName    = NSLocalizedString(@"Split Report", nil);
        printController.printInfo = printInfo;
        printController.delegate = self;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"Print Failure! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
                NSLog(@"Desc: %@", error.description);
            }
        };
        
        [printController presentAnimated:YES completionHandler:completionHandler];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't Print Report!", nil)
                                                            message:@"This device is not configured for printing."
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
            message = NSLocalizedString(@"Email Canceled", nil);
            break;
        case MFMailComposeResultSaved:
            message = NSLocalizedString(@"Email Saved", nil);
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"Email Sent", nil);
            break;
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"Email Failed", nil);
            break;
        default:
            message = NSLocalizedString(@"Email Not Sent", nil);
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
