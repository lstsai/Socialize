//
//  OrgDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgDetailsViewController.h"
#import "Location.h"
#import "WebViewController.h"
#import <Parse/Parse.h>
@interface OrgDetailsViewController ()

@end

@implementation OrgDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadOrgDetails];
}
-(void) loadOrgDetails{
    self.name.text=self.org.name;
    self.category.text=self.org.category;
    self.cause.text=self.org.cause;
    self.address.text=[Location addressFromLocation:self.org.location];
    self.tagLine.text=self.org.tagLine;
    self.mission.text=self.org.missionStatement;
    self.website.text=[self.org.website absoluteString];
    self.website.textColor=[UIColor linkColor];
    if([PFUser.currentUser[@"likedOrgs"] containsObject:self.org.ein])
        self.likeButton.selected=YES;
}

- (IBAction)didTapLink:(id)sender {
    [self performSegueWithIdentifier:@"webSegue" sender:nil];
}
- (IBAction)didTapLike:(id)sender {

    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [likedOrgs addObject:self.org.ein];
        [self performSelectorInBackground:@selector(addOrgToFriendsList) withObject:nil];//add to list in background

    }
    else{
        self.likeButton.selected=NO;
        [likedOrgs removeObject:self.org.ein];
        [self performSelectorInBackground:@selector(deleteOrgFromFriendsList) withObject:nil];//add to list in background

    }
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
    
}
-(void) addOrgToFriendsList{
    for(NSString* friend in PFUser.currentUser[@"friends"])//get the array of friends for current user
    {
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
        [friendQuery includeKey:@"friendAccessible"];
        PFUser* friendProfile=[friendQuery getObjectWithId:friend];
        //if the friend alreay has other friends that like this org
        PFObject * faAcess=friendProfile[@"friendAccessible"];
        if(faAcess[@"friendOrgs"][self.org.ein])
        {
            //add own username to that list of friends
            NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
            
            NSMutableArray* list= [friendOrgs[self.org.ein] mutableCopy];
            [list addObject:PFUser.currentUser.username];
            
            friendOrgs[self.org.ein]=list;
            faAcess[@"friendOrgs"]= friendOrgs;
        }
        else
        {
            //create that array for the ein and add self as the person who liked it
            NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
            friendOrgs[self.org.ein]=@[PFUser.currentUser.username];
            faAcess[@"friendOrgs"]= friendOrgs;
        }
        //save each friend
        [faAcess saveInBackground];
    }
}
-(void) deleteOrgFromFriendsList{
    for(NSString* friend in PFUser.currentUser[@"friends"])//get the array of friends for current user
       {
           PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
           [friendQuery includeKey:@"friendAccessible"];
           PFUser* friendProfile=[friendQuery getObjectWithId:friend];
           //if the friend alreay has other friends that like this org
           PFObject * faAcess=friendProfile[@"friendAccessible"];
           if(faAcess[@"friendOrgs"][self.org.ein])
           {
               //add own username to that list of friends
               NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
               
               NSMutableArray* list= [friendOrgs[self.org.ein] mutableCopy];
               [list removeObject:PFUser.currentUser.username];
               
               friendOrgs[self.org.ein]=list;
               faAcess[@"friendOrgs"]= friendOrgs;
           }
           //save each friend
           [faAcess saveInBackground];
       }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"webSegue"])
    {
        WebViewController *webVC=segue.destinationViewController;
        webVC.link=self.org.website;
    }
}


@end
