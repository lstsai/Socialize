//
//  FriendsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "FriendsViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FriendCell.h"
#import "Constants.h"
#import "ProfileViewController.h"
#import "Helper.h"
@interface FriendsViewController ()< DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView=[UIView new];
    [self getFriends];
}
/**
Makes a query to get all the friends the user has
*/
-(void) getFriends{
    PFObject *selfAccess=[Helper getUserAccess:self.user];
    PFQuery *requestQuery= [PFQuery queryWithClassName:@"_User"];
    [requestQuery whereKey:@"objectId" containedIn:selfAccess[@"friends"]];
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting Friend Requests" withMessage:error.localizedDescription on:self];
        else
            self.friends=objects;
        [self.tableView reloadData];
    }];
}
/**
Table view delegate method. returns a FriendCell to be shown.
@param[in] tableView the table that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FriendCell *friendCell=[tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    friendCell.user=self.friends[indexPath.row];
    [friendCell loadDetails];
    return friendCell;
}
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of friends
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of friends
*/
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}
/**
Empty collection view delegate method. Returns the image to be displayed when there are no friends
@param[in] scrollView the collection view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptyFriendRequest"];
}
/**
Empty collection view delegate method. Returns the title to be displayed when there are no friends
@param[in] scrollView the collection view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Friends";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns the message to be displayed when there are no friends
@param[in] scrollView the collection view that is empty
@return the message to be shown
*/
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Add some friends to see them here";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns if the empty view should be shown
@param[in] scrollView the collection view that is empty
@return if the empty view shouls be shown
 YES: if there are no friends
 NO: there are friends
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.friends.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profileSegue"])//takes the user to the profile page
    {
        ProfileViewController *profileVC= segue.destinationViewController;
        UITableViewCell *tappedCell=sender;
        NSIndexPath* tappedIndex= [self.tableView indexPathForCell:tappedCell];
        profileVC.user=self.friends[tappedIndex.row];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}
@end
