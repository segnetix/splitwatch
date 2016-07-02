//
//  Utilities.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/4/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

/*
+ (NSString *)getSplitViewHeaderText:(NSInteger)lapDistance
						 Units:(int)units
						  KiloSplits:(BOOL)kiloSplits
				  FurlongDisplayMode:(BOOL)furlongDisplayMode
{
	NSString *splitViewHeaderText = @"";
	
	if (units == kMetric)
	{
		if (kiloSplits)
		{
			switch (lapDistance) {
				case  25:	splitViewHeaderText = @"    Lap      Time        25         50        100       200";	break;
				case  50:	splitViewHeaderText = @"    Lap      Time        50       100        200       400";	break;
				case 100:	splitViewHeaderText = @"    Lap      Time      100       200       400       800";	break;
				case 200:	splitViewHeaderText = @"    Lap      Time      200       400       800      1000";	break;
				case 400:	splitViewHeaderText = @"    Lap      Time      400       800     1000      1600";	break;
				default:	break;
			}
		}
		else
		{
			switch (lapDistance) {
				case  25:	splitViewHeaderText = @"    Lap      Time        25         50        100       200";	break;
				case  50:	splitViewHeaderText = @"    Lap      Time        50       100        200       400";	break;
				case 100:	splitViewHeaderText = @"    Lap      Time      100       200       400       800";	break;
				case 200:	splitViewHeaderText = @"    Lap      Time      200       400       800      1600";	break;
				case 400:	splitViewHeaderText = @"    Lap      Time      400       800     1600      3200";	break;
				default:	break;
			}
		}
	}
	else if (units == kEnglish)
	{
		if (furlongDisplayMode && (lapDistance == 220 || lapDistance == 440))
		{
			switch (lapDistance) {
				case 220: splitViewHeaderText		= @"    Lap      Time       1/8       1/4       1/2     Mile";	break;
				case 440: splitViewHeaderText		= @"    Lap      Time       1/4       1/2       Mile    2-M";	break;
			}
		}
		else
		{
			switch (lapDistance) {
				case  25:	splitViewHeaderText		= @"    Lap      Time        25         50        100       200";	break;
				case  50:	splitViewHeaderText		= @"    Lap      Time        50       100        200       400";	break;
				case 110:	splitViewHeaderText		= @"    Lap      Time      110       220       440       880";	break;
				case 220:	splitViewHeaderText		= @"    Lap      Time      220      440       880      Mile";	break;
				case 440:	splitViewHeaderText		= @"    Lap      Time      440      880      Mile    2-Mile";	break;
				default:	break;
			}		
		}
	}
	else if (units == kLap)
	{
		splitViewHeaderText		= @"    Split    Time      Interval";
	}
	
	return splitViewHeaderText;
}
*/

+ (NSMutableArray *)getSplitViewHeaderArray:(NSInteger)lapDistance
                               Units:(int)units
                          KiloSplits:(BOOL)kiloSplits
                  FurlongDisplayMode:(BOOL)furlongDisplayMode
{
    NSMutableArray *splitHeaderArray = [[[NSMutableArray alloc] init] autorelease];
    
    if (units == kMetric)
    {
        [splitHeaderArray addObjectsFromArray: @[@"Lap", @"Time"]];
        
        if (kiloSplits)
        {
            switch (lapDistance) {
                case  25:	[splitHeaderArray addObjectsFromArray: @[ @"25",  @"50",  @"100",  @"200"]];	break;
                case  50:	[splitHeaderArray addObjectsFromArray: @[ @"50", @"100",  @"200",  @"400"]];	break;
                case 100:	[splitHeaderArray addObjectsFromArray: @[@"100", @"200",  @"400",  @"800"]];	break;
                case 200:	[splitHeaderArray addObjectsFromArray: @[@"200", @"400",  @"800", @"1000"]];	break;
                case 400:	[splitHeaderArray addObjectsFromArray: @[@"400", @"800", @"1000", @"1600"]];	break;
                default:	break;
            }
        }
        else
        {
            switch (lapDistance) {
                case  25:	[splitHeaderArray addObjectsFromArray: @[ @"25",  @"50",  @"100",  @"200"]];	break;
                case  50:	[splitHeaderArray addObjectsFromArray: @[ @"50", @"100",  @"200",  @"400"]];	break;
                case 100:	[splitHeaderArray addObjectsFromArray: @[@"100", @"200",  @"400",  @"800"]];	break;
                case 200:	[splitHeaderArray addObjectsFromArray: @[@"200", @"400",  @"800", @"1600"]];	break;
                case 400:	[splitHeaderArray addObjectsFromArray: @[@"400", @"800", @"1600", @"3200"]];	break;
                default:	break;
            }
        }
    }
    else if (units == kEnglish)
    {
        [splitHeaderArray addObjectsFromArray: @[@"Lap", @"Time"]];
        
        if (furlongDisplayMode && (lapDistance == 220 || lapDistance == 440))
        {
            switch (lapDistance) {
                case 220: [splitHeaderArray addObjectsFromArray: @[ @"1/8",  @"1/4",   @"1/2",     @"Mile"]];	break;
                case 440: [splitHeaderArray addObjectsFromArray: @[ @"1/4",  @"1/2",  @"Mile",   @"2-Mile"]];	break;
            }
        }
        else
        {
            switch (lapDistance) {
                case  25:	[splitHeaderArray addObjectsFromArray: @[ @"25",  @"50",   @"100",     @"200"]];	break;
                case  50:	[splitHeaderArray addObjectsFromArray: @[ @"50", @"100",   @"200",     @"400"]];	break;
                case 110:	[splitHeaderArray addObjectsFromArray: @[@"110", @"220",   @"440",     @"880"]];	break;
                case 220:	[splitHeaderArray addObjectsFromArray: @[@"220", @"440",   @"880",    @"Mile"]];	break;
                case 440:	[splitHeaderArray addObjectsFromArray: @[@"440", @"880",  @"Mile",  @"2-Mile"]];	break;
                default:	break;
            }		
        }
    }
    else if (units == kLap)
    {
        [splitHeaderArray addObjectsFromArray: @[ @"Split",  @"Time",   @"Interval"]];
    }
    
    return splitHeaderArray;
}

