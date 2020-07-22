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
#import "EventDetailsViewController.h"
#import "OrgDetailsViewController.h"
#import "Helper.h"
@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    [self setupImagePicker];
}
-(void) viewWillAppear:(BOOL)animated{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self loadProfile];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)loadProfile{
    if(self.user.username==PFUser.currentUser.username)
    {
        [self.topButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Edit" forState:UIControlStateSelected];
    }
    else{
        [self.topButton setTitle:@"+ Friend" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Friends" forState:UIControlStateSelected];
        
        PFQuery *accessQuery= [PFQuery queryWithClassName:@"UserAccessible"];
        [accessQuery whereKey:@"username" equalTo:PFUser.currentUser.username];
        PFObject *fAccess=[accessQuery getFirstObject];
        if([fAccess[@"friends"] containsObject:self.user.objectId])
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
    PFQuery *accessQuery= [PFQuery queryWithClassName:@"UserAccessible"];
    [accessQuery whereKey:@"username" equalTo:PFUser.currentUser.username];
    PFObject *fAccess=[accessQuery getFirstObject];
    self.friendCount.text=[NSString stringWithFormat:@"%lu", ((NSArray*)fAccess[@"friends"]).count];
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
            //add this friend to friend list and update write acess
            self.topButton.selected=YES;
            [self addFriend:PFUser.currentUser toFriend:self.user];
            [self addFriend:self.user toFriend:PFUser.currentUser];
        }
        else
        {
            //remove friend from friend list and update write acess
            self.topButton.selected=NO;
            [self removeFriend:PFUser.currentUser toFriend:self.user];
            [self removeFriend:self.user toFriend:PFUser.currentUser];
        }
    }

}

-(void) addFriend:(PFUser*) from toFriend:(PFUser*) to{
    
    PFQuery *accessQuery= [PFQuery queryWithClassName:@"UserAccessible"];
    [accessQuery whereKey:@"username" equalTo:from.username];
    PFObject *friendsAccess= [accessQuery getFirstObject];
    NSMutableArray *friendsArray=friendsAccess[@"friends"];
    [friendsArray addObject:to.objectId];
    friendsAccess[@"friends"]=friendsArray;
    [friendsAccess saveInBackground];
    
    [self performSelectorInBackground:@selector(addFriendLikes:) withObject:@[from, to]];
}

-(void) removeFriend:(PFUser*) from toFriend:(PFUser*) to{
    
    PFQuery *accessQuery= [PFQuery queryWithClassName:@"UserAccessible"];
    [accessQuery whereKey:@"username" equalTo:from.username];
    PFObject *friendsAccess= [accessQuery getFirstObject];
    NSMutableArray *friendsArray=friendsAccess[@"friends"];
    [friendsArray removeObject:to.objectId];
    friendsAccess[@"friends"]=friendsArray;
    [friendsAccess saveInBackground];
    [self performSelectorInBackground:@selector(deleteFriendLikes:) withObject:@[from, to]];

}

-(void)addFriendLikes:(NSArray*)users{
    
    /*
    HI JOHN if you're reading this the code ypou're about to see is super
    duper chunky because Parse wouldn't save my objects otherwise.
     You were warned :))
     */
    PFUser *fromUser= [users firstObject];
    PFUser *toUser=[users lastObject];
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:fromUser.username];
    [selfAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* selfAccess=object;
        PFObject *friendLikes=selfAccess[@"friendOrgs"];
        for(NSString* ein in toUser[@"likedOrgs"])
        {
            if(friendLikes[ein])
            {
                NSMutableArray *list= [friendLikes[ein] mutableCopy];
                [list addObject:toUser.username];
                friendLikes[ein]=list;
            }
            else
            {
                friendLikes[ein]=@[toUser.username];
            }
        }
        selfAccess[@"friendOrgs"]=friendLikes;
        [selfAccess saveInBackground];


        friendLikes=selfAccess[@"friendEvents"];
        for(NSString *eventId in toUser[@"likedEvents"])
        {
            if(friendLikes[eventId])
            {
                NSMutableArray *list= [friendLikes[eventId] mutableCopy];
                [list addObject:toUser];
                friendLikes[eventId]=list;
            }
            else
            {
                friendLikes[eventId]=@[toUser.username];
            }
        }
        selfAccess[@"friendEvents"]=friendLikes;
        [selfAccess saveInBackground];
    
    }];
}
-(void)deleteFriendLikes:(NSArray*)users{

    PFUser *fromUser= [users firstObject];
    PFUser *toUser=[users lastObject];
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:fromUser.username];
    [selfAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* selfAccess=object;
        PFObject *friendLikes=selfAccess[@"friendOrgs"];
        for(NSString* ein in toUser[@"likedOrgs"])
        {
            if(friendLikes[ein])
            {
                NSMutableArray *list= [friendLikes[ein] mutableCopy];
                [list removeObject:toUser.username];
                friendLikes[ein]=list;
            }
            else
            {
                friendLikes[ein]=@[toUser.username];
            }
        }
        selfAccess[@"friendOrgs"]=friendLikes;
        [selfAccess saveInBackground];

        friendLikes=selfAccess[@"friendEvents"];
        for(NSString *eventId in toUser[@"likedEvents"])
        {
            if(friendLikes[eventId])
            {
                NSMutableArray *list= [friendLikes[eventId] mutableCopy];
                [list removeObject:toUser];
                friendLikes[eventId]=list;
            }
            else
            {
                friendLikes[eventId]=@[toUser.username];
            }
        }
        selfAccess[@"friendEvents"]=friendLikes;
        [selfAccess saveInBackground];
    
    }];
}

