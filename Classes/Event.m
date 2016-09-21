//
//  Event.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "Event.h"
#import "Utilities.h"
#import "StopwatchAppDelegate.h"

static sqlite3_stmt *select_event_statement = nil;
static sqlite3_stmt *select_split_statement = nil;
static sqlite3_stmt *insert_event_statement = nil;
static sqlite3_stmt *insert_split_statement = nil;
static sqlite3_stmt *delete_event_statement = nil;
static sqlite3_stmt *delete_split_statement = nil;

@implementation Event

@synthesize eventNum;
@synthesize runnerName;
@synthesize eventName;
@synthesize distance;
@synthesize date;
@synthesize finalTime;
@synthesize lapDistance;
@synthesize splitArray;
@synthesize iEventType;
@synthesize bKiloSplits;
@synthesize bFurlongMode;

// this method will instanciate an Event from the database for the given pkNum (EventNum)
- (id)initWithEventNum:(NSInteger)pkNum
{
	if (self = [super init])
	{
		eventNum = pkNum;
		StopwatchAppDelegate *appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
		
		// allocate the split array
		splitArray = [[NSMutableArray alloc] init];
		
		// load the event and split data
		[self loadEventDataFromDatabase];
		[self loadSplitDataFromDatabase];
	}
	
	return self;
}

// this method initializes the event from stopwatch data and adds itself to the event database
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
{	
	if (self = [super init])
	{
		// get the event database
		StopwatchAppDelegate *appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
		
		if (rnrName != nil)
			runnerName = [rnrName copy];
		else
			runnerName = @"";

		if (evtName != nil)
			eventName = [evtName copy];
		else
			eventName = @"";
		
		date = eventDateTime;
		distance = eventDistance;
		finalTime = eventFinalTime;
		lapDistance = eventLapDistance;
		splitArray = [eventSplitData copy];
		iEventType = eventType;
		bKiloSplits = kiloSplits;
		bFurlongMode = furlongMode;
		
		[self addSelfToDatabase];
	}
	
	return self;
}

- (void)dealloc
{
	[runnerName release];
	[eventName release];
	[splitArray release];
	
	[super dealloc];
}

- (void)loadEventDataFromDatabase
{
	// load the rest of the data for this event from the Event table
	if (select_event_statement == nil)
	{
		const char *sql = "SELECT RunnerName, EventName, EventDateTime, EventFinalTime, EventDistance, LapDistance, EventType, KiloSplits, FurlongMode FROM Event WHERE EventNum=?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &select_event_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// for this query we bind the primary key (EventNum) to the first placeholder in the statement (?)
	// note that parameters are numbered from 1
	sqlite3_bind_int(select_event_statement, 1, (int)eventNum);
	
	if (sqlite3_step(select_event_statement) == SQLITE_ROW)
	{
		NSString *dateStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_event_statement, 2)];
		NSNumber *finalTimeNumber = [NSNumber numberWithDouble:sqlite3_column_double(select_event_statement, 3)];
		NSNumber *distanceNumber = [NSNumber numberWithInt:sqlite3_column_double(select_event_statement, 4)];
		NSNumber *lapDistanceNumber = [NSNumber numberWithInt:sqlite3_column_double(select_event_statement, 5)];
		
		self.runnerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_event_statement, 0)];
		self.eventName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_event_statement, 1)];
		self.date = [Utilities timeIntervalWithSQLString:dateStr];
		self.finalTime = (NSTimeInterval)[finalTimeNumber doubleValue];
		self.distance = (NSInteger)[distanceNumber intValue];
		self.lapDistance = (NSInteger)[lapDistanceNumber intValue];
		self.iEventType = sqlite3_column_int(select_event_statement, 6);
		self.bKiloSplits = (sqlite3_column_int(select_event_statement, 7) == 1) ? YES : NO;
		self.bFurlongMode = (sqlite3_column_int(select_event_statement, 8) == 1) ? YES : NO;
	}
	else
	{
		self.runnerName = @"ERROR";
		self.eventName = @"ERROR";
		self.date = 0;
		self.finalTime = 0;
		self.distance = 0;
		self.lapDistance = 0;
		self.iEventType = kMetric;
		self.bKiloSplits = NO;
		self.bFurlongMode = NO;
	}
	
	// reset allows reuse
	sqlite3_reset(select_event_statement);
}