+ (NSString *)formatTime:(NSTimeInterval)timeInterval minDigits:(int)minDigits precision:(int)precision
{
	int minutes = (int)(timeInterval / 60) % 60;
	int seconds = (int)timeInterval % 60;
	int miliseconds = (timeInterval - (seconds + (minutes * 60))) * 1000;
	int hundredths = (miliseconds + 5) / 10;
	int tenths = (hundredths + 5) / 10;
	
	if (precision == 1)
	{
		if (tenths >= 10)
		{
			tenths = 0;
			seconds++;
			
			
			if (seconds >= 60)
			{
				seconds = 0;
				minutes++;
			}
		}
	}
	else
	{
		if (hundredths >= 100)
		{
			hundredths = 0;
			seconds++;
			
			if (seconds >= 60)
			{
				seconds = 0;
				minutes++;
			}
		}
	}

	NSString *fraction =
		(precision == 1) ? [NSString stringWithFormat:@"%.1u", tenths] :
						   [NSString stringWithFormat:@"%.2u", hundredths];
	
	if (minDigits == 1)
		return [NSString stringWithFormat:@"%.1u:%.2u.%@", minutes, seconds, fraction];
	else
		return [NSString stringWithFormat:@"%.2u:%.2u.%@", minutes, seconds, fraction];
}

+ (NSString *)shortFormatTime:(NSTimeInterval)timeInterval precision:(int)precision
{
	int hours = (int)(timeInterval / 3600);
	int minutes = (int)(timeInterval / 60) % 60;
	int seconds = (int)timeInterval % 60;
	int miliseconds = (timeInterval - (seconds + (minutes * 60) + (hours * 3600))) * 1000;
	int hundredths = (miliseconds + 5) / 10;
	int tenths = (hundredths + 5) / 10;
	
	if (precision == 0)
	{
		return [NSString stringWithFormat:@"%u:%.2u:%.2u", hours, minutes, seconds];
	}
	
	if (precision == 1)
	{
		if (tenths >= 10)
		{
			tenths = 0;
			seconds++;
			
			// since we rounded up the seconds, bump the timeInterval
			// so we get the correct string formatting below
			timeInterval += 1.0;
			
			if (seconds >= 60)
			{
				seconds = 0;
				minutes++;
			}
		}
	}
	else
	{
		if (hundredths >= 100)
		{
			hundredths = 0;
			seconds++;
			
			if (seconds >= 60)
			{
				seconds = 0;
				minutes++;
			}
		}
	}
	
	NSString *fraction =
		(precision == 1) ? [NSString stringWithFormat:@"%.1u", tenths] :
						   [NSString stringWithFormat:@"%.2u", hundredths];
	
	NSString *returnTime = @"";
	
	if (timeInterval < 60)
	{
		returnTime = [NSString stringWithFormat:@"%u.%@", seconds, fraction];
	}
	else if (timeInterval < 3600)
	{
		returnTime = [NSString stringWithFormat:@"%u:%.2u.%@", minutes, seconds, fraction];
	}
	else if (timeInterval < 360000)
	{
		returnTime = [NSString stringWithFormat:@"%u:%.2u:%.2u.%@", hours, minutes, seconds, fraction];
	}
	else
	{
		returnTime = @"99:59:59.99";
	}
		
	return returnTime;
}

+ (NSString *)formatTimeWithHours:(NSTimeInterval)timeInterval
{
	int hours = (int)(timeInterval / 3600);
	int minutes = (int)(timeInterval / 60) % 60;
	int seconds = (int)timeInterval % 60;
	int miliseconds = (timeInterval - (seconds + (minutes * 60) + (hours * 3600))) * 1000;
	int hundredths = (miliseconds + 5) / 10;
	
	if (hundredths >= 100)
	{
		hundredths = 0;
		seconds++;
		
		if (seconds >= 60)
		{
			seconds = 0;
			minutes++;
			
			if (minutes >= 60)
			{
				minutes = 0;
				hours++;
			}
		}
	}
	
	return [NSString stringWithFormat:@" %.1u:%.2u:%.2u.%.2u", hours, minutes, seconds, hundredths];
}

