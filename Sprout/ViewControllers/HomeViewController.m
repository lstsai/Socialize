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
#import "Helper.h"
#import "EventDetailsViewController.h"
#import "OrgDetailsViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ProfileViewController.h"

@interface HomeViewController ()<CreateViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, OrgPostCellDelegate, EventPostCellDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self setupLoadingIndicators];
    [self performSelectorInBackground:@selector(getPosts:) withObject:nil];
}
-(void) viewWillAppear:(BOOL)animated{
    [self performSelectorInBackground:@selector(getPosts:) withObject:nil];
}
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getPosts:) forControlEvents:UIControlEventValueChanged];//add an event listener
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
    [self getPosts:nil];
}

-(void) getPosts:( UIRefreshControl * _Nullable )refreshControl{
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        if(error)
            [Helper displayAlert:@"Error getting friends" withMessage:error.localizedDescription on:self];
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
                    [Helper displayAlert:@"Error Loading Posts" withMessage:error.localizedDescription on:self];
                }
                else{
                    self.posts=[objects mutableCopy];
                    [self.tableView reloadData];
                }
                if(refreshControl)
                    [refreshControl endRefreshing];
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
        epc.delegate=self;
        [epc loadData];
        return epc;
    }
    else{
        OrgPostCell *opc=[tableView dequeueReusableCellWithIdentifier:@"OrgPostCell"];
        opc.post=currPost;
        opc.delegate=self;
        [opc loadData];
        return opc;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"share-post"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Posts to Show";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Add friends, like some events or organizations, or create a post!";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:EMPTY_MESSAGE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.posts.count==0;
}
-(void) didTapUser:(PFUser *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
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
    else if ([segue.identifier isEqualToString:@"profileSegue"]){
        ProfileViewController* profileVC= segue.destinationViewController;
        profileVC.user=(PFUser*)sender;
    }
    
}



@end
