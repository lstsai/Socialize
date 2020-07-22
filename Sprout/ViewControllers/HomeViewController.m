//
//  HomeViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "HomeViewController.h"
#import "EventPostCell.h"
#import "OrgPostCell.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "EventDetailsViewController.h"
#import "OrgDetailsViewController.h"
@interface HomeViewController ()<CreateViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self setupLoadingIndicators];
    [self performSelectorInBackground:@selector(getPosts) withObject:nil];
}
-(void) viewWillAppear:(BOOL)animated{
    [self getPosts];
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getPosts) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}
-(void) didCreateEvent{
    [self getPosts];
}

-(void) getPosts{
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        if(error)
            [AppDelegate displayAlert:@"Error getting friends" withMessage:error.localizedDescription on:self];
        else{
            PFQuery *postsQ= [PFQuery queryWithClassName:@"Post"];
            [postsQ orderByDescending:@"createdAt"];
            [postsQ includeKey:@"event"];
            [postsQ includeKey:@"author"];
            NSArray *friendsAndSelf=[friends arrayByAddingObject:PFUser.currentUser];
            [postsQ whereKey:@"author" containedIn:friendsAndSelf];
            [postsQ setLimit:RESULTS_SIZE];
            [postsQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(error)
                {
                    [AppDelegate displayAlert:@"Error Loading Posts" withMessage:error.localizedDescription on:self];
                }
                else{
                    self.posts=[objects mutableCopy];
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Post *currPost=self.posts[indexPath.row];
    if(currPost.event)
    {
        EventPostCell *epc=[tableView dequeueReusableCellWithIdentifier:@"EventPostCell"];
        epc.post=currPost;
        [epc loadData];
        return epc;
    }
    else{
        OrgPostCell *opc=[tableView dequeueReusableCellWithIdentifier:@"OrgPostCell"];
        opc.post=currPost;
        [opc loadData];
        return opc;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"CreateSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        CreateViewController *createController = (CreateViewController*)navigationController.topViewController;
        createController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"eventSegue"])
    {
        EventDetailsViewController *evc= segue.destinationViewController;
        UITableViewCell* tappedcell=sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedcell];
        evc.event=((EventPostCell*)tappedcell).event;
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"orgSegue"])
    {
        OrgDetailsViewController *ovc= segue.destinationViewController;
        UITableViewCell* tappedcell=sender;
        NSIndexPath *tappedIndex= [self.tableView indexPathForCell:tappedcell];
        ovc.org=((OrgPostCell*)tappedcell).org;
        [self.tableView deselectRowAtIndexPath:tappedIndex animated:YES];
    }
    
}



@end