+ (NSString *)formatLap:(NSInteger)lapCount;
{
	return [NSString stringWithFormat:@"%.2ld", (long)lapCount];
}

+ (NSString *)formatDistance:(NSInteger)distance
{
	NSMutableString *distStr = [NSMutableString stringWithString:@""];
	
	if (distance < 10000)
		[distStr appendString:@" "];
	if (distance < 1000)
		[distStr appendString:@" "];
	if (distance < 100)
		[distStr appendString:@" "];
	[distStr appendFormat:@"%ld", (long)distance];
	
	return distStr;
}

+ (NSString *)formatDate:(NSTimeInterval)dateTimeInterval
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:dateTimeInterval];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:usLocale];
	
	NSString *timeString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[usLocale release];
	
	return timeString;
}

+ (NSString *)formatDateTime:(NSTimeInterval)dateTimeInterval format:(NSString *)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:dateTimeInterval];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:usLocale];
	
	NSString *timeString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[usLocale release];
	
	return timeString;
}

#pragma mark -
#pragma mark Date and Time utilities

+ (NSString *)sqlStringWithIimeInterval:(NSTimeInterval)timeInterval
{
	NSInteger seconds = (int)timeInterval;
	seconds /= 36;
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.formatWidth = 5;
	formatter.paddingCharacter = @"0";
	formatter.paddingPosition = NSNumberFormatterPadAfterPrefix;
	NSString *offset = [formatter stringFromNumber:[NSNumber numberWithInteger:seconds]];
	[formatter release];
	return offset;
}

+ (NSTimeInterval)timeIntervalWithSQLString:(NSString *)string
{
    // pre v2.0 code
	//NSDate *date = [NSDate dateWithNaturalLanguageString:string];
   
    // v2.0 replacement for dateWithNaturalLanguageString (1/26/2015)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:string];
    [dateFormatter release];
    
    if (!date) return 0;
    
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *components = [calendar components:(
                                                         NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitHour |
                                                         NSCalendarUnitMinute |
                                                         NSCalendarUnitSecond)
                                               fromDate:date];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    date = [calendar dateFromComponents:components];
    return [date timeIntervalSinceReferenceDate];
}

// v1.2 changes - added Lap mode with ShowSplitTag
//				  added special handling for 25 and 50 yard split distances
//				  added Furlong mode string handling
+ (NSString *)stringFromDistance:(NSInteger)distance Units:(int)units ShowMiles:(BOOL)showMiles ShowSplitTag:(BOOL)showSplitTag Interval:(int)interval FurlongDisplayMode:(BOOL)furlongDisplayMode
{
	NSString *distanceString = @"";
	
	if (units == kMetric)
		distanceString = [NSString stringWithFormat:@"%ldm", (long)distance];
	else if (units == kEnglish && (interval == 25 || interval == 50))
		distanceString = [NSString stringWithFormat:@"%ldy", (long)distance];
	else if (units == kEnglish && (interval == 220 || interval == 440) && furlongDisplayMode)
	{
		// v1.2 - Furlong mode - generalized for any distance
		int mileUnit = (int)distance / 1760;
		int fractionUnit = distance % 1760;
		NSString *fractionStr = @"";
		
		switch (fractionUnit)
		{
			case    0:	fractionStr	= @"";		break;
			case  220:	fractionStr = @"1/8";	break;
			case  440:	fractionStr = @"1/4";	break;
			case  660:	fractionStr = @"3/8";	break;
			case  880:	fractionStr = @"1/2";	break;
			case 1100:	fractionStr = @"5/8";	break;
			case 1320:	fractionStr = @"3/4";	break;
			case 1540:	fractionStr = @"7/8";	break;
			default:	fractionStr = @"";		break;
		}
		
		if (distance < 1760)
		{
			distanceString = [NSString stringWithFormat:@"%@", fractionStr];
		}
		else if (fractionUnit == 0)
			distanceString = [NSString stringWithFormat:@"%u-M", mileUnit];
		else
			distanceString = [NSString stringWithFormat:@"%u-%@", mileUnit, fractionStr];
	}
	else if (units == kEnglish)
	{
		// English
		int mileUnit = (int)distance / 1760;
		int fractionUnit = distance % 1760;
		
		if (fractionUnit == 0)
		{
			if (mileUnit > 1)
				distanceString = [NSString stringWithFormat:@"%u-Mile", mileUnit];
			else
				distanceString = [NSString stringWithFormat:@"%u-Mile", mileUnit];
		}
		else
		{
			distanceString = [NSString stringWithFormat:@"%ldy", (long)distance];
			
			/*
			if (showMiles && mileUnit > 0)
			{
				if (mileUnit > 1)
					distanceString = [NSString stringWithFormat:@"%uM %uy", mileUnit, fractionUnit];
				else
					distanceString = [NSString stringWithFormat:@"%uM %uy", mileUnit, fractionUnit];
			}
			else
				distanceString = [NSString stringWithFormat:@"%uy", distance];
			*/
		}
	}
	else if (units == kLap)
	{
		if (showSplitTag)
		{
			if (distance == 1)
				distanceString = @"1 split";
			else
				distanceString = [NSString stringWithFormat:@"%ld splits", (long)distance];
		}
		else
		{
			distanceString = [NSString stringWithFormat:@"%ld", (long)distance];
		}
	}
	
	return distanceString;
}

