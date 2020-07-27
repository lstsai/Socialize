//
//  EventCollectionCell.h
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Collection view cells for the events that display on the Profile page
 */
#import <UIKit/UIKit.h>
#import "Event.h"

@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface EventCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
-(void) loadEventCell:(Event*)event;
@end

NS_ASSUME_NONNULL_END
