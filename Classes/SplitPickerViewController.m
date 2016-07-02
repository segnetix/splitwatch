//
//  SplitPickerViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 3/1/15.
//  Copyright (c) 2015 SEGNETIX. All rights reserved.
//

#import "SplitPickerViewController.h"

#define	kHours						0
#define	kMinutes					1
#define kSeconds					2
#define kHundredths					3

//@interface SplitPickerViewController ()
//@end

@implementation SplitPickerViewController

@synthesize pickerToolbar1;
@synthesize pickerToolbar2;
@synthesize pickView;
@synthesize editLabel;
@synthesize beforeLabel;
@synthesize afterLabel;
@synthesize beforeTimeLabel;
@synthesize beforeSplitLabel;
@synthesize editTimeLabel;
@synthesize editSplitLabel;
@synthesize afterTimeLabel;
@synthesize afterSplitLabel;
@synthesize splitDetailViewController;

- (id)initWithEvent:(Event *)theEvent andRow:(int)row
{
    if (self = [super initWithNibName:@"SplitPickerViewController" bundle:nil])
    {
        //bLoading = YES;
        event = theEvent;
						  
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        database = [appDelegate getEventDatabase];
        
        pickerSplitIndex = row;
        
        [self setSplitTimeLabelsFromEvent];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Split Edit";
    
    
    
    [self setSplitTimeLabelsFromEvent];
}

- (void)dealoc
{
    [editLabel release];
    [beforeLabel release];
    [afterLabel release];
    [editTimeLabel release];
    [editSplitLabel release];
    [beforeTimeLabel release];
    [beforeSplitLabel release];
    [afterTimeLabel release];
    [afterSplitLabel release];
    
    editLabel = nil;
    beforeLabel = nil;
    afterLabel = nil;
    editTimeLabel = nil;
    editSplitLabel = nil;
    beforeTimeLabel = nil;
    beforeSplitLabel = nil;
    afterTimeLabel = nil;
    afterSplitLabel = nil;
    
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [editLabel release];
    [beforeLabel release];
    [afterLabel release];
    [editTimeLabel release];
    [editSplitLabel release];
    [beforeTimeLabel release];
    [beforeSplitLabel release];
    [afterTimeLabel release];
    [afterSplitLabel release];
    
    editLabel = nil;
    beforeLabel = nil;
    afterLabel = nil;
    editTimeLabel = nil;
    editSplitLabel = nil;
    beforeTimeLabel = nil;
    beforeSplitLabel = nil;
    afterTimeLabel = nil;
    afterSplitLabel = nil;
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double)getTimePickerTime
{
    int		hrs =		 (int)[pickView selectedRowInComponent:kHours];
    int		min =		 (int)[pickView selectedRowInComponent:kMinutes];
    int		sec =		 (int)[pickView selectedRowInComponent:kSeconds];
    double	hundredths = (int)[pickView selectedRowInComponent:kHundredths];
    
    double split =  (hrs * 3600) +
    (min * 60) +
    sec +
    (hundredths / 100);
    
    return split;
}

//- (void)setSplitTimeLabels:(double)editTime beforeTime:(double)beforeTime afterTime:(double)afterTime
- (void)setSplitTimeLabelsFromEvent
{
    double editTime = [event getSplit:pickerSplitIndex];
    
    [self setSplitTimeLabels:editTime];
    [self setTimePickerTime:editTime];
}

- (void)setSplitTimeLabelsFromPicker
{
    double editTime = [self getTimePickerTime];
    
    [self setSplitTimeLabels:editTime];
}

- (void)setSplitTimeLabels:(double)editTime
{
    double beforeSplit = 0.0;
    double editSplit = 0.0;
    double afterSplit = 0.0;
    double beforeTime = 0.0;
    double afterTime = 0.0;
    
    beforeLabel.text = @"---";
    afterLabel.text  = @"---";
    //editLabel.text   = [NSString stringWithFormat:@"Split %ld", (long)pickerSplitIndex+1];
    editLabel.text = [Utilities lapTextForRow:pickerSplitIndex forDisplayMode:kDisplayMode_Normal forSplits:event.splitArray forIntervalDistance:event.lapDistance forUnits:event.iEventType forFurlongMode:event.bFurlongMode];
    
    if (pickerSplitIndex-1 >= 0)
    {
        beforeTime = [event getSplit:pickerSplitIndex-1];
        //beforeLabel.text = [NSString stringWithFormat:@"Split %ld", (long)pickerSplitIndex];
        beforeLabel.text = [Utilities lapTextForRow:pickerSplitIndex-1 forDisplayMode:kDisplayMode_Normal forSplits:event.splitArray forIntervalDistance:event.lapDistance forUnits:event.iEventType forFurlongMode:event.bFurlongMode];
    }
    
    if (pickerSplitIndex+1 < [event.splitArray count])
    {
        afterTime = [event getSplit:pickerSplitIndex+1];
        //afterLabel.text = [NSString stringWithFormat:@"Split %ld", (long)pickerSplitIndex+2];
        afterLabel.text = [Utilities lapTextForRow:pickerSplitIndex+1 forDisplayMode:kDisplayMode_Normal forSplits:event.splitArray forIntervalDistance:event.lapDistance forUnits:event.iEventType forFurlongMode:event.bFurlongMode];
    }
    
    editSplit = editTime - beforeTime;
    
    if (pickerSplitIndex > 1)
        beforeSplit = beforeTime - [event getSplit:pickerSplitIndex-2];
    else if (pickerSplitIndex == 1)
        beforeSplit = beforeTime;
    
    if (pickerSplitIndex < [event.splitArray count])
        afterSplit = afterTime - editTime;
    
    if (beforeSplit > 0)
    {
        beforeSplitLabel.text = [Utilities shortFormatTime:beforeSplit precision:2];
        beforeTimeLabel.text = [Utilities shortFormatTime:beforeTime precision:2];
    }
    else
    {
        beforeSplitLabel.text = @"---";
        beforeTimeLabel.text  = @"---";
    }
    
    if (afterSplit > 0)
    {
        afterSplitLabel.text = [Utilities shortFormatTime:afterSplit precision:2];
        afterTimeLabel.text = [Utilities shortFormatTime:afterTime precision:2];
    }
    else
    {
        afterSplitLabel.text = @"---";
        afterTimeLabel.text  = @"---";
    }
    
    if (editSplit > 0)
        editSplitLabel.text = [Utilities shortFormatTime:editSplit precision:2];
    else
        editSplitLabel.text = @"---";
    
    editTimeLabel.text = [Utilities shortFormatTime:editTime precision:2];
}

- (void)setTimePickerTime:(double)editTime
{
    int hrs =		 [Utilities getHrs:editTime];
    int min =		 [Utilities getMin:editTime];
    int sec =		 [Utilities getSec:editTime];
    int hundredths = [Utilities getHundredths:editTime];
    
    [pickView selectRow:hrs			inComponent:kHours		animated:NO];
    [pickView selectRow:min			inComponent:kMinutes	animated:NO];
    [pickView selectRow:sec			inComponent:kSeconds	animated:NO];
    [pickView selectRow:hundredths	inComponent:kHundredths	animated:NO];
}

- (IBAction)changeSplit:(id)sender
{
    //[appDelegate playClickSound];
    
    double origSplit = [event getSplit:pickerSplitIndex];
    double split = [self getTimePickerTime];
    
    if ([event split:split isValidForSplitIndex:pickerSplitIndex])
    {
        [event setSplit:split forIndex:pickerSplitIndex];
        [event updateSelfInDatabase];
        [self.splitDetailViewController flashSplitCellsInRow:pickerSplitIndex];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *message;
        
        if (split < origSplit)
            message = @"The new split time is less than the previous split.  Use 'Insert Split' to create a new split outside this range.";
        else
            message = @"The new split time is greater than the next split.  Use 'Insert Split' to create a new split outside this range.";
        
        // split time is not valid
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Split time is not valid!"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        // restore split labels
        [self setSplitTimeLabels:origSplit];
        [self setTimePickerTime:origSplit];
    }
}

- (IBAction)deleteSplit:(id)sender
{
    //[appDelegate playClickSound];
    
    // are you sure you want to delete?
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete the selected split?"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[appDelegate playClickSound];
    
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        // OK
        [event deleteSplit:pickerSplitIndex];
        [event updateSelfInDatabase];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)insertSplit:(id)sender
{
    //[appDelegate playClickSound];
    
    double split = [self getTimePickerTime];
    
    [event insertSplit:split];
    [event updateSelfInDatabase];
    [self.splitDetailViewController flashSplitCellsInRow:pickerSplitIndex + 1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelEdit:(id)sender
{
    //[appDelegate playClickSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)setPickerDataArrayWith:(NSNumber*)split
{
    [pickView reloadAllComponents];
}
*/

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    double editTime = [self getTimePickerTime];
    
    [self setSplitTimeLabels:editTime];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    switch (component)
    {
        case kHours:		return 100;	break;
        case kMinutes:		return  60;	break;
        case kSeconds:		return  60;	break;
        case kHundredths:	return 100;	break;
        default:			return   0;	break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    NSMutableString *cellString = [NSMutableString stringWithString:@""];
    
    if (row < 10)
        [cellString appendString:@"   0"];
    else
        [cellString appendString:@"   "];
    
    
    switch (component)
    {
        case kHours:
        case kMinutes:
        case kSeconds:
            [cellString appendFormat:@"%ld", (long)row];
            break;
        case kHundredths:
            if (row < 10)
                [cellString appendFormat:@"  .0%ld", (long)row];
            else
                [cellString appendFormat:@"  .%ld",  (long)row];
            break;
        default:		break;
    }
    
    return cellString;
}

- (void)dealloc
{
    [pickView release];
    [pickerToolbar1 release];
    [pickerToolbar2 release];
    [super dealloc];
}
@end