// v1.2 - Avg, Min, Max helper methods
// v2.0 - added Avg, Min, Max calcs for all columns
+ (NSString *)avgSplit:(NSMutableArray *)splits forColumn:(NSInteger)column
{
	NSString *avgStr = @"";
   
    double totalTime = [[splits lastObject] doubleValue];
    double avgSplit = totalTime / [splits count] * column;
    
    if (avgSplit < 3600)
        avgStr = [Utilities shortFormatTime:avgSplit precision:1];
    else if (avgSplit < 36000)
        avgStr = [Utilities shortFormatTime:avgSplit precision:1];
    else
        avgStr = [Utilities shortFormatTime:avgSplit precision:0];
    
	return avgStr;
}

+ (NSString *)minSplit:(NSMutableArray *)splits forColumn:(NSInteger)column
{
	NSString *minStr = @"";
 
    double minSplit = 99999999;
    
    for (long x = column - 1; x < [splits count]; x++)
    {
        NSNumber *nSplit = [splits objectAtIndex:x];
        NSTimeInterval split = [nSplit doubleValue];
        
        // interval time
        NSTimeInterval intervaltime = split;
        
        if (x > column - 1)
        {
            NSNumber *nPrevSplit = [splits objectAtIndex:x - column];
            intervaltime = split - [nPrevSplit doubleValue];
        }
        
        if (intervaltime < minSplit)
            minSplit = intervaltime;
    }
    
    if (minSplit < 99999999)
    {
        if (minSplit < 3600)
            minStr = [Utilities shortFormatTime:minSplit precision:1];
        else if (minSplit < 36000)
            minStr = [Utilities shortFormatTime:minSplit precision:1];
        else
            minStr = [Utilities shortFormatTime:minSplit precision:0];
    }
    
	return minStr;
}

+ (NSString *)maxSplit:(NSMutableArray *)splits forColumn:(NSInteger)column
{
	NSString *maxStr = @"";
	
    double maxSplit = 0;
    
    for (long x = column - 1; x < [splits count]; x++)
    {
        NSNumber *nSplit = [splits objectAtIndex:x];
        NSTimeInterval split = [nSplit doubleValue];
        
        // interval time
        NSTimeInterval intervaltime = split;
        
        if (x > column - 1)
        {
            NSNumber *nPrevSplit = [splits objectAtIndex:x - column];
            intervaltime = split - [nPrevSplit doubleValue];
        }
        
        if (intervaltime > maxSplit)
            maxSplit = intervaltime;
    }
    
    if (maxSplit > 0)
    {
        if (maxSplit < 3600)
            maxStr = [Utilities shortFormatTime:maxSplit precision:1];
        else if (maxSplit < 36000)
            maxStr = [Utilities shortFormatTime:maxSplit precision:1];
        else
            maxStr = [Utilities shortFormatTime:maxSplit precision:0];
    }
    
	return maxStr;
}

+ (int)getHrs:(double)split
{
	int hrs = 0;
	
	if (split > 3600)
	{
		hrs = (int)(split / 3600);
	}
	
	return hrs;
}

+ (int)getMin:(double)split
{
	int min = 0;
	
	if (split > 60)
	{
		min = (int)(split / 60) % 60;
	}
	
	return min;
}

+ (int)getSec:(double)split
{
    int hours = (int)(split / 3600);
    int minutes = (int)(split / 60) % 60;
    int seconds = (int)split % 60;
    int miliseconds = (split - (seconds + (minutes * 60) + (hours * 3600))) * 1000;
    int hundredths = (miliseconds + 5) / 10;
    //int tenths = (hundredths + 5) / 10;
    
    if (hundredths >= 100)
    {
        //hundredths = 0;
        seconds++;
        
        if (seconds >= 60)
        {
            seconds = 0;
            minutes++;
        }
    }

    return seconds;
}

+ (int)getHundredths:(double)split
{
	int hours = (int)(split / 3600);
	int minutes = (int)(split / 60) % 60;
	int seconds = (int)split % 60;
	int miliseconds = (split - (seconds + (minutes * 60) + (hours * 3600))) * 1000;
	int hundredths = (miliseconds + 5) / 10;
	//int tenths = (hundredths + 5) / 10;
	
    if (hundredths >= 100)
        hundredths = 0;
    
	return hundredths;
}

