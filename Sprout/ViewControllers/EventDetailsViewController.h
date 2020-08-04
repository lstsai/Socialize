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
#import <EventKit/EventKit.h>
#import <ResponsiveLabel.h>
@import Parse;
@import GoogleMaps;
NS_ASSUME_NONNULL_BEGIN


@interface EventDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet ResponsiveLabel *eventDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *groupButton;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

-(void) loadEventDetails;
-(void) getLikes;
-(void) setupMap;
@end

NS_ASSUME_NONNULL_END
