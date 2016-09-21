//
//  HistoryCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/22/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "HistoryCell.h"
#import "Utilities.h"

@implementation HistoryCell

//@synthesize backgroundImageView;
@synthesize dateLabel;
@synthesize nameLabel;
@synthesize timeLabel;
@synthesize eventLabel;

- (void)additionalSetup
{
	UIImageView *accImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AccDisclosure.png"]];
    //accImageView.tag = @"accImageView";
    accImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:accImageView];
	[accImageView release];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(/*dateLabel, nameLabel, timeLabel, eventLabel,*/ accImageView);
    
    /*
    if (IPAD) {
        // custom constraints for IPAD layout
        [NSLayoutConstraint deactivateConstraints:self.contentView.constraints];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[dateLabel]-4-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.175 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[eventLabel]-4-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:eventLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.100 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[timeLabel]-4-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:timeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.150 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[nameLabel]-4-|" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[dateLabel][eventLabel][timeLabel]-30-[nameLabel][accImageView(12)]-10-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[accImageView(14)]" options:0 metrics:nil views:views]];
    } else {
        // accessory image constraints for iPhone
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-6-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[accImageView(14)]" options:0 metrics:nil views:views]];
    }
    */
    
    if (IPAD) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-8-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[accImageView(14)]" options:0 metrics:nil views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-6-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-13-[accImageView(14)]" options:0 metrics:nil views:views]];
    }
    
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
