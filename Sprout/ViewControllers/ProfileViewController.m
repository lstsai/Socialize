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
#import "MBProgressHUD.h"
#import "EventDetailsViewController.h"
#import "OrgDetailsViewController.h"
#import "Helper.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Constants.h"
@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventCollectionView.delegate=self;
    self.eventCollectionView.dataSource=self;
    self.orgCollectionView.delegate=self;
    self.orgCollectionView.dataSource=self;
    self.orgCollectionView.emptyDataSetSource = self;
    self.orgCollectionView.emptyDataSetDelegate = self;
    self.eventCollectionView.emptyDataSetSource = self;
    self.eventCollectionView.emptyDataSetDelegate = self;
    self.likedOrgs= [[NSMutableArray alloc]init];
    if(!self.user){
        [PFUser.currentUser fetchInBackground];
        self.user=PFUser.currentUser;
    }
    [self setupImagePicker];
    [self loadProfile];
}

-(void)loadProfile{
    
   
    PFObject *fAccess=[Helper getUserAccess:PFUser.currentUser];
    if(self.user.username==PFUser.currentUser.username)
    {
        [self.topButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Edit" forState:UIControlStateSelected];
        self.topButton.alpha=HIDE_ALPHA;
        self.privateView.alpha=HIDE_ALPHA;
    }
    else{
        [self.topButton setTitle:@"+ Friend" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Requested" forState:UIControlStateSelected];

        if([fAccess[@"friends"] containsObject:self.user.objectId])
        {
            [self.topButton setTitle:@"Friends" forState:UIControlStateSelected];
            self.topButton.selected=YES;
            self.privateView.alpha=HIDE_ALPHA;
        }
        else if ([fAccess[@"outRequests"] containsObject:self.user.objectId])
        {
            self.topButton.highlighted=YES;
        }
        else if ([fAccess[@"inRequests"] containsObject:self.user.objectId])
        {
            self.requestView.alpha=SHOW_ALPHA;
            self.topButton.userInteractionEnabled=NO;
        }
    }
    self.topButton.layer.cornerRadius=CELL_CORNER_RADIUS*0.8;
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
    self.friendCount.text=[NSString stringWithFormat:@"%lu", ((NSArray*)fAccess[@"friends"]).count];
    self.orgCount.text=[NSString stringWithFormat:@"%lu",((NSArray*)self.user[@"likedOrgs"]).count];
    self.eventCount.text=[NSString stringWithFormat:@"%lu",((NSArray*)self.user[@"likedEvents"]).count];
    [self getLikedOrgInfo];
    [self getLikedEventInfo];
}
-(void)getLikedOrgInfo{
    
    self.likedOrgs=@[].mutableCopy;
    if(((NSArray*)self.user[@"likedOrgs"]).count!=0)
    {
        [MBProgressHUD showHUDAddedTo:self.orgCollectionView animated:YES];
        [[APIManager shared] getOrgsWithEIN:self.user[@"likedOrgs"] completion:^(NSArray * orgs, NSError * _Nonnull error) {
            if(error)
                [Helper displayAlert:@"Error getting liked organizations" withMessage:error.localizedDescription on:self];
            else{
                self.likedOrgs=orgs;
                NSLog(@"Success getting liked orgs");
                [self.orgCollectionView reloadData];
            }
            [MBProgressHUD hideHUDForView:self.orgCollectionView animated:YES];
        }];
    }
    else
        [self.orgCollectionView reloadData];
    
}
-(void)getLikedEventInfo{
    [MBProgressHUD showHUDAddedTo:self.eventCollectionView animated:YES];
    PFQuery *eventQuery= [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" containedIn:self.user[@"likedEvents"]];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting location of event" withMessage:error.localizedDescription on:self];
        else
        {
            self.likedEvents=objects;
            [self.eventCollectionView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.eventCollectionView animated:YES];
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
        //has not requested and not already friends (button is +Friends)
        if(!self.topButton.selected)
        {
            //send a request to this person
            [self.topButton setTitle:@"Requested" forState:UIControlStateSelected];
            self.topButton.selected=YES;
            [Helper addRequest:PFUser.currentUser forUser:self.user];
        }
        else if (self.topButton.selected && [self.topButton.titleLabel.text isEqualToString:@"Requested"])//if remove request
        {
            self.topButton.selected=NO;
            [Helper removeRequest:self.user forUser:PFUser.currentUser];
        }
        else//already friends and remove
        {
            //remove friend from friend list 
            self.topButton.selected=NO;
            self.privateView.alpha=SHOW_ALPHA;
            [Helper removeFriend:PFUser.currentUser toFriend:self.user];
            [Helper removeFriend:self.user toFriend:PFUser.currentUser];
        }
    }

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

- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error Logging out" withMessage:error.localizedDescription on:self];
        else
            NSLog(@"Success Logging out");
    }];
    //go back to login
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}
- (IBAction)didPullToRefresh:(id)sender {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, PULL_REFRESH_HEIGHT);
        [self.user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self loadProfile];
            [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
                   self.view.transform =CGAffineTransformIdentity;
                   self.view.alpha = SHOW_ALPHA;
               }];
        }];
    }];
}
- (IBAction)didTapAccept:(id)sender {
    self.requestView.alpha=HIDE_ALPHA;
    self.topButton.userInteractionEnabled=YES;
    [self.topButton setTitle:@"Friends" forState:UIControlStateSelected];
    self.topButton.selected=YES;
    self.privateView.alpha=HIDE_ALPHA;
    
    [Helper removeRequest:PFUser.currentUser forUser:self.user];
    [Helper addFriend:PFUser.currentUser toFriend:self.user];
    [Helper addFriend:self.user toFriend:PFUser.currentUser];
}
- (IBAction)didTapDecline:(id)sender {
    //remove request
    self.requestView.alpha=HIDE_ALPHA;
    self.topButton.userInteractionEnabled=YES;
    [Helper removeRequest:PFUser.currentUser forUser:self.user];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if((UICollectionView*)scrollView==self.eventCollectionView)
        return [UIImage imageNamed:@"emptyEvent"];
    else
        return [UIImage imageNamed:@"emptySprout"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text;
    if((UICollectionView*) scrollView== self.eventCollectionView)
        text = @"No Liked Events";
    else
        text = @"No Liked Orgizations";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    if((UICollectionView*)scrollView==self.eventCollectionView)
        return self.likedEvents.count==0;
    else
        return self.likedOrgs.count==0;
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
