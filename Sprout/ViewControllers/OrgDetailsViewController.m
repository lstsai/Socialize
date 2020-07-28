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
#import "MapViewController.h"
@interface OrgDetailsViewController ()

@end

@implementation OrgDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
}
-(void) getCoords{
    [[APIManager shared] getCoordsFromAddress:[self.org.location streetAddress] completion:^(CLLocationCoordinate2D coords, NSError * _Nullable error) {
        if(error)
        {
            [Helper displayAlert:@"Error getting location" withMessage:@"Could not determine the location of this organization" on:self];
            self.gotCoords=NO;
        }
        else
        {
            self.coord=coords;
            self.gotCoords=YES;
        }
    }];
}
/**
Triggered when the user taps the address of the org and presents the MapViewController
@param[in] sender the address that was tapped
*/
- (IBAction)didTapAddress:(id)sender {
    if(self.gotCoords){
        [self performSegueWithIdentifier:@"mapSegue" sender:nil];
    }
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
    }
    else if([segue.identifier isEqualToString:@"mapSegue"])//shows user the map view
    {
        MapViewController *mapVC=segue.destinationViewController;
        mapVC.coords=self.coord;
        mapVC.name=self.org.name;
    }
}


@end
