//
//  Event.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface Event : NSObject
{
	NSInteger eventNum;
	
	NSString *runnerName;
	NSString *eventName;
	NSTimeInterval date;
	NSInteger distance;
	NSTimeInterval finalTime;
	NSInteger lapDistance;
	int iEventType;
	BOOL bKiloSplits;
	BOOL bFurlongMode;
	
	NSMutableArray *splitArray;
	sqlite3 *database;
}

@property NSInteger eventNum;
@property (nonatomic, retain) NSString *runnerName;
@property (nonatomic, retain) NSString *eventName;
@property (nonatomic, retain) NSMutableArray *splitArray;
@property NSTimeInterval date;
@property NSInteger distance;
@property NSTimeInterval finalTime;
@property NSInteger lapDistance;
@property int iEventType;
@property BOOL bKiloSplits;
@property BOOL bFurlongMode;

- (id)initWithEventNum:(NSInteger)pkNum;

- (id)initWithRunnerName:(NSString *)rnrName
			   EventName:(NSString *)evtName
			   EventDateTime:(NSTimeInterval)eventDateTime
		  EventDistance:(NSInteger)eventDistance
		 EventFinalTime:(NSTimeInterval)eventFinalTime
	   EventLapDistance:(NSInteger)eventLapDistance
		   EventSplitData:(NSMutableArray *)eventSplitData
			EventType:(int)eventType
			 KiloSplits:(BOOL)kiloSplits
			 FurlongMode:(BOOL)furlongMode;

- (void)addSelfToDatabase;
- (void)deleteSelfFromDatabase;
- (void)updateSelfInDatabase;
- (void)loadEventDataFromDatabase;
- (void)loadSplitDataFromDatabase;

- (void)addSplit:(NSTimeInterval)split;
- (void)deleteSplit:(int)splitIndex;
- (void)insertSplit:(double)split;
- (double)getSplit:(int)splitIndex;
- (void)setSplit:(double)split forIndex:(int)splitIndex;
- (BOOL)split:(double)split isValidForSplitIndex:(int)splitIndex;
- (NSArray *)getSplitData;

@end