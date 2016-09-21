//
//  SplitHeaderView.h
//  Stopwatch
//
//  Created by Steven Gentry on 6/21/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitHeaderView : UIView
{
    UILabel *lapColumn;
    UILabel *timeColumn;
    UILabel *splitColumn1;
    UILabel *splitColumn2;
    UILabel *splitColumn3;
    UILabel *splitColumn4;
}

@property (nonatomic, assign) IBOutlet UILabel *lapColumn;
@property (nonatomic, assign) IBOutlet UILabel *timeColumn;
@property (nonatomic, assign) IBOutlet UILabel *splitColumn1;
@property (nonatomic, assign) IBOutlet UILabel *splitColumn2;
@property (nonatomic, assign) IBOutlet UILabel *splitColumn3;
@property (nonatomic, assign) IBOutlet UILabel *splitColumn4;

- (void)setup;
- (void)setTextWithArray:(NSMutableArray*)textArray;

@end