/*
+ (NSString *)lapTextForRow:(NSInteger)row
             forDisplayMode:(NSInteger)mode
            withSplitsCount:(int)splitsCount
           intervalDistance:(int)intervalDistance
                      units:(int)units
                furlongMode:(BOOL)furlongMode
{
    NSString *lapText = @"";
    
    if (splitsCount > 0)
    {
        if (mode == kDisplayMode_Normal)
        {
            int totalDistance = (int)((row + 1) * intervalDistance);
            
            lapText = [Utilities stringFromDistance:totalDistance
                                              Units:units
                                          ShowMiles:NO
                                       ShowSplitTag:NO
                                           Interval:(int)intervalDistance
                                 FurlongDisplayMode:furlongMode];
        }
        else if (mode == kDisplayMode_Space)
        {
            lapText = @"";
        }
        else if (mode == kDisplayMode_Last_Header)			// v1.2
        {
            lapText = @"Last:";
        }
        else if (mode == kDisplayMode_Last_Split)			// v1.2
        {
            lapText = @"";
        }
        else if (mode == kDisplayMode_Avg_Split)			// v1.2
        {
            lapText = @"Avg:";
        }
        else if (mode == kDisplayMode_Min_Split)			// v1.2
        {
            lapText = @"Min:";
        }
        else if (mode == kDisplayMode_Max_Split)			// v1.2
        {
            lapText = @"Max:";
        }
    }
    
    return lapText;
}
*/

/*
+ (NSString *)timeTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode
{
    NSString *cellText = @"";
    
    if (splits.count > 0)
    {
        if (mode == kDisplayMode_Normal)
        {
            // lap time
            NSNumber *nSplit = [splits objectAtIndex:row];
            NSTimeInterval split = [nSplit doubleValue];
            
            // if split > 1 hour, drop precision to 1
            // if split > 10 hours, drop precision to 0 (no fractional seconds)
            if (split < 3600)
                cellText = [Utilities shortFormatTime:split precision:2];
            else if (split < 36000)
                cellText = [Utilities shortFormatTime:split precision:1];
            else
                cellText = [Utilities shortFormatTime:split precision:0];
        }
        else if (mode == kDisplayMode_Space)
        {
            cellText = @"";
        }
        else if (mode == kDisplayMode_Last_Header)			// v1.2
        {
            cellText = [Utilities stringFromDistance:intervalDistance
                                               Units:iUnits
                                           ShowMiles:NO
                                        ShowSplitTag:NO
                                            Interval:(int)intervalDistance
                                  FurlongDisplayMode:bFurlongMode];
        }
        else if (mode == kDisplayMode_Last_Split)			// v1.2
        {
            cellText = [self lastSplitTextForColumn:0];
        }
        else if (mode == kDisplayMode_Avg_Split)			// v1.2
        {
            cellText = [Utilities avgSplit:splits forColumn:1];
        }
        else if (mode == kDisplayMode_Min_Split)			// v1.2
        {
            cellText = [Utilities minSplit:splits forColumn:1];
        }
        else if (mode == kDisplayMode_Max_Split)			// v1.2
        {
            cellText = [Utilities maxSplit:splits forColumn:1];
        }
    }
    
    return cellText;
}
*/

#pragma mark -
#pragma mark Cell Text Methods

+ (NSString *)lapTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode forSplits:(NSMutableArray*)splits forIntervalDistance:(NSInteger)intervalDistance forUnits:(int)iUnits forFurlongMode:(BOOL)bFurlongMode
{
    NSString *lapText = @"";
    
    if (splits.count > 0)
    {
        if (mode == kDisplayMode_Normal)
        {
            int totalDistance = (int)((row + 1) * intervalDistance);
            
            lapText = [Utilities stringFromDistance:totalDistance
                                              Units:iUnits
                                          ShowMiles:NO
                                       ShowSplitTag:NO
                                           Interval:(int)intervalDistance
                                 FurlongDisplayMode:bFurlongMode];
        }
        else if (mode == kDisplayMode_Space)
        {
            lapText = @"";
        }
        else if (mode == kDisplayMode_Last_Header)			// v1.2
        {
            lapText = @"Last:";
        }
        else if (mode == kDisplayMode_Last_Split)			// v1.2
        {
            lapText = @"";
        }
        else if (mode == kDisplayMode_Avg_Split)			// v1.2
        {
            lapText = @"Avg:";
        }
        else if (mode == kDisplayMode_Min_Split)			// v1.2
        {
            lapText = @"Min:";
        }
        else if (mode == kDisplayMode_Max_Split)			// v1.2
        {
            lapText = @"Max:";
        }
    }
    
    return lapText;
}

