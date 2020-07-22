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

@interface CreateViewController ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate>

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    
}
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
-(void) didUpdateSDate:(id)sender{
    UIDatePicker *picker = (UIDatePicker*)self.startDateField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.startDateField.text = [dateFormat stringFromDate:eventDate];
}

-(void) didUpdateEDate:(id)sender{
    UIDatePicker *picker = (UIDatePicker*)self.endDateField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.endDateField.text = [dateFormat stringFromDate:eventDate];
}

- (IBAction)didTapCreate:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIDatePicker *spicker = (UIDatePicker*)self.startDateField.inputView;
    UIDatePicker *epicker = (UIDatePicker*)self.endDateField.inputView;

    [Event postEvent:self.eventImage.image withName:self.eventNameField.text withSTime:spicker.date withETime:epicker.date withLocation:self.locationPoint withStreetAdress:self.locationField.text withDetails:self.detailsTextView.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
        {
            NSLog(@"Success creating event and post");
            [self.delegate didCreateEvent];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [Helper displayAlert:@"Error creating event" withMessage:error.localizedDescription on:self];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapImagePicker:(id)sender {
    
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
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
    self.eventImage.alpha=1;
    [self.eventImage setImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didEditLocation:(id)sender {
    [self.locationField resignFirstResponder];
    GMSAutocompleteViewController *gmsAutocompleteVC=[[GMSAutocompleteViewController alloc]init];
    gmsAutocompleteVC.delegate=self;
    [self presentViewController:gmsAutocompleteVC animated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    self.locationField.text=place.formattedAddress;
    self.locationPoint= [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    [Helper displayAlert:@"Error with location autocomplete" withMessage:error.localizedDescription on:self];

}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
