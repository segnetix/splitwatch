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
	NSString *distStr = @"";
	
	if (distance < 10000)
		distStr = [distStr stringByAppendingString:@" "];
	if (distance < 1000)
		distStr = [distStr stringByAppendingString:@" "];
	if (distance < 100)
		distStr = [distStr stringByAppendingString:@" "];
	distStr = [distStr stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)distance]];
	
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

@end