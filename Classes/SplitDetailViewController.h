//
//  EventDetailViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "SplitDetailCell.h"

@class SplitEditViewController;
@class StopwatchAppDelegate;

@interface SplitDetailViewController : UITableViewController
{
	NSMutableArray *splits;
	NSInteger intervalDistance;

	int  iUnits;
	BOOL bKiloSplits;
	BOOL bFurlongMode;
	BOOL bFinished;
	BOOL bEditMode;
    BOOL bWideDisplay;
	SummarySelectionType summarySelection;
    NSInteger initialHighlightRow;
    
	SplitEditViewController *splitEditViewController;
	StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, retain) NSMutableArray *splits;
@property BOOL bFinished;
@property BOOL bEditMode;
@property BOOL bWideDisplay;
@property (nonatomic, assign) SplitEditViewController *splitEditViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (nonatomic, retain) Event *event;
@property (nonatomic) SummarySelectionType summarySelection;
@property (nonatomic) NSInteger initialHighlightRow;

- (id)initWithIntervalDistance:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode Finished:(BOOL)finished EditMode:(BOOL)editMode;
- (void)addSplit:(NSTimeInterval)split;
- (NSMutableArray *)getSplits;
- (void)clearSplits;
- (NSTimeInterval)getFinalTime;
- (NSInteger)getFinalDistance;
- (void)summarySelectionDidChange;
- (void)resetLapInterval:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode;
- (void)scrollToLastLine;
- (void)scrollToTop;
//- (void)processRowSelection:(NSInteger)displayMode withDistance:(NSString *)distance;
- (void)flashSplitCellsInRow:(long)row;
- (void)refreshSplitView:(BOOL)scrollToLastLine;

@end