+ (NSString *)timeTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode forSplits:(NSMutableArray*)splits forIntervalDistance:(NSInteger)intervalDistance forUnits:(int)iUnits forFurlongMode:(BOOL)bFurlongMode
{
    NSString *cellText = @"";
    
    if (splits.count > 0)
    {
        if (mode == kDisplayMode_Normal)
        {
            // lap time
            NSNumber *nSplit = [splits objectAtIndex:row];
            NSTimeInterval split = [nSplit doubleValue];
            
            // if split > 1 hour, drop precision to 1
            // if split > 10 hours, drop precision to 0 (no fractional seconds)
            if (split < 3600)
                cellText = [Utilities shortFormatTime:split precision:2];
            else if (split < 36000)
                cellText = [Utilities shortFormatTime:split precision:1];
            else
                cellText = [Utilities shortFormatTime:split precision:0];
        }
        else if (mode == kDisplayMode_Space /*&& iUnits < kLap*/)
        {
            cellText = @"";
        }
        else if (mode == kDisplayMode_Last_Header /*&& iUnits < kLap*/)			// v1.2
        {
            cellText = [Utilities stringFromDistance:intervalDistance
                                               Units:iUnits
                                           ShowMiles:NO
                                        ShowSplitTag:NO
                                            Interval:(int)intervalDistance
                                  FurlongDisplayMode:bFurlongMode];
        }
        else if (mode == kDisplayMode_Last_Split /*&& iUnits < kLap*/)			// v1.2
        {
            cellText = [self lastSplitTextForColumn:0 forSplits:splits];
        }
        else if (mode == kDisplayMode_Avg_Split /*&& iUnits < kLap*/)			// v1.2
        {
            cellText = [Utilities avgSplit:splits forColumn:1];
        }
        else if (mode == kDisplayMode_Min_Split /*&& iUnits < kLap*/)			// v1.2
        {
            cellText = [Utilities minSplit:splits forColumn:1];
        }
        else if (mode == kDisplayMode_Max_Split /*&& iUnits < kLap*/)			// v1.2
        {
            cellText = [Utilities maxSplit:splits forColumn:1];
        }
    }
    
    return cellText;
}

+ (NSString *)splitTextForRow:(NSInteger)row Column:(NSInteger)column forDisplayMode:(NSInteger)mode forSplits:(NSMutableArray*)splits forIntervalDistance:(NSInteger)intervalDistance forUnits:(int)iUnits forFurlongMode:(BOOL)bFurlongMode forKiloSplits:(BOOL)bKiloSplits
{
    NSString *cellText = @"";
    NSInteger modValue;
    
    switch (column)
    {
        case 1: modValue = 1; break;
        case 2: modValue = 2; break;
        case 3: modValue = 4; break;
        case 4: modValue = (bKiloSplits) ? 5 : 8; break;
        default: modValue = 99; break;
    }
    
    if (splits.count > 0)
    {
        if (mode == kDisplayMode_Normal)
        {
            if (iUnits == kLap && column >= 2)
            {
                return cellText;
            }
            
            // lap count
            int lapCount = (int)(row + 1);
            
            if (lapCount % modValue == 0)
            {
                // lap time
                NSNumber *nSplit = [splits objectAtIndex:row];
                NSTimeInterval split = [nSplit doubleValue];
                
                // interval time
                NSTimeInterval intervaltime = split;
                
                if (lapCount > modValue)
                {
                    NSNumber *nPrevSplit = [splits objectAtIndex:row - modValue];
                    intervaltime = split - [nPrevSplit doubleValue];
                }
                
                // if split > 1 hour, drop precision to 1
                // if split > 10 hours, drop precision to 0 (no fractional seconds)
                if (intervaltime < 3600)
                    cellText = [Utilities shortFormatTime:intervaltime precision:1];
                else if (intervaltime < 36000)
                    cellText = [Utilities shortFormatTime:intervaltime precision:1];
                else
                    cellText = [Utilities shortFormatTime:intervaltime precision:0];
            }
        }
        else if (mode == kDisplayMode_Space)
        {
            cellText = @"";
        }
        else if (mode == kDisplayMode_Last_Header)
        {
            if (column < splits.count)
                cellText = [Utilities stringFromDistance:((column + 1) * intervalDistance)
                                                   Units:iUnits
                                               ShowMiles:NO
                                            ShowSplitTag:NO
                                                Interval:(int)intervalDistance
                                      FurlongDisplayMode:bFurlongMode];
        }
        else if (mode == kDisplayMode_Last_Split)
        {
            cellText = [self lastSplitTextForColumn:column forSplits:splits];
        }
        else if (mode == kDisplayMode_Avg_Split && splits.count - 1 > column)
        {
            cellText = [Utilities avgSplit:splits forColumn:column + 1];
        }
        else if (mode == kDisplayMode_Max_Split && splits.count - 1 > column)
        {
            cellText = [Utilities maxSplit:splits forColumn:column + 1];
        }
        else if (mode == kDisplayMode_Min_Split && splits.count - 1 > column)
        {
            cellText = [Utilities minSplit:splits forColumn:column + 1];
        }
        else
        {
            cellText = @"";
        }
    }
    
    return cellText;
}

+ (NSString *)lastSplitTextForColumn:(NSInteger)column forSplits:(NSMutableArray*)splits
{
    NSString *cellText = @"";
    
    if (splits.count > column)
    {
        // bump column as we start with last split column 2 (last split 1 is handled in timeTextForRow:)
        column++;
        
        int lastSplitIndex = (int)(splits.count - 1);
        
        // final time
        NSNumber *lastSplit = [splits lastObject];
        NSTimeInterval finalTime = [lastSplit doubleValue];
        
        // interval time
        NSTimeInterval intervaltime = 0;
        
        if (column == splits.count)
        {
            intervaltime = finalTime;
        }
        else
        {
            NSNumber *prevSplit = [splits objectAtIndex:lastSplitIndex - column];
            intervaltime = finalTime - [prevSplit doubleValue];
        }
        
        // if split > 1 hour, drop precision to 1
        // if split > 10 hours, drop precision to 0 (no fractional seconds)
        if (intervaltime < 3600)
            cellText = [Utilities shortFormatTime:intervaltime precision:1];
        else if (intervaltime < 36000)
            cellText = [Utilities shortFormatTime:intervaltime precision:1];
        else
            cellText = [Utilities shortFormatTime:intervaltime precision:0];
    }
    
    return cellText;
}

