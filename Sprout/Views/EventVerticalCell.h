//
//  EventVerticalCell.h
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface EventVerticalCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet  PFImageView *eventImage;
@property (strong, nonatomic) Event *event;

-(void) loadData;
@end

NS_ASSUME_NONNULL_END
