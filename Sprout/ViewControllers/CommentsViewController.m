//
//  CommentsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CommentsViewController.h"
#import "Comment.h"
#import "CommentCell.h"
#import "ProfileViewController.h"
@interface CommentsViewController ()<UITableViewDelegate, UITableViewDataSource, CommentCellDelegate>

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
     //Do any additional setup after loading the view.
    [self loadProfileImage];
    [self getPostComments];
    [self.tableView reloadData];
}

-(void) loadProfileImage{
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.layer.cornerRadius=self.profileImage.bounds.size.width/2;
    if(PFUser.currentUser[@"profilePic"])
    {
        self.profileImage.file=PFUser.currentUser[@"profilePic"];
        [self.profileImage loadInBackground];
    }
}

- (void) getPostComments{
    PFQuery *commentQuery= [PFQuery queryWithClassName:@"Comment"];
    [commentQuery orderByDescending:@"createdAt"];
    [commentQuery includeKey:@"post"];
    [commentQuery includeKey:@"author"];
    [commentQuery includeKey:@"profilePicture"];
    [commentQuery whereKey:@"post" equalTo:self.post];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
        {
            NSLog(@"Error getting comments %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"Success getting comments");
            self.comments=objects;
            [self.tableView reloadData];
        }
    }];
}
- (IBAction)didTapDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapPost:(id)sender {
    [Comment postComment:self.commentTextField.text forPost:self.post withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error)
            {
                NSLog(@"Error posting comment %@", error.localizedDescription);
            }
            else
            {
                NSLog(@"Success posting comment");
                //increment comment count
                self.commentTextField.text=@"";
                [self.commentTextField endEditing:YES];
                [self getPostComments];
            }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommentCell *currCell= [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    currCell.comment=self.comments[indexPath.row];
    currCell.delegate=self;
    [currCell loadComment];
    return currCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (void)didTapUser:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"commentProfileSegue" sender:user];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"commentProfileSegue"])
    {
        ProfileViewController *profileVC= segue.destinationViewController;
        profileVC.user=(PFUser*) sender;
    }
}

@end
