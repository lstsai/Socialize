//
//  EventDetailsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN
@protocol EventDetailsViewControllerDelegate

- (void)didLikeEvent:(Event*)likedEvent;
- (void)didUnlikeEvent:(Event*)unlikedEvent;


@end

@interface EventDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) id<EventDetailsViewControllerDelegate> delegate;


-(void) loadEventDetails;


@end

NS_ASSUME_NONNULL_END
