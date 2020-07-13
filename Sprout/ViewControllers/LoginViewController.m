//
//  LoginViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.alert= [UIAlertController alertControllerWithTitle:@"Error" message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //nothing
    }];
    [self.alert addAction:okAction];
}
- (IBAction)didTapLogin:(id)sender {
    [self.activityIndicator startAnimating];
    
    NSString *username= self.usernameField.text;
    NSString *password= self.passwordField.text;
    
    [self.alert setTitle:@"Error Logging In"];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil)
        {
            [self.alert setMessage:[NSString stringWithFormat: @"%@", error.description]];
            [self presentViewController:self.alert animated:YES completion:^{
                //nobthing
            }];
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
    [self.alert setTitle:@"Error Signing up"];
    
    if([newUser.username isEqualToString:@""] || [newUser.password isEqualToString:@""])
    {
        [self.alert setMessage:@"Username and/or password cannot be empty"];
        [self presentViewController:self.alert animated:YES completion:^{
             [self.activityIndicator stopAnimating];
        }];
    }
    else{//only signup if there was no error
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                [self.alert setMessage:[NSString stringWithFormat: @"%@", error.localizedDescription]];
                [self presentViewController:self.alert animated:YES completion:^{
                    //nobthing
                }];
            } else {
                NSLog(@"User registered successfully");
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
