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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate=self;
    [self setupSegmentControl];
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
-(void) setupSegmentControl{
    self.searchControl.backgroundColor=[UIColor whiteColor];
    self.searchControl.tintColor=[UIColor clearColor];    
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
- (IBAction)didTapSearch:(id)sender {
    [self fetchResults:nil];
}

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
- (void)didCreateEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    [Helper displayAlert:@"Error with location autocomplete" withMessage:error.localizedDescription on:self];

}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"createEventSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        CreateViewController *createController = (CreateViewController*)navigationController.topViewController;
        createController.delegate = self;
    }
}





@end
