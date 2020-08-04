//
//  EditOrgViewController.m
//  Sprout
//
//  Created by laurentsai on 8/4/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EditOrgViewController.h"
#import "Constants.h"
#import "Helper.h"
@interface EditOrgViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation EditOrgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    [self loadCurrentInfo];
}
-(void) loadCurrentInfo{
    self.addressField.text=self.claimedOrg.address;
    self.categoryField.text=self.claimedOrg.category;
    self.causeField.text=self.claimedOrg.cause;
    self.missionTextView.text =self.claimedOrg.missionStatement;
    self.nameField.text =self.claimedOrg.name;
    
    self.orgImage.file =self.claimedOrg.image;
    [self.orgImage loadInBackground];

    self.taglineField.text =self.claimedOrg.tagLine;
    self.websiteField.text =self.claimedOrg.website;
}
/**
 Called when the keyboard appears on screen, moves the view up if it is blocking the views
 @param[in] notification the notification to alert the keyboard appeared
 */
-(void)keyboardOnScreen:(NSNotification *)notification{
    if(!self.causeField.isEditing && !self.categoryField.isEditing && !self.nameField.isEditing &&! self.taglineField.isEditing)
    {
        NSDictionary *info = notification.userInfo;
        NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
        CGRect rawFrame= [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
            self.view.transform=CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -1*keyboardFrame.size.height + CELL_TOP_OFFSET*1.5);
        }];
    }
}
/**
 Called when the keyboard will hide on screen, moves the view back down
 @param[in] notification the notification to alert the keyboard will hide
 */
-(void)keyboardOffScreen:(NSNotification *)notification{
    [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
        self.view.transform=CGAffineTransformIdentity;
    }];
}

/**
Triggered when the user presses the backdrop image. Presents the image picker(photo album) so the user can choose an image for the event.
@param[in] sender the background image that was tapped
*/
- (IBAction)didTapImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    UIAlertController* imageAlert = [UIAlertController alertControllerWithTitle:@"Choose an Image Source" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
    UIAlertAction* camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
           [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    UIAlertAction* library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
           [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [imageAlert addAction:camera];
    [imageAlert addAction:library];
    [imageAlert addAction:cancel];
    
    [self presentViewController:imageAlert animated:YES completion:nil];
}

/**
Triggered when the user chooses an image to be the event image. Sets the background image to be the image selected
@param[in] picker the image picker that has the selected image
 @param[in] info the dictionary that contains the picked image
*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.orgImage.alpha=SHOW_ALPHA;
    [self.orgImage setImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 Triggered when the user saves the information typed, it will update the claimed org
 @param[in] sender the save button
 */
- (IBAction)didTapSave:(id)sender {
    self.claimedOrg.address=self.addressField.text;
    self.claimedOrg.category=self.categoryField.text;
    self.claimedOrg.cause=self.causeField.text;
    self.claimedOrg.image=[Helper getPFFileFromImage:self.orgImage.image withName:self.claimedOrg.ein];
    self.claimedOrg.missionStatement=self.missionTextView.text;
    self.claimedOrg.name=self.nameField.text;
    self.claimedOrg.tagLine=self.taglineField.text;
    self.claimedOrg.website=self.websiteField.text;
    [self.claimedOrg saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
            [Helper displayAlert:@"Successfully Saved Information" withMessage:@"" on:self];
    }];
}
/**
 Triggered when the user taps anywhere on the view, dismiss the keyboard
 */
- (IBAction)didTapView:(id)sender {
    [self.addressField endEditing:YES];
    [self.categoryField endEditing:YES];
    [self.causeField endEditing:YES];
    [self.missionTextView endEditing:YES];
    [self.nameField endEditing:YES];
    [self.taglineField endEditing:YES];
    [self.websiteField endEditing:YES];
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
