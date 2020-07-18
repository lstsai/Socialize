//
//  LoginViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
- (IBAction)didTapLogin:(id)sender {
    [self.activityIndicator startAnimating];
    
    NSString *username= self.usernameField.text;
    NSString *password= self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil)
        {
            [AppDelegate displayAlert:@"Error Logging in" withMessage:error.localizedDescription on:self];
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
- (IBAction)didTapSignUp:(id)sender {
    [self.activityIndicator startAnimating];
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    PFObject *userAccessible= [PFObject objectWithClassName:@"UserAccessible"];
    userAccessible[@"username"]=newUser.username;
    
    if([newUser.username isEqualToString:@""] || [newUser.password isEqualToString:@""])
    {
        [AppDelegate displayAlert:@"Error Signing up" withMessage:@"Username and/or password cannot be empty" on:self];
        [self.activityIndicator stopAnimating];
    }
    else{//only signup if there was no error
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                [AppDelegate displayAlert:@"Error Signing up" withMessage:error.localizedDescription on:self];

            } else {
                NSLog(@"User registered successfully");
                [userAccessible saveInBackground];
                newUser[@"friendAccessible"]=userAccessible;
                [newUser saveInBackground];
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];//go to timeline after login
            }
            [self.activityIndicator stopAnimating];
        }];
    }
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
