//
//  Stopwatch.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/18/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "Stopwatch.h"
#import "MultiStopwatchCell.h"
#import "Event.h"

@implementation Stopwatch

@synthesize bTimerRunning;
@synthesize lapCount;
@synthesize timer;
@synthesize startTime;
@synthesize stopTime;
@synthesize elapsedTime;
@synthesize lapTime;
@synthesize previousLapTime;
@synthesize currentRunningTime;
@synthesize	currentLapTime;
@synthesize splits;
@synthesize intervalDistance;
@synthesize multiStopwatchTableViewController;
@synthesize	stopwatchCell;
@synthesize runnerName;
@synthesize eventName;
@synthesize iEventType;
@synthesize bKiloSplits;
@synthesize bFurlongMode;

- (id)initWithMultiStopwatchTableViewController:(MultiStopwatchTableViewController *)theMultiStopwatchTableVC
									eventType:(int)eventType
									 kiloSplits:(BOOL)kiloSplits
									furlongMode:(BOOL)furlongMode
{
	if (self = [super init])
	{
		multiStopwatchTableViewController = theMultiStopwatchTableVC;
		iEventType = eventType;
		bKiloSplits = kiloSplits;
		bFurlongMode = furlongMode;
		
		splits = [[NSMutableArray alloc] init];
		
		runnerName = @"";
		eventName = @"";
	}
	
    return self;
}

- (void)dealloc
{
	[splits release];
	[timer release];
	[runnerName release];
	[eventName release];
	
	splits = nil;
	timer = nil;
	runnerName = nil;
	eventName = nil;
	
	[super dealloc];
}

- (void)addSplit:(NSTimeInterval)split
{	
	[splits addObject:[NSNumber numberWithDouble:split]];
}

- (void)startRunningTimer
{
	// START TIMER
	previousLapTime = lapTime;
	
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.03
											 target: self
										   selector: @selector(updateTimeCounts)
										   userInfo: nil
											repeats: YES];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

// reset means stopped and not holding any watch state 
- (BOOL)isReset
{
	return (timer == nil && lapCount == 0);
}

- (void)startStopButtonPressed
{
	// toggle state
	bTimerRunning = !bTimerRunning;
	
	if (bTimerRunning)
	{
		// START TIMER
		startTime = [NSDate timeIntervalSinceReferenceDate] - elapsedTime;
		
		// for large time testing - will clip at 99:59:59.99
		//startTime -= 3595;
		
		lapTime = startTime;
		previousLapTime = lapTime;
		
		timer = [NSTimer scheduledTimerWithTimeInterval: 0.03
												 target: self
											   selector: @selector(updateTimeCounts)
											   userInfo: nil
												repeats: YES];
		
        // this will allow the timer to fire on any loop in case the user is scrolling
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
		// clear any previous split events
		[splits removeAllObjects];
		
		// notify the multiStopwatchTableViewController
		[multiStopwatchTableViewController aWatchStarted:self];
	}
	else
	{
		// STOP TIMER
		stopTime = [NSDate timeIntervalSinceReferenceDate];
		[timer invalidate];
		timer = nil;
		
		elapsedTime = stopTime - startTime;
		previousLapTime = lapTime;
		lapTime = stopTime;
		lapCount++;
		
		[self updateTimeCounts];
		
		// add last split to splits array
		[splits addObject:[NSNumber numberWithDouble:elapsedTime]];
		
		// NOTE: Watches are committed to the db by the table
		// view controller only after all watches have stopped.
		// This aids performance of any still running multiwatches.
		
		// add new record to the event database
		//[self addNewEventToDatabase];
		
		// notify the multiStopwatchTableViewController
		[multiStopwatchTableViewController aWatchStopped:self];
	}
}

- (void)lapResetButtonPressed
{
	if (bTimerRunning)
	{
		// LAP BUTTON
		previousLapTime = lapTime;
		lapTime = [NSDate timeIntervalSinceReferenceDate];
		lapCount++;
		
		// add split to split window
		NSTimeInterval split = lapTime - startTime;
		[splits addObject:[NSNumber numberWithDouble:split]];
		
		// notify the multiStopwatchTableViewController
		//[multiStopwatchTableViewController aWatchLap:self];
	}
	else
	{
		// v1.2 - watches are committed to the database on reset
		//		  instead of on last watch stop
		if (elapsedTime > 0)
		{
			[self addNewEventToDatabase];
		}
		
		// RESET BUTTON
		lapCount = 0;
		elapsedTime = 0;
		startTime = 0;
		stopTime = 0;
		lapTime = 0;
	}	
}

- (void)updateTimeCounts
{
	NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
	currentRunningTime = nowTime - startTime;
	currentLapTime = nowTime - lapTime;
	
	[stopwatchCell updateTimeDisplays];
}

- (void)addNewEventToDatabase
{	
	// create new event - it will add itself to the event database
	Event *event = [[Event alloc] initWithRunnerName:runnerName
										   EventName:eventName
										   EventDateTime:[NSDate timeIntervalSinceReferenceDate] - elapsedTime
									  EventDistance:lapCount * intervalDistance
									 EventFinalTime:elapsedTime
								   EventLapDistance:intervalDistance
									   EventSplitData:splits
										EventType:iEventType
										 KiloSplits:bKiloSplits
										 FurlongMode:bFurlongMode];
	
	[event release];
}

@end
