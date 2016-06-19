//
//  HistoryCell.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/22/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHistoryTableViewCellHeight	36

@interface HistoryCell : UITableViewCell
{
	//UIImageView *backgroundImageView;
	UILabel *dateLabel;
	UILabel *eventLabel;
	UILabel *nameLabel;
	UILabel *timeLabel;
}

//@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *eventLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (void)additionalSetup;

@end