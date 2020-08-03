//
//  DMViewController.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "DMViewController.h"
#import "DMCell.h"
#import "Helper.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MessagingViewController.h"
#import "Constants.h"
#import "FriendCell.h"
@interface DMViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.searchBar.delegate=self;
    self.tableView.emptyDataSetSource=self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.isSearch=NO;
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getMessageThreads:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard
    [self getMessageThreads:nil];
}
/**
Triggered when the user presses thesearch button on the keyboard. Calls the fetchResults method to get
 data and dismisses the keyboard
 @param[in] searchBar the search bar being searched
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.isSearch=YES;
    [self.searchBar endEditing:YES];
    [self searchFriends];
}
-(void) getMessageThreads:(UIRefreshControl* _Nullable)refreshControl{
    PFObject* selfUserAccess=[Helper getUserAccess:PFUser.currentUser];
    NSArray* messageThreads=selfUserAccess[@"messageThreads"];
    self.unreadMessages=selfUserAccess[@"unreadMessages"];
    self.messageThreads=[[NSMutableArray alloc] init];
    self.messageUsers=[[NSMutableArray alloc] init];
    for(NSString* userID in messageThreads)
    {
        PFUser* user= [PFQuery getUserObjectWithId:userID];
        PFQuery* messageQ=[PFQuery queryWithClassName:@"Message"];
        [messageQ includeKey:@"sender"];
        [messageQ includeKey:@"receiver"];
        [messageQ whereKey:@"sender" containedIn:@[user, PFUser.currentUser]];
        [messageQ whereKey:@"receiver" containedIn:@[user, PFUser.currentUser]];
        [messageQ orderByDescending:@"createdAt"];
        [self.messageThreads addObject:[messageQ getFirstObject]];
        [self.messageUsers addObject:user];
    }
    if(refreshControl)
        [refreshControl endRefreshing];
    [self.tableView reloadData];
}
-(void) searchFriends{
    if([self.searchBar.text isEqualToString:@""])
    {
        self.isSearch=NO;
        [self.tableView reloadData];
        return;
    }
    PFObject* selfUserAccess=[Helper getUserAccess:PFUser.currentUser];
    NSArray* friendsID=selfUserAccess[@"friends"];
    PFQuery* userQ=[PFQuery queryWithClassName:@"_User"];
    [userQ whereKey:@"objectId" containedIn:friendsID];
    [userQ whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"(?i)%@",self.searchBar.text]];
    [userQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error getting friends" withMessage:error.localizedDescription on:self];
        else{
            self.friends=objects;
            [self.tableView reloadData];
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(self.isSearch)
    {
        FriendCell* friendc=[tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
        friendc.user=self.friends[indexPath.row];
        [friendc loadDetails];
        return friendc;
    }
    else{
        DMCell* dmc=[tableView dequeueReusableCellWithIdentifier:@"DMCell" forIndexPath:indexPath];
        dmc.latestMessage=self.messageThreads[indexPath.row];;
        dmc.user=self.messageUsers[indexPath.row];
        dmc.unread=[self.unreadMessages containsObject:((PFUser*)self.messageUsers[indexPath.row]).objectId];
        [dmc loadData];
        return dmc;

    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isSearch)
        return self.friends.count;
    else
        return self.messageUsers.count;
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
    NSString *text = @"No Messages";
    
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
    NSString *text = @"Search for a friend to Message!";
    
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
    return self.messageThreads.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"messagesSegue"])
    {
        UITableViewCell* tappedCell=sender;
        NSIndexPath* tappedIndex=[self.tableView indexPathForCell:tappedCell];
        MessagingViewController* messageVC=segue.destinationViewController;
        if(self.isSearch)
            messageVC.user=self.friends[tappedIndex.row];
        else
            messageVC.user=self.messageUsers[tappedIndex.row];
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
}

@end
