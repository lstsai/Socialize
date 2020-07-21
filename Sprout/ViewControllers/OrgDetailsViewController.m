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
    
    if(self.org.imageURL)//set image if available
        [self.backdropImage setImageWithURL:self.org.imageURL];
    else{
        //fetch image if not available, set when complete
        [[APIManager shared] getOrgImage:self.org.name completion:^(NSURL * _Nonnull orgImage, NSError * _Nonnull error) {
            if(orgImage)
            {
                self.org.imageURL=orgImage;
                NSLog(@"%@", orgImage);
                [self.backdropImage setImageWithURL:self.org.imageURL];
            }
        }];
    }
    if([PFUser.currentUser[@"likedOrgs"] containsObject:self.org.ein])
        self.likeButton.selected=YES;
}

- (IBAction)didTapLink:(id)sender {
    [self performSegueWithIdentifier:@"webSegue" sender:nil];
}
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [self.delegate didLikeOrg:self.org];

    }
    else{
        self.likeButton.selected=NO;
        [self.delegate didUnlikeOrg:self.org];

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