-(void) setupImagePicker{
    self.profileImagePicker=[UIImagePickerController new];
    self.profileImagePicker.allowsEditing=YES;
    self.profileImagePicker.delegate=self;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    
    self.backgroundImagePicker=[UIImagePickerController new];
    self.backgroundImagePicker.allowsEditing=YES;
    self.backgroundImagePicker.delegate=self;
}

- (IBAction)didTapImagePicker:(id)sender {
    UIImagePickerController* imagePickerVC;
    
    if([(UIGestureRecognizer *)sender view]==self.profileImage)
        imagePickerVC=self.profileImagePicker;
    else
        imagePickerVC=self.backgroundImagePicker;
    //check if this device has a camera before presenting the picker
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"No camera available, using image picker");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if(picker==self.profileImagePicker){
        [self.profileImage setImage:editedImage];
        NSString *imageName=[PFUser.currentUser.username stringByAppendingString:@"ProfilePic"];
        PFUser.currentUser[@"profilePic"]=[Helper getPFFileFromImage:editedImage withName:imageName];
    }
    else{
        [self.backgroundImage setImage:editedImage];
        NSString *imageName=[PFUser.currentUser.username stringByAppendingString:@"BackgroundPic"];
        PFUser.currentUser[@"backgroundPic"]=[Helper getPFFileFromImage:editedImage withName:imageName];
    }
    [PFUser.currentUser saveInBackground];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"orgSegue"])
    {
        OrgDetailsViewController *orgVC= segue.destinationViewController;
        UICollectionViewCell *tappedCell=sender;
        NSIndexPath *tappedIndex=[self.orgCollectionView indexPathForCell:tappedCell];
        orgVC.org=self.likedOrgs[tappedIndex.item];
        [self.orgCollectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
    else if([segue.identifier isEqualToString:@"eventSegue"])
    {
        EventDetailsViewController *eventVC= segue.destinationViewController;
        UICollectionViewCell *tappedCell=sender;
        NSIndexPath *tappedIndex=[self.eventCollectionView indexPathForCell:tappedCell];
        eventVC.event=self.likedEvents[tappedIndex.item];
        [self.eventCollectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}


@end
