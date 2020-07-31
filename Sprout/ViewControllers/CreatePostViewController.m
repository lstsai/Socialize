//
//  CreatePostViewController.m
//  Sprout
//
//  Created by laurentsai on 7/22/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CreatePostViewController.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "Constants.h"
@interface CreatePostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.file=PFUser.currentUser[@"profilePic"];
    [self.profileImage loadInBackground];
}
/**
 Determine the placehodler text to be shown depending on whether this is a post for an org or event
 */
-(void) viewWillAppear:(BOOL)animated{
    self.postTextView.placeholderColor = [UIColor lightGrayColor];
    if(self.org)
        self.postTextView.placeholder=[ORG_POST_TEXT_PLACEHOLDER mutableCopy];
    else
        self.postTextView.placeholder=[EVENT_POST_TEXT_PLACEHOLDER mutableCopy];
    
    if(self.isGroupPost)
    {
        self.attachImageLabel.alpha=SHOW_ALPHA;
        self.attachedImage.alpha=SHOW_ALPHA*0.3;
    }
    else
    {
        self.attachImageLabel.alpha=HIDE_ALPHA;
        self.attachedImage.alpha=HIDE_ALPHA;
    }

}
/**
Triggered when the user presses the cancel button, dismisses the view controller
 @param[in] sender the cancel button
 */
- (IBAction)didTapDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
Triggered when the user presses the pst button, calls the helper method to create a post
 dismisses the view controller
 @param[in] sender the post button
 */
- (IBAction)didTapPost:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Post createPost:self.attachedImage.image withDescription:self.postTextView.text withEvent:self.event withOrg:self.org groupPost:self.isGroupPost withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate didCreatePost];
    }];
}
/**
Triggered when the user presses the backdrop image. Presents the image picker(photo album) so the user can choose an image for the event.
@param[in] sender the background image that was tapped
*/
- (IBAction)didTapImagePicker:(id)sender {
    
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
/**
Triggered when the user chooses an image to be the event image. Sets the background image to be the image selected
@param[in] picker the image picker that has the selected image
 @param[in] info the dictionary that contains the picked image
*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.attachedImage.alpha=SHOW_ALPHA;
    [self.attachedImage setImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
