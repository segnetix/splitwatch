//
//  Utilities.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/4/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMetric                     0
#define kEnglish                    1
#define kLap                        2                   // v1.2
#define k25mLapInterval             0
#define k50mLapInterval             1
#define k100mLapInterval            2
#define	k200mLapInterval            3
#define	k400mLapInterval            4
#define	k25yLapInterval             0
#define	k50yLapInterval             1
#define	k110yLapInterval            2
#define	k220yLapInterval            3
#define	k440yLapInterval            4
#define kControlOff                 0
#define kControlOn                  1
#define kNoSelection               -1
#define kDisplayMode_Normal			1
#define kDisplayMode_Space			2
#define kDisplayMode_Last_Header	3
#define kDisplayMode_Last_Split		4
#define kDisplayMode_Avg_Split		5
#define kDisplayMode_Min_Split		6
#define kDisplayMode_Max_Split		7
#define kEventDetailMaxRows        12                   // v1.2
#define kSummaryLineCount           6                   // v1.2
#define	FONT_NAME                   @"Avenir-Book"      // v2.0

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface Utilities : NSObject
{
}

+ (NSString *)formatTime:(NSTimeInterval)timeInterval minDigits:(int)minDigits precision:(int)precision;
+ (NSString *)formatTimeWithHours:(NSTimeInterval)timeInterval;
+ (NSString *)shortFormatTime:(NSTimeInterval)timeInterval precision:(int)precision;
+ (NSString *)formatLap:(NSInteger)lapCount;
+ (NSString *)formatDistance:(NSInteger)distance;
+ (NSString *)formatDate:(NSTimeInterval)dateTimeInterval;
+ (NSString *)formatDateTime:(NSTimeInterval)dateTimeInterval format:(NSString *)format;
//+ (NSString *)getSplitViewHeaderText:(NSInteger)lapDistance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongDisplayMode:(BOOL)furlongDisplayMode;
+ (NSMutableArray *)getSplitViewHeaderArray:(NSInteger)lapDistance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongDisplayMode:(BOOL)furlongDisplayMode;

//+ (NSString *)sqlStringWithDate:(NSDate *)date;
//+ (NSDate *)dateWithSQLString:(NSString *)string;
+ (NSString *)sqlStringWithIimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)timeIntervalWithSQLString:(NSString *)string;

+ (NSString *)stringFromDistance:(NSInteger)distance Units:(int)units ShowMiles:(BOOL)showMiles ShowSplitTag:(BOOL)showSplitTag Interval:(int)interval FurlongDisplayMode:(BOOL)furlongDisplayMode;

+ (NSString *)avgSplit:(NSMutableArray *)splits forColumn:(NSInteger)column;
+ (NSString *)minSplit:(NSMutableArray *)splits forColumn:(NSInteger)column;
+ (NSString *)maxSplit:(NSMutableArray *)splits forColumn:(NSInteger)column;

+ (int)getHrs:(double)split;
+ (int)getMin:(double)split;
+ (int)getSec:(double)split;
+ (int)getHundredths:(double)split;

+ (NSString *)lapTextForRow:(NSInteger)row
             forDisplayMode:(NSInteger)mode
            withSplitsCount:(int)splitsCount
           intervalDistance:(int)intervalDistance
                      units:(int)units
                furlongMode:(BOOL)furlongMode;
//+ (NSString *)timeTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode;

@end