- (void)loadSplitDataFromDatabase
{
	[splitArray removeAllObjects];
	
	// load the splits from the Split table for this event
	if (select_split_statement == nil)
	{
		const char *sql = "SELECT Split FROM Split WHERE EventNum=? ORDER BY SplitSeqNum";
		
		if (sqlite3_prepare_v2(database, sql, -1, &select_split_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// bind the primary key (EventNum) to the placeholder
	sqlite3_bind_int(select_split_statement, 1, (int)eventNum);
	
	// walk the split results and add to our Event
	while (sqlite3_step(select_split_statement) == SQLITE_ROW)
	{
		NSNumber *splitNumber = [NSNumber numberWithDouble:sqlite3_column_double(select_split_statement, 0)];
		
		[self addSplit:(NSTimeInterval)[splitNumber doubleValue]];
	}
	
	// reset allows reuse
	sqlite3_reset(select_split_statement);
}

- (void)addSelfToDatabase
{
	// insert Event record
	if (insert_event_statement == nil)
	{
		static char *sql = "INSERT INTO Event (RunnerName, EventName, EventDateTime, EventFinalTime, EventDistance, LapDistance, EventType, KiloSplits, MetricUnits, FurlongMode) VALUES (?,?,?,?,?,?,?,?,?,?)";
		
		if (sqlite3_prepare_v2(database, sql, -1, &insert_event_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"ERROR: Failed to prepare Event insert statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	NSString *dateTimeStr = [Utilities formatDateTime:self.date format:@"YYYY-MM-dd HH:mm:ss"];
	
	sqlite3_bind_text(insert_event_statement, 1, [self.runnerName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_event_statement, 2, [self.eventName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_event_statement, 3, [dateTimeStr UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(insert_event_statement, 4, finalTime);
	sqlite3_bind_int(insert_event_statement, 5, (int)distance);
	sqlite3_bind_int(insert_event_statement, 6, (int)lapDistance);
	sqlite3_bind_int(insert_event_statement, 7, iEventType);
	sqlite3_bind_int(insert_event_statement, 8, bKiloSplits ? 1 : 0);
	sqlite3_bind_int(insert_event_statement, 9, (iEventType == 0) ? 1 : 0);
	sqlite3_bind_int(insert_event_statement, 10, bFurlongMode ? 1 : 0);
	
	int success = sqlite3_step(insert_event_statement);
	
	sqlite3_reset(insert_event_statement);
	
	if (success != SQLITE_ERROR)
	{
		eventNum = (int)sqlite3_last_insert_rowid(database);
	}
	else
	{
		eventNum = -1;
		NSAssert1(0, @"ERROR: Failed to insert into the Event table with message '%s'.", sqlite3_errmsg(database));
		return;
	}
	
	// insert Split records
	if (insert_split_statement == nil)
	{
		static char *sql = "INSERT INTO Split (EventNum, SplitSeqNum, Split) VALUES (?,?,?)";
		
		if (sqlite3_prepare_v2(database, sql, -1, &insert_split_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"ERROR: Failed to prepare Split insert statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	for (int seqNum=0; seqNum < splitArray.count; seqNum++)
	{
		NSNumber *split = [splitArray objectAtIndex:seqNum];
		
		sqlite3_bind_int(insert_split_statement, 1, (int)eventNum);
		sqlite3_bind_int(insert_split_statement, 2, seqNum + 1);	// splitSeqNum is a 1-based index
		sqlite3_bind_double(insert_split_statement, 3, [split doubleValue]);
		
		success = sqlite3_step(insert_split_statement);
		sqlite3_reset(insert_split_statement);
		
		if (success == SQLITE_ERROR)
		{
			NSAssert1(0, @"ERROR: Failed to insert into the Split table with message '%s'.", sqlite3_errmsg(database));
		}
	}
}

- (void)deleteSelfFromDatabase
{
	// delete Event record
	if (delete_event_statement == nil)
	{
		static char *sql = "DELETE FROM Event WHERE EventNum=?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &delete_event_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"ERROR: Failed to prepare Event insert statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_bind_int(delete_event_statement, 1, (int)self.eventNum);
	
	int success = sqlite3_step(delete_event_statement);
	
	sqlite3_reset(delete_event_statement);
	
	if (success != SQLITE_DONE)
	{
		NSAssert1(0, @"ERROR: Failed to delete event from the Event table with message '%s'.", sqlite3_errmsg(database));
		return;
	}
	
	// delete Split records
	if (delete_split_statement == nil)
	{
		static char *sql = "DELETE FROM Split WHERE EventNum=?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &delete_split_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"ERROR: Failed to prepare Split insert statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_bind_int(delete_split_statement, 1, (int)self.eventNum);
	
	success = sqlite3_step(delete_split_statement);
	
	sqlite3_reset(delete_split_statement);
	
	if (success != SQLITE_DONE)
	{
		NSAssert1(0, @"ERROR: Failed to delete data from the Split table with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void)updateSelfInDatabase
{
	[self deleteSelfFromDatabase];
	[self addSelfToDatabase];
}

// adds a split to the end of the split array
- (void)addSplit:(NSTimeInterval)split
{
	[splitArray addObject:[NSNumber numberWithDouble:split]];
}

// deletes the indexed split from the split array
- (void)deleteSplit:(int)splitIndex
{
	if (splitIndex < [splitArray count])
	{
		[splitArray removeObjectAtIndex:splitIndex];
	}
}

// inserts a split at the logical position in the split array
- (void)insertSplit:(double)split
{		
	[splitArray insertObject:[NSNumber numberWithDouble:split] atIndex:0];
	[splitArray sortUsingSelector:@selector(compare:)];
}

// returns the split value at the index
- (double)getSplit:(int)splitIndex
{
	double split = 0;
	
	if (splitIndex < [splitArray count])
	{
		NSNumber *num = [splitArray objectAtIndex:splitIndex];
		split = [num doubleValue];
	}
	
	return split;
}

// reassign the split at the index with the given value
// also moves the split to the logical position if necessary
- (void)setSplit:(double)split forIndex:(int)splitIndex
{	
	[splitArray insertObject:[NSNumber numberWithDouble:split] atIndex:splitIndex];
	[splitArray removeObjectAtIndex:splitIndex + 1];
	
	[splitArray sortUsingSelector:@selector(compare:)];
}

- (BOOL)split:(double)split isValidForSplitIndex:(int)splitIndex
{
    int splitArrayCount = (int)[splitArray count];
    
    if (splitIndex < 0 || splitIndex >= splitArrayCount)
        return NO;
    
    // check with previous split
    if (splitIndex > 0)
    {
        NSNumber *prevNum = [splitArray objectAtIndex:splitIndex-1];
        double prevSplit = [prevNum doubleValue];
        
        if (split <= prevSplit)
            return NO;
    }
    
    // check with next split
    if (splitIndex < splitArrayCount-1)
    {
        NSNumber *nextNum = [splitArray objectAtIndex:splitIndex+1];
        double nextSplit = [nextNum doubleValue];
        
        if (split >= nextSplit)
            return NO;
    }

    return YES;
}

- (NSMutableArray *)getSplitData
{
	return splitArray;
}

@end
