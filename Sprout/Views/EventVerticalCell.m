//
//  EventVerticalCell.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventVerticalCell.h"
#import "Constants.h"
#import "Helper.h"
@import GoogleMaps;

@implementation EventVerticalCell
/**
Loads the cell data from the event
*/
-(void) loadData{
    //format the date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *dateString = [dateFormat stringFromDate:self.event.startTime];
    self.dateLabel.text=dateString;
    [dateFormat setDateFormat:@"MMM"];
    NSString *monthString = [dateFormat stringFromDate:self.event.startTime];
    self.monthLabel.text=monthString;
    [dateFormat setDateFormat:@"h:mm a"];
    NSString *timeString = [dateFormat stringFromDate:self.event.startTime];
    self.timeLabel.text=timeString;
    
    self.nameLabel.text=self.event.name;
    //if the user has liked this event, set the like button to 'liked'
    if([PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId])
        self.likeButton.selected=YES;
    else
        self.likeButton.selected=NO;
    //load the event image
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    
    //Use the google maps geocoder to find the city of the event using the coordinates of the event
    GMSGeocoder *geocoder= [GMSGeocoder geocoder];
    CLLocationCoordinate2D cllocation= CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    [geocoder reverseGeocodeCoordinate:cllocation completionHandler:^(GMSReverseGeocodeResponse * _Nullable address, NSError * _Nullable error) {
        if(error)
            NSLog(@"Error getting location of event %@", error.localizedDescription);
        else{
            self.locationLabel.text=[[address firstResult] locality];
            self.event.streetAddress =[[[address firstResult] lines] componentsJoinedByString:@"\n"];
            [self.event saveInBackground];
        }

    }];
    
    
    [self setupShadows];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
    

}
/**
 configure the shadow and rounded corners for the cell
 */
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
    
    self.dateView.layer.cornerRadius = CELL_CORNER_RADIUS/2;
    self.dateView.layer.borderColor = [UIColor clearColor].CGColor;
    self.dateView.layer.masksToBounds = YES;
    self.dateView.clipsToBounds = YES;
    self.dateView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.dateView.layer.shadowOffset = CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET);
    self.dateView.layer.shadowRadius = SHADOW_RADIUS;
    self.dateView.layer.shadowOpacity = SHADOW_OPACITY;
    self.dateView.layer.masksToBounds = NO;

}
/**
 calculates the number of friends that have liked this specific event
 only shows the label if at least one friend has liked it
 */
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendEvents"][self.event.objectId])
        {
            self.event.numFriendsLike=((NSArray*)userAccess[@"friendEvents"][self.event.objectId]).count;
            if(self.event.numFriendsLike>0){
                self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friends have liked this", self.event.numFriendsLike];
                self.numLikesLabel.alpha=SHOW_ALPHA;
            }
        }
        else
        {
            self.numLikesLabel.alpha=HIDE_ALPHA;
        }
    }];
}
/**
Triggered when the user (un)likes this event. Calls the Helper method didLikeEvent or
 didUnlikeEvent to update user fields on parse.
 @param[in] sender the UIButton that was tapped
*/
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeEvent:self.event senderVC:nil];
    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeEvent:self.event];

    }
}
@end
