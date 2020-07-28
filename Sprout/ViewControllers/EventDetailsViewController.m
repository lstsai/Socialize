
//
//  EventDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "CreatePostViewController.h"
#import "Helper.h"
#import "MapViewController.h"
#import "Constants.h"
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEventDetails];
}
/**
Loads the view controller's views to reflect the event it is representing
*/
-(void) loadEventDetails{
    self.eventNameLabel.text=self.event.name;
    [self.event.author fetchIfNeeded];
    self.eventAuthorLabel.text= self.event.author.username;
    self.eventLocationLabel.text=self.event.streetAddress;
    
    self.eventDetailsLabel.text= self.event.details;
    NSString *sdateString, *edateString;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //display the start time and end time differently depending on if start and end are on same day
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
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];

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
        [Helper didLikeEvent:self.event senderVC:self];
    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeEvent:self.event];

    }
}
/**
Triggered when the user taps the address of the event and presents the MapViewController
@param[in] sender the address that was tapped
*/
- (IBAction)didTapAddress:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"eventPostSegue"])//takes the user to the page to create post about this event
    {
        CreatePostViewController *createPostVC=segue.destinationViewController;
        createPostVC.event=self.event;
        createPostVC.org=nil;
    }
    else if([segue.identifier isEqualToString:@"mapSegue"])//shows the user the map view of the event location
    {
        MapViewController *mapVC=segue.destinationViewController;
        mapVC.name=self.event.name;
        mapVC.coords=CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    }
}


@end
