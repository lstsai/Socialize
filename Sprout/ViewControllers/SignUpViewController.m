//
//  SignUpViewController.m
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "SignUpViewController.h"
#import "Helper.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapSignUp:(id)sender {
    [self.activityIndicator startAnimating];
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    PFObject *userAccessible= [PFObject objectWithClassName:@"UserAccessible"];
    userAccessible[@"username"]=newUser.username;
    
    if([newUser.username isEqualToString:@""] || [newUser.password isEqualToString:@""] || [newUser.email isEqualToString:@""])
    {
        [Helper displayAlert:@"Error Signing up" withMessage:@"Fields cannot be empty" on:self];
        [self.activityIndicator stopAnimating];
    }
    else{//only signup if there was no error
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                [Helper displayAlert:@"Error Signing up" withMessage:error.localizedDescription on:self];

            } else {
                NSLog(@"User registered successfully");
                [userAccessible saveInBackground];
                newUser[@"friendAccessible"]=userAccessible;
                [newUser saveInBackground];
                [self performSegueWithIdentifier:@"signupSegue" sender:nil];//go to timeline after login
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
