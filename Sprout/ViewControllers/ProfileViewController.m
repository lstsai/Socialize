//
//  ProfileViewController.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "ProfileViewController.h"
#import "EventCollectionCell.h"
#import "OrgCollectionCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventCollectionView.delegate=self;
    self.eventCollectionView.dataSource=self;
    self.orgCollectionView.delegate=self;
    self.orgCollectionView.dataSource=self;
    self.likedOrgs= [[NSMutableArray alloc]init];
    if(!self.user){
        [PFUser.currentUser fetchInBackground];
        self.user=PFUser.currentUser;
    }    
}
-(void) viewWillAppear:(BOOL)animated{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self loadProfile];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)loadProfile{
    if(self.user==PFUser.currentUser)
    {
        [self.topButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Edit" forState:UIControlStateSelected];
    }
    else{
        [self.topButton setTitle:@"+ Friend" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Friends" forState:UIControlStateSelected];
        if([PFUser.currentUser[@"friends"] containsObject:self.user.objectId])
            self.topButton.selected=YES;
    }
    self.topButton.layer.cornerRadius=8;
    self.topButton.layer.masksToBounds=YES;
    
    self.nameLabel.text=self.user.username;
    self.usernameLabel.text=self.user.username;

    if(self.user[@"profilePic"])
    {
        self.profileImage.file=self.user[@"profilePic"];
        [self.profileImage loadInBackground];
    }
    if(self.user[@"backgroundPic"])
    {
        self.backgroundImage.file=self.user[@"backgroundPic"];
        [self.backgroundImage loadInBackground];
    }
    self.friendCount.text=[NSString stringWithFormat:@"%lu", ((NSArray*)self.user[@"friends"]).count];
    self.orgCount.text=[NSString stringWithFormat:@"%lu",((NSArray*)self.user[@"likedOrgs"]).count];
    self.eventCount.text=[NSString stringWithFormat:@"%lu",((NSArray*)self.user[@"likedEvents"]).count];
    [self getLikedOrgInfo];
    [self getLikedEventInfo];
}
-(void)getLikedOrgInfo{
    
    [[APIManager shared] getOrgsWithEIN:self.user[@"likedOrgs"] completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
        if(error)
            [AppDelegate displayAlert:@"Error getting liked organizations" withMessage:error.localizedDescription on:self];
        else{
            self.likedOrgs =organizations;
            NSLog(@"Success getting liked orgs");
            [self.orgCollectionView reloadData];
        }
    }];
    
}
-(void)getLikedEventInfo{
    PFQuery *eventQuery= [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" containedIn:self.user[@"likedEvents"]];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error getting location of event" withMessage:error.localizedDescription on:self];
        else
        {
            self.likedEvents=objects;
            [self.eventCollectionView reloadData];
        }
    }];

}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(collectionView==self.eventCollectionView)
    {
        EventCollectionCell *ecc=[collectionView dequeueReusableCellWithReuseIdentifier:@"EventCollectionCell" forIndexPath:indexPath];
        [ecc loadEventCell:self.likedEvents[indexPath.item]];
        return ecc;
    }
    else{
        OrgCollectionCell *orgcc=[collectionView dequeueReusableCellWithReuseIdentifier:@"OrgCollectionCell" forIndexPath:indexPath];
        [orgcc loadOrgCell:self.likedOrgs[indexPath.item]];
        return orgcc;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView==self.eventCollectionView)
        return self.likedEvents.count;
    else
        return self.likedOrgs.count;
}
- (IBAction)didTapButton:(id)sender {
    
    if(self.user!=PFUser.currentUser)
    {
        if(!self.topButton.selected)
        {
            self.topButton.selected=YES;
            NSMutableArray *friendsArray=PFUser.currentUser[@"friends"];
            [friendsArray addObject:self.user.objectId];
            PFUser.currentUser[@"friends"]=friendsArray;
            
            friendsArray=self.user[@"friends"];
            [friendsArray addObject:PFUser.currentUser.objectId];
            self.user[@"friends"]=friendsArray;
        }
        else
        {
            self.topButton.selected=NO;
            NSMutableArray *friendsArray=PFUser.currentUser[@"friends"];
            [friendsArray removeObject:self.user.objectId];
            PFUser.currentUser[@"friends"]=friendsArray;
            
            friendsArray=self.user[@"friends"];
            [friendsArray removeObject:PFUser.currentUser.objectId];
            self.user[@"friends"]=friendsArray;
        }
        [PFUser.currentUser saveInBackground];
        [self.user saveInBackground];
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