+ (NSString *)splitHTMLTextForRow:(NSInteger)row forSplits:(NSMutableArray*)splits forIntervalDistance:(NSInteger)intervalDistance forUnits:(int)iUnits forFurlongMode:(BOOL)bFurlongMode forKiloSplits:(BOOL)bKiloSplits
{
    NSMutableString *splitRowText = [NSMutableString stringWithString:@""];
    
    if (splits.count > 0)
    {
        [splitRowText appendString:@"<tr class='splitData' align='right'>"];
        [splitRowText appendFormat:@"<td>%@</td>", [self lapTextForRow:row forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode]];
        [splitRowText appendFormat:@"<td>%@</td>", [self timeTextForRow:row forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode]];
        [splitRowText appendFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 1 forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits]];
        [splitRowText appendFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 2 forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits]];
        [splitRowText appendFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 3 forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits]];
        [splitRowText appendFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 4 forDisplayMode:kDisplayMode_Normal forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits]];
        [splitRowText appendString:@"</tr>"];
    }
    
    return splitRowText;
}

// v1.2 - added rowCount and handling for lap mode and furlong mode
+ (NSString *)lastSplitHeaderHTMLText:(int)rowCount forSplits:(NSMutableArray*)splits forUnits:(int)iUnits forIntervalDistance:(NSInteger)intervalDistance forFurlongMode:(BOOL)bFurlongMode
{
    //if (iUnits == kLap)
    //	return @"";
    
    NSMutableString *lastSplitHeaderText = [NSMutableString stringWithString:@"<tr><td> </td></tr><tr class='lastSplitDataHeader' style='font-weight:bold;' align='right'>"];
    
    if (rowCount > 1)
        [lastSplitHeaderText appendString:@"<td>Last:</td>"];
    else
        [lastSplitHeaderText appendString:@"<td> </td>"];
    
    // rolled up split header
    if (iUnits == kMetric)
    {
        if (rowCount == 2)
        {
            switch (intervalDistance) {
                case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td>",  25,  50]; break;
                case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td>",  50, 100]; break;
                case 100:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td>", 100, 200]; break;
                case 200:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td>", 200, 400]; break;
                case 400:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td>", 400, 800]; break;
                default:	break;
            }
        }
        else if (rowCount == 3)
        {
            switch (intervalDistance) {
                case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75]; break;
                case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150]; break;
                case 100:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300]; break;
                case 200:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600]; break;
                case 400:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200]; break;
                default:	break;
            }
        }
        else if (rowCount == 4)
        {
            switch (intervalDistance) {
                case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75,  100]; break;
                case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150,  200]; break;
                case 100:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300,  400]; break;
                case 200:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600,  800]; break;
                case 400:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200, 1600]; break;
                default:	break;
            }
        }
        else
        {
            switch (intervalDistance) {
                case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75,  100,  125]; break;
                case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150,  200,  250]; break;
                case 100:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300,  400,  500]; break;
                case 200:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600,  800, 1000]; break;
                case 400:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200, 1600, 2000]; break;
                default:	break;
            }
        }
    }
    else if (iUnits == kEnglish)
    {
        if (bFurlongMode && (intervalDistance == 220 || intervalDistance == 440))
        {
            if (intervalDistance == 220)
            {
                if (rowCount == 3)
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8"];
                else if (rowCount == 4)
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8", @"1/2"];
                else
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8", @"1/2", @"5/8"];
            }
            else
            {
                if (rowCount == 3)
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4"];
                else if (rowCount == 4)
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4", @"Mile"];
                else
                    [lastSplitHeaderText appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4", @"Mile", @"1-1/4"];
            }
        }
        else
        {
            if (rowCount == 3)
            {
                switch (intervalDistance) {
                    case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75]; break;
                    case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150]; break;
                    case 110:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330]; break;
                    case 220:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660]; break;
                    case 440:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 440, 880, 1320]; break;
                    default:	break;
                }
            }
            else if (rowCount == 4)
            {
                switch (intervalDistance) {
                    case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75, 100]; break;
                    case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150, 200]; break;
                    case 110:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330, 440]; break;
                    case 220:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660, 880]; break;
                    case 440:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td>", 440, 880, 1320, @"Mile"]; break;
                    default:	break;
                }
            }
            else
            {
                switch (intervalDistance) {
                    case  25:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75, 100,  125]; break;
                    case  50:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150, 200,  250]; break;
                    case 110:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330, 440,  550]; break;
                    case 220:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660, 880, 1100]; break;
                    case 440:	[lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td><td>%@</td>", 440, 880, 1320, @"Mile", @"Mile-1/4"]; break;
                    default:	break;
                }
            }
        }
    }
    else if (iUnits == kLap)
    {
        if (rowCount == 3) {
            [lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3];
        }
        else if (rowCount == 4) {
            [lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3, 4];
        }
        else {
            [lastSplitHeaderText appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3, 4, 5];
        }
    }
    
    [lastSplitHeaderText appendString:@"</tr>"];
    
    return lastSplitHeaderText;
}

