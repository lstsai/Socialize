//
//  CreatePostViewController.m
//  Sprout
//
//  Created by laurentsai on 7/22/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CreatePostViewController.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "Constants.h"
@interface CreatePostViewController ()

@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileImage.file=PFUser.currentUser[@"profilePic"];
    [self.profileImage loadInBackground];
}
-(void) viewWillAppear:(BOOL)animated{
    self.postTextView.placeholderColor = [UIColor lightGrayColor];
    if(self.org)
        self.postTextView.placeholder=[ORG_POST_TEXT_PLACEHOLDER mutableCopy];
    else
        self.postTextView.placeholder=[EVENT_POST_TEXT_PLACEHOLDER mutableCopy];

}
- (IBAction)didTapDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didTapPost:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Post createPost:nil withDescription:self.postTextView.text withEvent:self.event withOrg:self.org withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
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
