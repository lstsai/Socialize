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
#import "UIScrollView+EmptyDataSet.h"
#import "Constants.h"

@interface CommentsViewController ()<UITableViewDelegate, UITableViewDataSource, CommentCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.emptyDataSetSource=self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
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
    if(![Helper connectedToInternet])
        [commentQuery fromLocalDatastore];
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
            [PFObject pinAllInBackground:objects withName:@"comment"];
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
/**
Empty table view delegate method. Returns the image to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"comment"];
}
/**
Empty table view delegate method. Returns the title to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Comments to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns the message to be displayed when there are no users
@param[in] scrollView the collection view that is empty
@return the message to be shown
*/
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Be the first to leave a comment!";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty table view delegate method. Returns if the empty view should be shown
@param[in] scrollView the table view that is empty
@return if the empty view shouls be shown
 YES: if there are no posts
 NO: there are posts
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.comments.count==0;
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
