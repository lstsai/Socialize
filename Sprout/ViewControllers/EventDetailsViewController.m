
//
//  EventDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
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
    self.eventAuthorLabel.text=self.event.author.username;
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
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E, d MMM yyyy\nh:mm a"];
    NSString *dateString = [dateFormat stringFromDate:self.event.time];
    self.eventTimeLabel.text=dateString;
    
    if(self.event.image)
    {
        self.eventImageView.file=self.event.image;
        [self.eventImageView loadInBackground];
    }
    if([PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId])
        self.likeButton.selected=YES;
}
- (IBAction)didTapLike:(id)sender {
     NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];
       if(!self.likeButton.selected)
       {
           self.likeButton.selected=YES;
           [likedEvents addObject:self.event.objectId];
           [self performSelectorInBackground:@selector(addEventToFriendsList) withObject:nil];
       }
       else{
           self.likeButton.selected=NO;
           [likedEvents removeObject:self.event.objectId];
           [self performSelectorInBackground:@selector(deleteEventFromFriendsList) withObject:nil];

       }
       PFUser.currentUser[@"likedEvents"]=likedEvents;
       [PFUser.currentUser saveInBackground];
}

-(void) addEventToFriendsList{
    for(NSString* friend in PFUser.currentUser[@"friends"])//get the array of friends for current user
    {
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
        [friendQuery includeKey:@"friendAccessible"];
        PFUser* friendProfile=[friendQuery getObjectWithId:friend];
        //if the friend alreay has other friends that like this org
        PFObject * faAcess=friendProfile[@"friendAccessible"];
        if(faAcess[@"friendEvents"][self.event.objectId])
        {
            //add own username to that list of friends
            NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
            
            NSMutableArray* list= [friendEvents[self.event.objectId] mutableCopy];
            [list addObject:PFUser.currentUser.username];
            
            friendEvents[self.event.objectId]=list;
            faAcess[@"friendEvents"]= friendEvents;
        }
        else
        {
            //create that array for the ein and add self as the person who liked it
            NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
            friendEvents[self.event.objectId]=@[PFUser.currentUser.username];
            faAcess[@"friendEvents"]= friendEvents;
        }
        //save each friend
        [faAcess saveInBackground];
    }
}

-(void) deleteEventFromFriendsList{
    for(NSString* friend in PFUser.currentUser[@"friends"])//get the array of friends for current user
       {
           PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
           [friendQuery includeKey:@"friendAccessible"];
           PFUser* friendProfile=[friendQuery getObjectWithId:friend];
           //if the friend alreay has other friends that like this org
           PFObject * faAcess=friendProfile[@"friendAccessible"];
           if(faAcess[@"friendEvents"][self.event.objectId])
           {
               //add own username to that list of friends
               NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
               
               NSMutableArray* list= [friendEvents[self.event.objectId] mutableCopy];
               [list removeObject:PFUser.currentUser.username];
               
               friendEvents[self.event.objectId]=list;
               faAcess[@"friendEvents"]= friendEvents;
           }
           //save each friend
           [faAcess saveInBackground];
       }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
