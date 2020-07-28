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
/**
 Fetches data about the user from Parse and updates the views of the page accordingly
 */
-(void)loadProfile{
    
   
    PFObject *fAccess=[Helper getUserAccess:PFUser.currentUser];
    if(self.user.username==PFUser.currentUser.username)
    {
        [self.topButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.topButton setTitle:@"Save" forState:UIControlStateSelected];
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
    self.bioLabel.text=self.user[@"bio"];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
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
/**
 Calls the helper method to fetch the organizations teh user has liked
 */
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
/**
Creates a parse query and fetches the events the user has liked
*/
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
/**
Collection view delegate method. returns a cell to be shown at the index path for a collection view.
 If the collection view calling the method is the events one, creates an event cell.
 else will create an organization cell
@param[in] collectionView the collection view that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
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
/**
Collection view delegate method. returns the number of sections that the collection has. Each collection only has
 one section. if the collection view calling the method is the events one, will return the number of liked events
 else will return the number of liked organizations
@param[in] collectionView the collection view that is calling this method
@param[in] section the section in question
@return the number of liked objects
*/
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView==self.eventCollectionView)
        return self.likedEvents.count;
    else
        return self.likedOrgs.count;
}
/**
 Triggered when the user presses the top button to request/unfriends a user.
 reconfigues the button to match the current state, and calls the correct helper methods.
 If the profile is for the current user, it allows the user to change their bio
 @param[in] sender the button that was pressed
 */
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
    else
    {
        if(!self.topButton.selected)
        {
            //User wants to edit profile
            self.topButton.selected=YES;
            self.bioField.alpha=SHOW_ALPHA;
        }
        else
        {
            self.topButton.selected=NO;
            self.bioField.alpha=HIDE_ALPHA;
            self.bioLabel.text=self.bioField.text;
            PFUser.currentUser[@"bio"]=self.bioField.text;
            [PFUser.currentUser saveInBackground];
        }
    }

}
/**
 sets up the image pickers for the background image and the profile image view
 */
-(void) setupImagePicker{
    self.profileImagePicker=[UIImagePickerController new];
    self.profileImagePicker.allowsEditing=YES;
    self.profileImagePicker.delegate=self;
    
    self.backgroundImagePicker=[UIImagePickerController new];
    self.backgroundImagePicker.allowsEditing=YES;
    self.backgroundImagePicker.delegate=self;
}
/**
Triggered when the user presses the profile or backdrop image. Presents the image picker(photo album or camera) so the user can choose an image for the
 tapped image view.
@param[in] sender the imageview  that was tapped
*/
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
/**
Triggered when the user chooses an image to be the profile/background image. Sets the image view to be the image selected
@param[in] picker the image picker that has the selected image
 @param[in] info the dictionary that contains the picked image
*/
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
/**
Triggered when the user taps the logout button. Logs the user out and
 presents the login page.
@param[in]  sender the logout button
*/
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
/**
Mimics the pull to refresh function of the table and collecton views. Animates the view to look like the
 user is pulling, and refreshes the user data.
@param[in]  sender the sqipe gesture recognizer
*/
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
/**
Triggered when the user accepts the friend request from the profile page, calls the
 helper methods to update user data. removes the private view so the user can see
 the other users data
@param[in]  sender the accept buttons
*/
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
/**
Triggered when the user declins the friend request from the profile page, calls the
 helper methods to update user data
@param[in]  sender the delete buttons
*/
- (IBAction)didTapDecline:(id)sender {
    //remove request
    self.requestView.alpha=HIDE_ALPHA;
    self.topButton.userInteractionEnabled=YES;
    [Helper removeRequest:PFUser.currentUser forUser:self.user];
}
/**
Empty collection view delegate method. Returns the image to be displayed when there are no events/orgs
@param[in] scrollView the collection view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if((UICollectionView*)scrollView==self.eventCollectionView)
        return [UIImage imageNamed:@"emptyEvent"];
    else
        return [UIImage imageNamed:@"emptySprout"];
}
/**
Empty collection view delegate method. Returns the title to be displayed when there are no events/orgs
@param[in] scrollView the collection view that is empty
@return the title to be shown
*/
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
/**
Empty collection view delegate method. Returns if the empty view should be shown
@param[in] scrollView the collection view that is empty
@return if the empty view shouls be shown
 YES: if there are no events/orgs
 NO: there are events/orgs
*/
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
    if([segue.identifier isEqualToString:@"orgSegue"])//takes the user to the orgs details page
    {
        OrgDetailsViewController *orgVC= segue.destinationViewController;
        UICollectionViewCell *tappedCell=sender;
        NSIndexPath *tappedIndex=[self.orgCollectionView indexPathForCell:tappedCell];
        orgVC.org=self.likedOrgs[tappedIndex.item];
        [self.orgCollectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
    else if([segue.identifier isEqualToString:@"eventSegue"])//takes user to the events details page
    {
        EventDetailsViewController *eventVC= segue.destinationViewController;
        UICollectionViewCell *tappedCell=sender;
        NSIndexPath *tappedIndex=[self.eventCollectionView indexPathForCell:tappedCell];
        eventVC.event=self.likedEvents[tappedIndex.item];
        [self.eventCollectionView deselectItemAtIndexPath:tappedIndex animated:YES];
    }
}


@end
