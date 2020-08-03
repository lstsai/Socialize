//
//  RequestsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "RequestsViewController.h"
#import "Helper.h"
#import <Parse/Parse.h>
#import "UIScrollView+EmptyDataSet.h"
#import "Constants.h"
#import "ProfileViewController.h"

@interface RequestsViewController ()< DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getFriendRequests];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView=[UIView new];
}
/**
 Refresh when the view appears
 */
-(void) viewWillAppear:(BOOL)animated{
    [self getFriendRequests];
}
/**
Makes a query to get all the friend requests the user has
*/
-(void) getFriendRequests{
    PFObject *selfAccess=[Helper getUserAccess:PFUser.currentUser];
    PFQuery *requestQuery= [PFQuery queryWithClassName:@"_User"];
    [requestQuery whereKey:@"objectId" containedIn:selfAccess[@"inRequests"]];
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting Friend Requests" withMessage:error.localizedDescription on:self];
        else
            self.friendRequests=objects;
        [self.tableView reloadData];
    }];
}
/**
Table view delegate method. returns a requestcell to be shown. 
@param[in] tableView the table that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RequestCell *reqCell=[tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];
    reqCell.requestUser=self.friendRequests[indexPath.row];
    [reqCell loadData];
    return reqCell;
}
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of requests
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of requests
*/
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendRequests.count;
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
Empty collection view delegate method. Returns the title to be displayed when there are no requests
@param[in] scrollView the collection view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Friend Requests";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty collection view delegate method. Returns if the empty view should be shown
@param[in] scrollView the collection view that is empty
@return if the empty view shouls be shown
 YES: if there are no requests
 NO: there are requests
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.friendRequests.count==0;
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
        profileVC.user=self.friendRequests[tappedIndex.row];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}




@end
