//
//  EventCollectionCell.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventCollectionCell.h"
#import "Constants.h"
#import "DateTools.h"
@implementation EventCollectionCell
-(void) loadEventCell:(Event*)event{

    self.eventImage.file=event.image;
    [self.eventImage loadInBackground];
    self.eventNameLabel.text=event.name;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.timeLabel.text = [dateFormat stringFromDate:event.startTime];
    
    self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;

    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.layer.shadowRadius = SHADOW_RADIUS;
    self.layer.shadowOpacity = SHADOW_OPACITY;
    self.layer.masksToBounds = NO;
}
@end
