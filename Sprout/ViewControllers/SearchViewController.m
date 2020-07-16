//
//  SearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "SearchViewController.h"
#import "OrgCell.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "OrgDetailsViewController.h"
#import "AppDelegate.h"
@interface SearchViewController ()<UISearchBarDelegate, CLLocationManagerDelegate>

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate=self;
    self.eventsVC=[self.childViewControllers objectAtIndex:EVENT_SEGMENT ];
    self.orgsVC=[self.childViewControllers objectAtIndex:ORG_SEGMENT];
    [self.eventsView setHidden:YES];
    [self.orgsView setHidden:NO];
}


- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error Logging out" withMessage:error.localizedDescription on:self];
        else
            NSLog(@"Success Logging out");
    }];
    //go back to login
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }

    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: SEARCH_DELAY
                                                        target: self
                                                      selector: @selector(fetchResults:)
                                                      userInfo: nil
                                                       repeats: NO];
}
- (IBAction)didChangeLocation:(id)sender {
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }
    // reschedule the search: in 1.0 second, call the searchForKeyword: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: SEARCH_DELAY
                                                        target: self
                                                      selector: @selector(fetchResults:)
                                                      userInfo: nil
                                                       repeats: NO];
}
-(void) fetchResults:( UIRefreshControl * _Nullable )refreshControl{
    
    if(self.searchControl.selectedSegmentIndex==ORG_SEGMENT)
    {
        self.orgsVC.searchText=self.searchBar.text;
        self.orgsVC.citySearch=[self.cityField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.orgsVC.stateSearch=[[self.stateField.text uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.orgsVC getOrgs:refreshControl];
    }
    else if(self.searchControl.selectedSegmentIndex==EVENT_SEGMENT){
        self.eventsVC.searchText=self.searchBar.text;
        self.eventsVC.citySearch=[self.cityField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.eventsVC.stateSearch=[[self.stateField.text uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.eventsVC getEvents:refreshControl];
    }
}

- (IBAction)didChangeSearch:(id)sender {
    if(self.searchControl.selectedSegmentIndex==ORG_SEGMENT)
    {
        self.orgsVC.searchText=self.searchBar.text;
        self.orgsVC.citySearch=[self.cityField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.orgsVC.stateSearch=[[self.stateField.text uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.orgsVC getOrgs:nil];
        [self.searchBar setPlaceholder:[ORG_SEARCH_PLACEHOLDER mutableCopy]];
        [self.eventsView setHidden:YES];
        [self.orgsView setHidden:NO];
    }
    else if (self.searchControl.selectedSegmentIndex==EVENT_SEGMENT)
    {
        self.eventsVC.searchText=self.searchBar.text;
        self.eventsVC.citySearch=[self.cityField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.eventsVC.stateSearch=[[self.stateField.text uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.eventsVC getEvents:nil];
        [self.searchBar setPlaceholder:[EVENT_SEARCH_PLACEHOLDER mutableCopy]];
        [self.orgsView setHidden:YES];
        [self.eventsView setHidden:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
