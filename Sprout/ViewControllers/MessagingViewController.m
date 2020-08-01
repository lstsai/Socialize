//
//  MessagingViewController.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "MessagingViewController.h"
#import "IncomingMessageCell.h"
#import "OutgoingMessageCell.h"
#import "Message.h"
#import "Helper.h"
#import "Constants.h"
@interface MessagingViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);//flip the table view upside down
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self setupLoadingIndicators];
    [self getMessages:nil];
}
/**
 setup the refresh control and infinite scroll indicators
 */
-(void) setupLoadingIndicators{
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];//initialize the refresh control
    [refreshControl addTarget:self action:@selector(getMessages:) forControlEvents:UIControlEventValueChanged];//add an event listener
    [self.tableView insertSubview:refreshControl atIndex:0];//add into the storyboard

    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];

    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
}
/**
 Parse Query for the messages with this user
 */
-(void) getMessages:(UIRefreshControl* _Nullable)refreshControl{
    PFQuery* messageQ=[PFQuery queryWithClassName:@"Message"];
    [messageQ whereKey:@"sender" containedIn:@[self.user, PFUser.currentUser]];
    [messageQ whereKey:@"receiver" containedIn:@[self.user, PFUser.currentUser]];
    [messageQ orderByDescending:@"createdAt"];
    [messageQ setLimit:RESULTS_SIZE*self.pageNum];
    [messageQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error loading messages" withMessage:error.localizedDescription on:self];
        else
        {
            self.messages=objects;
        }
    }];
}
/**
Triggered when the user scrolls on the table view. Determines if the program should load more data
 depending on how far the user has scrolled and if more data is already loading. Calls the getPosts method
 if more posts are needed.
@param[in] scrollView table view that is being scrolled
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading && self.messages.count!=0)
       {
           int scrollContentHeight=self.tableView.contentSize.height;
           int scrollOffsetThreshold = scrollContentHeight - self.tableView.bounds.size.height;

           if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging)
           {
               self.isMoreDataLoading=YES;
               self.pageNum++;
               CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
               self.loadingMoreView.frame = frame;
               [self.loadingMoreView startAnimating];
               [self getMessages:nil];
           }

       }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Message* currMess= self.messages[indexPath.row];
    if([currMess.sender.username isEqualToString:PFUser.currentUser.username])
    {
        OutgoingMessageCell* omc= [tableView dequeueReusableCellWithIdentifier:@"OutgoingMessageCell" forIndexPath:indexPath];
        omc.message=currMess;
        [omc loadMessage];
        omc.transform = CGAffineTransformMakeScale(1, -1);//flip
        return omc;
    }
    else
    {
        IncomingMessageCell* imc= [tableView dequeueReusableCellWithIdentifier:@"IncomingMessageCell" forIndexPath:indexPath];
        imc.message=currMess;
        [imc loadMessage];
        imc.transform = CGAffineTransformMakeScale(1, -1);//flip
        return imc;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
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
