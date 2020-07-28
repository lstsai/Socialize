//
//  EventDetailsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
View Controller to display the details for a specified event
*/
#import <UIKit/UIKit.h>
#import "Event.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN


@interface EventDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;

-(void) loadEventDetails;
-(void) getLikes;
@end

NS_ASSUME_NONNULL_END
