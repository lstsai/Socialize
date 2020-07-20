//
//  EventVerticalCell.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventVerticalCell.h"
#import "Constants.h"
@import GoogleMaps;

@implementation EventVerticalCell

-(void) loadData{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *dateString = [dateFormat stringFromDate:self.event.time];
    self.dateLabel.text=dateString;
    [dateFormat setDateFormat:@"MMM"];
    NSString *monthString = [dateFormat stringFromDate:self.event.time];
    self.monthLabel.text=monthString;
    [dateFormat setDateFormat:@"h:mm a"];
    NSString *timeString = [dateFormat stringFromDate:self.event.time];
    self.timeLabel.text=timeString;
    
    self.nameLabel.text=self.event.name;
    
    if([PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId])
        self.likeButton.selected=YES;
    else
        self.likeButton.selected=NO;
    
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    
    GMSGeocoder *geocoder= [GMSGeocoder geocoder];
    CLLocationCoordinate2D cllocation= CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    [geocoder reverseGeocodeCoordinate:cllocation completionHandler:^(GMSReverseGeocodeResponse * _Nullable address, NSError * _Nullable error) {
        if(error)
            NSLog(@"Error getting location of event %@", error.localizedDescription);
        else
            self.locationLabel.text=[[address firstResult] locality];

    }];
    [self setupShadows];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
    

}
-(void) setupShadows{
    
    self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.layer.shadowRadius = SHADOW_RADIUS*2;
    self.layer.shadowOpacity = SHADOW_OPACITY;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
    
    self.dateView.layer.cornerRadius = CELL_CORNER_RADIUS/2;
    self.dateView.layer.borderColor = [UIColor clearColor].CGColor;
    self.dateView.layer.masksToBounds = YES;
    self.dateView.clipsToBounds = YES;
    self.dateView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.dateView.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.dateView.layer.shadowRadius = SHADOW_RADIUS;
    self.dateView.layer.shadowOpacity = SHADOW_OPACITY/2;
    self.dateView.layer.masksToBounds = NO;
    self.dateView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.dateView.bounds cornerRadius:self.dateView.layer.cornerRadius].CGPath;

}

-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendEvents"][self.event.objectId])
        {
            self.event.numFriendsLike=((NSArray*)userAccess[@"friendEvents"][self.event.objectId]).count;
            self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.event.numFriendsLike];
            self.numLikesLabel.alpha=SHOW_ALPHA;
        }
        else
        {
            self.numLikesLabel.alpha=HIDE_ALPHA;
        }
    }];
}
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [self.delegate didLikeEvent:self.event];
    }
    else{
        self.likeButton.selected=NO;
        [self.delegate didUnlikeEvent:self.event];

    }
}
@end
