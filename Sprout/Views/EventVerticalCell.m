//
//  EventVerticalCell.m
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventVerticalCell.h"
@import GoogleMaps;

@implementation EventVerticalCell

-(void) loadData{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
    NSString *dateString = [dateFormat stringFromDate:self.event.time];
    self.dateLabel.text=dateString;
    
    self.nameLabel.text=self.event.name;
    GMSGeocoder *geocoder= [GMSGeocoder geocoder];
    CLLocationCoordinate2D cllocation= CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    [geocoder reverseGeocodeCoordinate:cllocation completionHandler:^(GMSReverseGeocodeResponse * _Nullable address, NSError * _Nullable error) {
        if(error)
            NSLog(@"Error getting location of event %@", error.localizedDescription);
        else
            self.locationLabel.text=[[address firstResult] locality];

    }];
    
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    
    self.contentView.layer.cornerRadius = 20.0f;
    self.contentView.layer.borderWidth = 1.0f;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.1f;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
}

@end
