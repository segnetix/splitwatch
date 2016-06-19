//
//  HistoryCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/22/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

//@synthesize backgroundImageView;
@synthesize dateLabel;
@synthesize nameLabel;
@synthesize timeLabel;
@synthesize eventLabel;

- (void)additionalSetup
{
	// background
	//UIImage *backgroundGradient = [UIImage imageNamed:@"dark_black_gradient.png"];
	//backgroundImageView = [[UIImageView alloc] initWithImage:backgroundGradient];
	//backgroundImageView.frame = CGRectMake(0, 0, 320, kHistoryTableViewCellHeight);
	//[self.backgroundView addSubview:backgroundImageView];
	
	//[backgroundImageView release];

	//self.backgroundColor = [UIColor blackColor];
	//self.backgroundView.backgroundColor = [UIColor blackColor];
	
	// cell label text color
	//dateLabel.textColor = [UIColor whiteColor];
	//nameLabel.textColor = [UIColor whiteColor];
	//timeLabel.textColor = [UIColor whiteColor];
	//eventLabel.textColor = [UIColor whiteColor];
	
	UIImageView *accImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AccDisclosure.png"]];
	//accImageView.frame = CGRectMake(302, 11, 12, 14);
    accImageView.tag = @"accImageView";
    accImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:accImageView];
	[accImageView release];
	
	UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
	//separatorImageView = CGRectMake(11, 35, 287, 1);
    separatorImageView.tag = @"separatorImageView";
    separatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:separatorImageView];
	[separatorImageView release];
	
    NSDictionary *views = NSDictionaryOfVariableBindings(accImageView, separatorImageView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-6-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[accImageView(14)]" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-11-[separatorImageView]-20-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[separatorImageView(1)]" options:0 metrics:nil views:views]];
    
	self.selectionStyle = UITableViewCellSelectionStyleGray;
	self.backgroundView.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc
{
	[dateLabel release];
	[nameLabel release];
	[timeLabel release];
	[eventLabel release];
	
	dateLabel = nil;
	nameLabel = nil;
	timeLabel = nil;
	eventLabel = nil;
	
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