+ (NSString *)lastSplitHTMLText:(NSMutableArray*)splits
{
    //if (iUnits == kLap)
    //	return @"";
    
    NSMutableString *lastSplitRowText = [NSMutableString stringWithString:@"<tr class='lastSplitData' align='right'>"];
    
    if (splits.count > 0)
    {
        [lastSplitRowText appendString:@"<td></td>"];
        [lastSplitRowText appendFormat:@"<td>%@</td>", [Utilities lastSplitTextForColumn: 0 forSplits:splits]];
        [lastSplitRowText appendFormat:@"<td>%@</td>", [Utilities lastSplitTextForColumn: 1 forSplits:splits]];
        [lastSplitRowText appendFormat:@"<td>%@</td>", [Utilities lastSplitTextForColumn: 2 forSplits:splits]];
        [lastSplitRowText appendFormat:@"<td>%@</td>", [Utilities lastSplitTextForColumn: 3 forSplits:splits]];
        [lastSplitRowText appendFormat:@"<td>%@</td>", [Utilities lastSplitTextForColumn: 4 forSplits:splits]];
        [lastSplitRowText appendString:@"</tr>"];
    }
    
    return lastSplitRowText;
}

+ (NSString *)getSplitHTMLDataString:(NSMutableArray*)splits forIntervalDistance:(NSInteger)intervalDistance forUnits:(int)iUnits forKiloSplits:(BOOL)bKiloSplits forFurlongMode:(BOOL)bFurlongMode
{
    NSMutableString *splitDataStr = [NSMutableString stringWithString:@""];
    
    [splitDataStr appendString:@"<table id='splitData' cellpadding='5'>"];
    [splitDataStr appendString:@"<tr id='headers' style='font-weight:bold;' align='center'>"];
    [splitDataStr appendString:@"<td align='right'>Split</td><td>Time</td>"];
    
    // rolled up split header
    if (iUnits == kMetric)
    {
        if (bKiloSplits)
        {
            switch (intervalDistance) {
                case  25:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,  100,  200]; break;
                case  50:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  200,  400]; break;
                case 100:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  400,  800]; break;
                case 200:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  800, 1000]; break;
                case 400:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1000, 1600]; break;
                default:	break;
            }
        }
        else
        {
            switch (intervalDistance) {
                case  25:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,  100,  200]; break;
                case  50:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  200,  400]; break;
                case 100:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  400,  800]; break;
                case 200:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  800, 1600]; break;
                case 400:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1600, 3200]; break;
                default:	break;
            }
        }
    }
    else if (iUnits == kEnglish)
    {
        if (bFurlongMode && (intervalDistance == 220 || intervalDistance == 440))
        {
            if (intervalDistance == 220)
                [splitDataStr appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"1/2", @"Mile"];
            else
                [splitDataStr appendFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"Mile", @"2-Mile"];
        }
        else
        {
            switch (intervalDistance)
            {
                case  25:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50, 100, 200]; break;
                case  50:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100, 200, 400]; break;
                case 110:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220, 440, 880]; break;
                case 220:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td>", 220, 440, 880, @"Mile"]; break;
                case 440:	[splitDataStr appendFormat:@"<td>%u</td><td>%u</td><td>%@</td><td>%@</td>", 440, 880, @"Mile", @"2-Mile"]; break;
                default:	break;
            }
        }
    }
    else if (iUnits == kLap)
    {
        [splitDataStr appendFormat:@"<td>%@</td>",  @"Interval"];
    }
    
    // rolled up split rows
    for (int row = 0; row < splits.count; row++)
    {
        [splitDataStr appendString:[self splitHTMLTextForRow:row forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits]];
    }
    
    // write last header and split rows
    // v1.2 - write Min, Max, Avg split summary
    // v2.0 - summaries for all distances
    if (splits.count > 1)
    {
        [splitDataStr appendFormat:@"%@", [self lastSplitHeaderHTMLText:(int)splits.count forSplits:splits forUnits:iUnits forIntervalDistance:intervalDistance forFurlongMode:bFurlongMode]];
        [splitDataStr appendFormat:@"%@", [self lastSplitHTMLText:splits]];
        [splitDataStr appendString:@"<tr><td align='right'> </td></tr>"];
        
        [splitDataStr appendString:@"<td><b>Min:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            [splitDataStr appendFormat:@"<td align='right'>%@</td>", [Utilities minSplit:splits forColumn:column]];
        
        [splitDataStr appendString:@"<tr></tr><td><b>Max:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            [splitDataStr appendFormat:@"<td align='right'>%@</td>", [Utilities maxSplit:splits forColumn:column]];
        
        [splitDataStr appendString:@"<tr></tr><td><b>Avg:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            [splitDataStr appendFormat:@"<td align='right'>%@</td>", [Utilities avgSplit:splits forColumn:column]];
    }
    
    // end table
    [splitDataStr appendString:@"</table>"];
    
    return splitDataStr;
}

@end