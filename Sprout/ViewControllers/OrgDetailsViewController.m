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
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "CreatePostViewController.h"
#import "Helper.h"
#import "Constants.h"
#import "ClaimedOrganization.h"
#import "MBProgressHUD.h"
#import "EditOrgViewController.h"
#import "DMViewController.h"
@interface OrgDetailsViewController ()

@end

@implementation OrgDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void) viewWillAppear:(BOOL)animated{
    [self loadOrgDetails];
    [self getCoords];
}
/**
 Loads the view controller's views to reflect the organization it is representing
 */
-(void) loadOrgDetails{
    self.name.text=self.org.name;
    self.category.text=self.org.category;
    self.cause.text=self.org.cause;
    self.address.text=[Location addressFromLocation:self.org.location];
    self.tagLine.text=self.org.tagLine;
    self.mission.text=self.org.missionStatement;
    self.website.text=[self.org.website absoluteString];
    self.website.textColor=[UIColor linkColor];
    
    if(self.org.imageURL)//set image if available
    {
        [self.backdropImage setImageWithURL:self.org.imageURL];
        self.backdropImage.backgroundColor=[UIColor whiteColor];
    }
    else{
        //fetch image if not available, set when complete
        [[APIManager shared] getOrgImage:self.org.name completion:^(NSURL * _Nonnull orgImage, NSError * _Nonnull error) {
            if(orgImage)
            {
                self.org.imageURL=orgImage;
                [self.backdropImage setImageWithURL:self.org.imageURL];
                self.backdropImage.backgroundColor=[UIColor whiteColor];
            }
        }];
    }
    if([PFUser.currentUser[@"likedOrgs"] containsObject:self.org.ein])
        self.likeButton.selected=YES;
    if([PFUser.currentUser[@"claimedOrgs"] containsObject:self.org.ein])
    {
        self.claimButton.alpha=HIDE_ALPHA;
        self.editButton.alpha=SHOW_ALPHA;
        self.messageButton.alpha=SHOW_ALPHA;
    }
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];
    [self checkClaimed];
}

-(void) checkClaimed{
    [Helper getClaimedOrgFromEin:self.org.ein withCompletion:^(PFObject * _Nonnull claimedOrg) {
        if(claimedOrg)
        {
            self.claimButton.alpha=HIDE_ALPHA;
            self.claimedOrg=(ClaimedOrganization*)claimedOrg;
            self.name.text=self.claimedOrg.name;
            self.category.text=self.claimedOrg.category;
            self.cause.text=self.claimedOrg.cause;
            self.address.text=self.claimedOrg.address;
            self.tagLine.text=self.claimedOrg.tagLine;
            self.mission.text=self.claimedOrg.missionStatement;
            self.website.text=self.claimedOrg.website;
            self.backdropImage.file=self.claimedOrg.image;
            [self.backdropImage loadInBackground];
            [Helper performSelectorInBackground:@selector(addUserToSeenClaimedOrgList:) withObject:claimedOrg];
        }
    }];
    
}
/**
 calculates the number of friends that have liked this specific org
 only shows the label if at least one friend has liked it
 */
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendOrgs"][self.org.ein])
        {
            self.org.numFriendsLike=((NSArray*)userAccess[@"friendOrgs"][self.org.ein]).count;
            if(self.org.numFriendsLike>0){
                if(self.org.numFriendsLike==1)
                    self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friend liked this", self.org.numFriendsLike];
                else
                    self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friends liked this", self.org.numFriendsLike];
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
Gets the coordinates of the organization
*/
-(void) getCoords{
    [[APIManager shared] getCoordsFromAddress:[Location  addressFromLocation:self.org.location] completion:^(CLLocationCoordinate2D coords, NSError * _Nullable error) {
        if(error)
        {
            [Helper displayAlert:@"Error getting location" withMessage:@"Could not determine the location of this organization" on:self];
            self.gotCoords=NO;
        }
        else
        {
            self.coord=coords;
            self.gotCoords=YES;
            [self setupMap];
        }
    }];
}
/**
 Configures the map view in the details controller according to the coords
 */
-(void) setupMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.coord zoom:MAP_ZOOM];
    self.mapView.camera=camera;
    GMSMarker* marker= [GMSMarker markerWithPosition:self.coord];
    marker.title=self.org.name;
    marker.map=self.mapView;
}
/**
 Triggered when the user taps the link of the website and presents the webviewcontroller
 @param[in] sender the link that was tapped
 */
