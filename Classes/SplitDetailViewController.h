//
//  EventDetailViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

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
	
	SplitEditViewController *splitEditViewController;
	StopwatchAppDelegate *appDelegate;
}

@property (nonatomic, retain) NSMutableArray *splits;
@property BOOL bFinished;
@property BOOL bEditMode;
@property (nonatomic, assign) SplitEditViewController *splitEditViewController;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (nonatomic, retain) Event *event;

- (id)initWithIntervalDistance:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode Finished:(BOOL)finished EditMode:(BOOL)editMode;
- (void)addSplit:(NSTimeInterval)split;
- (NSMutableArray *)getSplits;
- (void)clearSplits;
- (NSTimeInterval)getFinalTime;
- (NSInteger)getFinalDistance;
- (void)resetLapInterval:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode;
- (void)scrollToLastLine;
- (void)scrollToTop;
- (void)refreshSplitView:(BOOL)scrollToLastLine;

- (NSString *)lapTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode;
- (NSString *)timeTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode;
- (NSString *)splitTextForRow:(NSInteger)row Column:(NSInteger)column forDisplayMode:(NSInteger)mode;
- (NSString *)lastSplitTextForColumn:(NSInteger)column;
- (NSString *)lastSplitHeaderHTMLText:(int)rowCount;
- (NSString *)lastSplitHTMLText;
- (NSString *)splitHTMLTextForRow:(NSInteger)row;
- (NSString *)getSplitHTMLDataString;

@end
