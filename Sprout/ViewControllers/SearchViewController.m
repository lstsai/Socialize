//
//  SearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "SearchViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "OrgDetailsViewController.h"
#import "Helper.h"
@import GooglePlaces;
@interface SearchViewController ()<UISearchBarDelegate, CLLocationManagerDelegate, CreateViewControllerDelegate, GMSAutocompleteViewControllerDelegate>

@end

@implementation SearchViewController
/**
 Some set up tasks when the view is loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate=self;
    self.eventsVC=[self.childViewControllers objectAtIndex:EVENT_SEGMENT ];
    self.orgsVC=[self.childViewControllers objectAtIndex:ORG_SEGMENT];
    self.peopleVC=[self.childViewControllers objectAtIndex:PEOPLE_SEGMENT];
    self.locManager=[[LocationManager sharedInstance] init];
    self.citySearch=@"";
    self.stateSearch=@"";
    [self.peopleView setHidden:YES];
    [self.eventsView setHidden:YES];
    [self.orgsView setHidden:NO];
    
}
/**
Triggered when the user presses the logout button. Then logs the user out and shows the login page
 @param[in] sender the button the was pressed
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
Triggered when the user presses thesearch button. Calls the fetchResults method to get
 data and dismisses the keyboard
 @param[in] sender the button that was pressed
 */
- (IBAction)didTapSearch:(id)sender {
    [self fetchResults:nil];
    [self.searchBar endEditing:YES];
}
/**
 Calls the correct method in the child view controllers depending on the type of search indicated by the segmented control
 after the search button is pressed
 @param[in] refreshControl the refreshControl that is animating if there is one
 */
-(void) fetchResults:( UIRefreshControl * _Nullable )refreshControl{
    if([self.citySearch isEqualToString:@""]){
        self.citySearch=self.locManager.currentPlacemark.locality;
        self.locationCoord=self.locManager.currentLocation.coordinate;
    }
    if(self.searchControl.selectedSegmentIndex==ORG_SEGMENT)
    {
        self.orgsVC.searchText=self.searchBar.text;
        self.orgsVC.citySearch=self.citySearch;
        self.orgsVC.stateSearch=self.stateSearch;
        self.orgsVC.locationCoord=self.locationCoord;
        [self.orgsVC getOrgs:refreshControl];
    }
    else if(self.searchControl.selectedSegmentIndex==EVENT_SEGMENT){
        self.eventsVC.searchText=self.searchBar.text;
        self.eventsVC.locationCoord=self.locationCoord;
        [self.eventsVC getEvents:refreshControl];
    }
    else if(self.searchControl.selectedSegmentIndex==PEOPLE_SEGMENT){
        self.peopleVC.searchText=self.searchBar.text;
        [self.peopleVC getPeople:refreshControl];
    }
}
/**
Calls the correct method in the child view controllers depending on the type of search indicated by the segmented control.
 Shows an hides the view controllers depending on search type
@param[in] sender the semented control that was changed
*/
- (IBAction)didChangeSearch:(id)sender {
    if(self.searchControl.selectedSegmentIndex==ORG_SEGMENT)
    {
        self.orgsVC.searchText=self.searchBar.text;
        self.orgsVC.citySearch=self.citySearch;
        self.orgsVC.stateSearch=self.stateSearch;
        self.orgsVC.locationCoord=self.locationCoord;
        [self.orgsVC getOrgs:nil];
        [self.searchBar setPlaceholder:[ORG_SEARCH_PLACEHOLDER mutableCopy]];
        [self.eventsView setHidden:YES];
        [self.peopleView setHidden:YES];
        [self.orgsView setHidden:NO];
    }
    else if (self.searchControl.selectedSegmentIndex==EVENT_SEGMENT)
    {
        self.eventsVC.searchText=self.searchBar.text;
        self.eventsVC.locationCoord=self.locationCoord;
        [self.searchBar setPlaceholder:[EVENT_SEARCH_PLACEHOLDER mutableCopy]];
        [self.orgsView setHidden:YES];
        [self.peopleView setHidden:YES];
        [self.eventsView setHidden:NO];
    }
    else if(self.searchControl.selectedSegmentIndex==PEOPLE_SEGMENT){
        self.peopleVC.searchText=self.searchBar.text;
        [self.searchBar setPlaceholder:[PEOPLE_SEARCH_PLACEHOLDER mutableCopy]];
        [self.peopleVC getPeople:nil];
        [self.orgsView setHidden:YES];
        [self.eventsView setHidden:YES];
        [self.peopleView setHidden:NO];
    }
}
/**
 Delegate method for the CreateViewController. Called after the user creates an event to dismiss the view controller
 */
- (void)didCreateEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 Triggered when the user taps on the location field to select a location. Presents the Google Places
 Autocomplete view controller inorder to make it eaiser to choose a location. Filters the places data
 to only show cities.
 @param[in] sender the location field that was pressed
 */
- (IBAction)didEditLocation:(id)sender {
    [self.locationField resignFirstResponder];
    GMSAutocompleteViewController *gmsAutocompleteVC=[[GMSAutocompleteViewController alloc]init];
    gmsAutocompleteVC.delegate=self;
    // Specify a filter to only cities
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    gmsAutocompleteVC.autocompleteFilter = filter;
    [self presentViewController:gmsAutocompleteVC animated:YES completion:nil];
    
}
/**
Delegate method for the GMSAutocompleteViewController. Called when the user presses an autocomplete result. Updates
 the city and state and location coordinate properties of the viewcontroller to match the user's selection. dismisses the
 autocomplete view controller after
@param[in] viewController the GMSAutocompleteViewController that was used to select the result
 @param[in] place the place that the user selected
*/
- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    self.locationField.text=place.formattedAddress;
    self.locationCoord=place.coordinate;
    self.citySearch=place.name;
    for(GMSAddressComponent* comp in place.addressComponents)
    {
        if([comp.types containsObject:@"administrative_area_level_1"])
        {
            self.stateSearch=comp.shortName;
            break;
        }
    }
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"createEventSegue"])//takes the user to the create page
    {
        UINavigationController *navigationController = segue.destinationViewController;
        CreateViewController *createController = (CreateViewController*)navigationController.topViewController;
        createController.delegate = self;
    }
}





@end