- (IBAction)didTapLink:(id)sender {
    [self performSegueWithIdentifier:@"webSegue" sender:nil];
}
/**
Triggered when the user (un)likes this organization. Calls the Helper method didLikeOrg or
 didUnlikeOrg to update user fields on parse.
 @param[in] sender the UIButton that was tapped
*/
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeOrg:self.org sender:self];

    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeOrg:self.org];

    }
}
/**
 Triggered when the user presses the claim button
 */
- (IBAction)didClaimOrg:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ClaimedOrganization claimOrganization:self.org.ein withName:self.org.name withCategory:self.org.category withCause:self.org.cause withMissionStatement:self.org.missionStatement withAddress:self.address.text withTagline:self.org.tagLine withWebsite:self.org.website.absoluteString withImage:self.backdropImage.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
            [Helper displayAlert:@"Error Claiming Organization" withMessage:error.localizedDescription on:self];
        else{
            NSMutableArray* claimed=PFUser.currentUser[@"claimedOrgs"];
            [claimed addObject:self.org.ein];
            PFUser.currentUser[@"claimedOrgs"]=claimed;
            [PFUser.currentUser saveInBackground];
            self.claimButton.alpha=HIDE_ALPHA;
            self.editButton.alpha=SHOW_ALPHA;
            [Helper getClaimedOrgFromEin:self.org.ein withCompletion:^(PFObject * _Nonnull claimedOrg) {
                if(claimedOrg)
                    self.claimedOrg=(ClaimedOrganization*) claimedOrg;
            }];
            [Helper displayAlert:@"Successfully Claimed Organization" withMessage:@"You have claimed this organization, now you can edit this organization's information" on:self];
        }
    }];
}
/**
 Triggered when the user taps the message button,
 fetches the users that have seen this org and presents the dm view*/
- (IBAction)didTapMessage:(id)sender {
    [Helper getClaimedOrgSeenUsers:self.claimedOrg withCompletion:^(NSArray * _Nonnull users, NSError * _Nonnull error) {
        [self performSegueWithIdentifier:@"messageSegue" sender:users];
    }];
}
/**
 Triggered when the user pinches to zoom on the image. Will animate back to original
 state when the user stops pinching.
 @param[in] sender the pinch gesture that was triggered
 */
- (IBAction)didPinchImage:(id)sender {

    UIPinchGestureRecognizer* pinch= sender;
    //end pinching, go back to original
    if(UIGestureRecognizerStateEnded == [pinch state]){
        [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
            self.backdropImage.transform=CGAffineTransformIdentity;
        }];
    }
    UIView *pinchView = pinch.view;
    CGRect bounds = pinchView.bounds;
    CGPoint pinchCenter = [pinch locationInView:pinchView];
    pinchCenter.x -= CGRectGetMidX(bounds);
    pinchCenter.y -= CGRectGetMidY(bounds);
    CGAffineTransform transform = pinchView.transform;
    transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
    CGFloat scale = pinch.scale;
    transform = CGAffineTransformScale(transform, scale, scale);
    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
    pinchView.transform = transform;
    pinch.scale = PINCH_SCALE;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"webSegue"])//takes the user to the webview controller
    {
        WebViewController *webVC=segue.destinationViewController;
        webVC.link=self.org.website;
    }
    else if([segue.identifier isEqualToString:@"orgPostSegue"])//takes the user to the page to create a post about this org
    {
        CreatePostViewController *createPostVC=segue.destinationViewController;
        createPostVC.org=self.org;
        createPostVC.event=nil;
        createPostVC.isGroupPost=NO;

    }
    else if([segue.identifier isEqualToString:@"editSegue"])//takes the user to the page to create a post about this org
    {
        EditOrgViewController *editVC=segue.destinationViewController;
        editVC.claimedOrg=self.claimedOrg;
    }
    else if([segue.identifier isEqualToString:@"messageSegue"])//takes the user to the page to create a post about this org
    {
        DMViewController *dmVC=segue.destinationViewController;
        dmVC.seenUsers=(NSArray*)sender;
        dmVC.isOrgMessages=YES;
    }
}


@end
