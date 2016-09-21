//
//  SplitDetailCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/9/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "SplitDetailCell.h"
#import "SplitDetailViewController.h"
#import "Utilities.h"

@implementation SplitDetailCell

@synthesize lapColumn;
@synthesize timeColumn;
@synthesize splitColumn1;
@synthesize splitColumn2;
@synthesize splitColumn3;
@synthesize splitColumn4;
@synthesize accDisclosureImage;
@synthesize accImageView;
@synthesize separatorImage;
@synthesize separatorImageView;
@synthesize splitDetailViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// initialization
    }
    
    return self;
}

- (void)dealloc
{
	[lapColumn release];
	[timeColumn release];
	[splitColumn1 release];
	[splitColumn2 release];
	[splitColumn3 release];
	[splitColumn4 release];
	
	lapColumn = nil;
	timeColumn = nil;
	splitColumn1 = nil;
	splitColumn2 = nil;
	splitColumn3 = nil;
	splitColumn4 = nil;
	accDisclosureImage = nil;
	accImageView = nil;
	separatorImage = nil;
	separatorImageView = nil;
	
    [super dealloc];
}

- (void)additionalSetup
{
	accDisclosureImage = [UIImage imageNamed:@"AccDisclosure.png"];
	accImageView = [[[UIImageView alloc] initWithImage:accDisclosureImage] autorelease];
    accImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:accImageView];
	
	separatorImage = [UIImage imageNamed:@"separator.png"];
	separatorImageView = [[[UIImageView alloc] initWithImage:separatorImage] autorelease];
    separatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:separatorImageView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(accImageView, separatorImageView);
    
    if (IPAD) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-1-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[accImageView(14)]" options:0 metrics:nil views:views]];
        
        lapColumn.font = [UIFont fontWithName:FONT_NAME size:22];
        timeColumn.font = [UIFont fontWithName:FONT_NAME size:22];
        splitColumn1.font = [UIFont fontWithName:FONT_NAME size:22];
        splitColumn2.font = [UIFont fontWithName:FONT_NAME size:22];
        splitColumn3.font = [UIFont fontWithName:FONT_NAME size:22];
        splitColumn4.font = [UIFont fontWithName:FONT_NAME size:22];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-1-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[accImageView(14)]" options:0 metrics:nil views:views]];
        
        lapColumn.font = [UIFont fontWithName:FONT_NAME size:14];
        timeColumn.font = [UIFont fontWithName:FONT_NAME size:14];
        splitColumn1.font = [UIFont fontWithName:FONT_NAME size:14];
        splitColumn2.font = [UIFont fontWithName:FONT_NAME size:14];
        splitColumn3.font = [UIFont fontWithName:FONT_NAME size:14];
        splitColumn4.font = [UIFont fontWithName:FONT_NAME size:14];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorImageView]-12-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorImageView(1)]|" options:0 metrics:nil views:views]];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.splitDetailViewController == nil ||
        event.type != UIEventTypeTouches) {
        return;
    }
    
    // store current sel type for comparison later
    SummarySelectionType prevSelType = self.splitDetailViewController.summarySelection;
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint tappedLocation = [touch locationInView:touch.view];
    
    if ([lapColumn.text isEqualToString:@"Min:"]) {
        if (CGRectContainsPoint(lapColumn.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kNone;
        } else if (CGRectContainsPoint(timeColumn.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kTimeColumnMin;
        } else if (CGRectContainsPoint(splitColumn1.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn1Min;
        } else if (CGRectContainsPoint(splitColumn2.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn2Min;
        } else if (CGRectContainsPoint(splitColumn3.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn3Min;
        } else if (CGRectContainsPoint(splitColumn4.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn4Min;
        }
    } else if ([lapColumn.text isEqualToString:@"Max:"]) {
        if (CGRectContainsPoint(lapColumn.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kNone;
        } else if (CGRectContainsPoint(timeColumn.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kTimeColumnMax;
        } else if (CGRectContainsPoint(splitColumn1.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn1Max;
        } else if (CGRectContainsPoint(splitColumn2.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn2Max;
        } else if (CGRectContainsPoint(splitColumn3.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn3Max;
        } else if (CGRectContainsPoint(splitColumn4.frame, tappedLocation)) {
            self.splitDetailViewController.summarySelection = kSplitColumn4Max;
        }
    } else {
        self.splitDetailViewController.summarySelection = kNone;
    }
    
    // if sel type has changed then reload table view
    if (self.splitDetailViewController.summarySelection != prevSelType) {
        [self.splitDetailViewController.tableView reloadData];
    }
}

@end
