//
//  RequestsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "RequestsViewController.h"
#import "RequestCell.h"
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RequestCell *reqCell=[tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];
    reqCell.requestUser=self.friendRequests[indexPath.row];
    [reqCell loadData];
    return reqCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendRequests.count;
}
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptyFriendRequest"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Friend Requests";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.friendRequests.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profileSegue"])
    {
        ProfileViewController *profileVC= segue.destinationViewController;
        UITableViewCell *tappedCell=sender;
        NSIndexPath* tappedIndex= [self.tableView indexPathForCell:tappedCell];
        profileVC.user=self.friendRequests[tappedIndex.row];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}




@end
