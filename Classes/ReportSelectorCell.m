//
//  ReportSelectorCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "ReportSelectorCell.h"

@implementation ReportSelectorCell

@synthesize selectorLabel;
@synthesize selectionLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [selectorLabel release];
    [selectionLabel release];
    [super dealloc];
}
@end
