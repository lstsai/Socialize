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
    
    self.contentView.layer.cornerRadius = 10.0f;
    self.contentView.layer.borderWidth = 1.0f;
    self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.clipsToBounds = YES;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
    
    self.dateView.layer.cornerRadius = 5.0f;
    self.dateView.layer.borderWidth = 1.0f;
    self.dateView.layer.borderColor = [UIColor clearColor].CGColor;
    self.dateView.layer.masksToBounds = YES;
    self.dateView.clipsToBounds = YES;
    self.dateView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.dateView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.dateView.layer.shadowRadius = 5.0f;
    self.dateView.layer.shadowOpacity = 0.5f;
    self.dateView.layer.masksToBounds = NO;
    self.dateView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.dateView.bounds cornerRadius:self.dateView.layer.cornerRadius].CGPath;

}

@end
