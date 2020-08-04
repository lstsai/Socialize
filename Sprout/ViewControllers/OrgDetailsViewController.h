//
//  OrgDetailsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View Controller to display the details for a specified organization
 */
#import <UIKit/UIKit.h>
#import "Organization.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "ClaimedOrganization.h"
@import GoogleMaps;
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface OrgDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Organization *org;
@property (strong, nonatomic) ClaimedOrganization *claimedOrg;
@property (weak, nonatomic) IBOutlet PFImageView *backdropImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tagLine;
@property (weak, nonatomic) IBOutlet UILabel *mission;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *cause;
@property (weak, nonatomic) IBOutlet UILabel *website;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (nonatomic) CLLocationCoordinate2D coord;
@property (nonatomic) BOOL gotCoords;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *claimButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


-(void) loadOrgDetails;
-(void) checkClaimed;
-(void) getCoords;
-(void) getLikes;
-(void) setupMap;
@end

NS_ASSUME_NONNULL_END
