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
#import "MessagingViewController.h"
@interface DMViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.searchBar.delegate=self;
    self.isSearch=NO;
    self.messageThreads=[[NSMutableArray alloc] init];
    self.messageUsers=[[NSMutableArray alloc] init];

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
    [userQ whereKey:@"username" containsString:self.searchBar.text];
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
    DMCell* dmc=[tableView dequeueReusableCellWithIdentifier:@"DMCell" forIndexPath:indexPath];
    if(self.isSearch)
    {
        dmc.user=self.friends[indexPath.row];
        [dmc loadData];
    }
    else{
        dmc.latestMessage=self.messageThreads[indexPath.row];;
        dmc.user=self.messageUsers[indexPath.row];
        [dmc loadData];
    }
    return dmc;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isSearch)
        return self.friends.count;
    else
        return self.messageUsers.count;
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
