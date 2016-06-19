//
//  Stopwatch.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/18/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiStopwatchTableViewController.h"

@class MultiStopwatchCell;

@interface Stopwatch : NSObject
{
	BOOL bTimerRunning;
	
	NSTimer *timer;
	NSTimeInterval startTime;
	NSTimeInterval stopTime;
	NSTimeInterval elapsedTime;
	NSTimeInterval lapTime;
	NSTimeInterval previousLapTime;
	NSTimeInterval currentRunningTime;
	NSTimeInterval currentLapTime;
	NSInteger lapCount;
	
	NSMutableArray *splits;
	NSInteger intervalDistance;
	NSString *runnerName;
	NSString *eventName;
	int iEventType;
	BOOL bKiloSplits;
	BOOL bFurlongMode;
	
	MultiStopwatchTableViewController *multiStopwatchTableViewController;
	MultiStopwatchCell *stopwatchCell;
}

@property (nonatomic, retain) NSTimer	*timer;
@property NSTimeInterval startTime;
@property NSTimeInterval stopTime;
@property NSTimeInterval elapsedTime;
@property NSTimeInterval lapTime;
@property NSTimeInterval previousLapTime;
@property NSTimeInterval currentRunningTime;
@property NSTimeInterval currentLapTime;
@property NSInteger lapCount;
@property BOOL bTimerRunning;
@property NSInteger intervalDistance;
@property (nonatomic, retain) NSString *runnerName;
@property (nonatomic, retain) NSString *eventName;
@property int iEventType;
@property BOOL bKiloSplits;
@property BOOL bFurlongMode;
@property (nonatomic, retain) NSMutableArray *splits;
@property (assign) MultiStopwatchTableViewController *multiStopwatchTableViewController;
@property (assign) MultiStopwatchCell *stopwatchCell;

- (id)initWithMultiStopwatchTableViewController:(MultiStopwatchTableViewController *)theMultiStopwatchTableVC
									eventType:(int)eventType
									 kiloSplits:(BOOL)kiloSplits
									furlongMode:(BOOL)furlongMode;
- (void)addNewEventToDatabase;
- (void)addSplit:(NSTimeInterval)split;
- (void)startRunningTimer;
- (void)startStopButtonPressed;
- (void)lapResetButtonPressed;
- (void)updateTimeCounts;
- (BOOL)isReset;

@end
