
//
//  EventDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "CreatePostViewController.h"
#import "Helper.h"
@import GooglePlaces;
@import GoogleMaps;
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEventDetails];
}
-(void) loadEventDetails{
    self.eventNameLabel.text=self.event.name;
    [self.event.author fetchIfNeeded];
    self.eventAuthorLabel.text= self.event.author.username;
    
    GMSGeocoder *geocoder= [GMSGeocoder geocoder];
    CLLocationCoordinate2D cllocation= CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    [geocoder reverseGeocodeCoordinate:cllocation completionHandler:^(GMSReverseGeocodeResponse * _Nullable address, NSError * _Nullable error) {
        if(address)
        {
            self.eventLocationLabel.text=[[[address firstResult] lines] componentsJoinedByString:@"\n"];
        }
        else{
            NSLog(@"Error getting location of event %@", error.localizedDescription);
            [AppDelegate displayAlert:@"Error getting location of event" withMessage:error.localizedDescription on:self];
        }

    }];
    self.eventDetailsLabel.text= self.event.details;
    NSString *sdateString, *edateString;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if([[NSCalendar currentCalendar] isDate:self.event.startTime inSameDayAsDate:self.event.endTime])
    {
        [dateFormat setDateFormat:@"E, d MMM yyyy\nh:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        [dateFormat setDateFormat:@" - h:mm a"];
        edateString=[dateFormat stringFromDate:self.event.endTime];
        self.eventTimeLabel.text=[sdateString stringByAppendingString:edateString];
    }
    else{
        [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        edateString =[dateFormat stringFromDate:self.event.endTime];
        self.eventTimeLabel.text=[sdateString stringByAppendingFormat:@"\nTo %@", edateString];
    }
    
    if(self.event.image)
    {
        self.eventImageView.file=self.event.image;
        [self.eventImageView loadInBackground];
    }
    if([PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId])
        self.likeButton.selected=YES;
}
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeEvent:self.event senderVC:self];
    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeEvent:self.event];

    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"eventPostSegue"])
    {
        CreatePostViewController *createPostVC=segue.destinationViewController;
        createPostVC.event=self.event;
        createPostVC.org=nil;
    }
}


@end
