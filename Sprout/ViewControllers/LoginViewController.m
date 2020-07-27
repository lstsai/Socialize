//
//  LoginViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "LoginViewController.h"
#import "Helper.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
/**
 Triggered when the user taps the login button
 @param[in] sender the button that was pressed
 retrieves the username and password the user enters and attempts to login the user
 with those credentials through Parse. Displays an error if there is one. Presents the search page
 if successful login
 */
- (IBAction)didTapLogin:(id)sender {
    [self.activityIndicator startAnimating];
    
    NSString *username= self.usernameField.text;
    NSString *password= self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil)
        {
            [Helper displayAlert:@"Error Logging in" withMessage:error.localizedDescription on:self];
            NSLog(@"User log in failed: %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
        [self.activityIndicator stopAnimating];

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

@end
