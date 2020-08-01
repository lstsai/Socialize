//
//  CreateViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CreateViewController.h"
#import "Constants.h"
#import "Event.h"
#import "MBProgressHUD.h"
#import "Helper.h"
@import GooglePlaces;

@interface CreateViewController ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, GMSAutocompleteViewControllerDelegate>

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailsTextView.delegate=self;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    [self setupDatePicker];
    
}
/**
 Set the input type of the start and end time fields to be date pickers
 */
-(void) setupDatePicker{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setMinuteInterval:MINUTE_INTERVAL];
    [datePicker addTarget:self action:@selector(didUpdateSDate:) forControlEvents:UIControlEventValueChanged];
    [self.startDateField setInputView:datePicker];
    
    UIDatePicker *eDatePicker = [[UIDatePicker alloc]init];
    [eDatePicker setDate:[NSDate date]];
    [eDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [eDatePicker setMinuteInterval:MINUTE_INTERVAL];
    [eDatePicker addTarget:self action:@selector(didUpdateEDate:) forControlEvents:UIControlEventValueChanged];
    [self.endDateField setInputView:eDatePicker];

}
/**
 Triggered when the user changes the start date field and changes the field's text accordingly
 @param[in] sender the start date field
 */
-(void) didUpdateSDate:(id)sender{
    UIDatePicker *picker = (UIDatePicker*)self.startDateField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.startDateField.text = [dateFormat stringFromDate:eventDate];
}
/**
Triggered when the user changes the end date field and changes the field's text accordingly
@param[in] sender the end date field
*/
-(void) didUpdateEDate:(id)sender{
    UIDatePicker *picker = (UIDatePicker*)self.endDateField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.endDateField.text = [dateFormat stringFromDate:eventDate];
}
/**
Triggered when the user presses the create/post button for the event. Gathers the information the user has
 entered about the event and creates a parse event. Displays errors if applicable. calls the delegate method
 to dismiss the view controller
@param[in] sender the create/post button
*/
- (IBAction)didTapCreate:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIDatePicker *spicker = (UIDatePicker*)self.startDateField.inputView;
    UIDatePicker *epicker = (UIDatePicker*)self.endDateField.inputView;
    
    if([self.eventNameField.text isEqualToString:@""])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Helper displayAlert:@"Error Creating Event" withMessage:@"Please enter a name for the event" on:self];
    }
    else if([self.startDateField.text isEqualToString:@""])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Helper displayAlert:@"Error Creating Event" withMessage:@"Please enter a start time" on:self];
    }
    
    else if([self.locationField.text isEqualToString:@""])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Helper displayAlert:@"Error Creating Event" withMessage:@"Please enter a location for the event" on:self];
    }
    else{
        [Event postEvent:self.eventImage.image withName:self.eventNameField.text withSTime:spicker.date withETime:epicker.date withLocation:self.locationPoint withStreetAdress:self.locationField.text withDetails:self.detailsTextView.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded)
            {
                NSLog(@"Success creating event and post");
                [self.delegate didCreateEvent];
            }
            else{
                [Helper displayAlert:@"Error creating event" withMessage:error.localizedDescription on:self];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}
/**
Triggered when the user presses the cancel button. Dismisses the view controller
@param[in] sender the dismiss button
*/
- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
Triggered when the user presses the backdrop image. Presents the image picker(photo album) so the user can choose an image for the event.
@param[in] sender the background image that was tapped
*/
- (IBAction)didTapImagePicker:(id)sender {
    
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
    self.eventImage.alpha=1;
    [self.eventImage setImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
Triggered when the user presses the location field. Presents the GMSAutocompleteViewController so that the user
 can easily select a location for the event
@param[in] sender the location field
*/
- (IBAction)didEditLocation:(id)sender {
    [self.locationField resignFirstResponder];
    GMSAutocompleteViewController *gmsAutocompleteVC=[[GMSAutocompleteViewController alloc]init];
    gmsAutocompleteVC.delegate=self;
    [self presentViewController:gmsAutocompleteVC animated:YES completion:nil];
    
}
/**
 Called when the keyboard appears on screen, moves the view up in order to show the text field
 @param[in] notification the notification to alert the keyboard appeared
 */
-(void)keyboardOnScreen:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame= [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
        self.view.transform=CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -1*keyboardFrame.size.height + CELL_TOP_OFFSET*1.5);
    }];
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
Triggered when the user taps out of the text view
 @param[in] sender the tap gesture recognizer
*/
- (IBAction)didTapOutside:(id)sender {
    [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
        self.view.layer.transform=CATransform3DIdentity;
        [self.detailsTextView endEditing:YES];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/**
Delegate method for the GMSAutocompleteViewController. Called when the user presses an autocomplete result. Updates
 the location properties of the viewcontroller to match the user's selection. dismisses the
 autocomplete view controller after
@param[in] viewController the GMSAutocompleteViewController that was used to select the result
 @param[in] place the place that the user selected
*/
- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    self.locationField.text=place.formattedAddress;
    self.locationPoint= [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
Delegate method for the GMSAutocompleteViewController. Triggered when there is an error with autocomplete. Then displays the alert to the user
@param[in] viewController the GMSAutocompleteViewController which had an error
 @param[in] error the error that occured
*/
- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    [Helper displayAlert:@"Error with location autocomplete" withMessage:error.localizedDescription on:self];

}
/**
Delegate method for the GMSAutocompleteViewController. Triggered when the user cancels the location search
@param[in] viewController the GMSAutocompleteViewController to be dismissed
*/
- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
