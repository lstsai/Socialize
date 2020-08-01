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
#import "UIScrollView+EmptyDataSet.h"
@interface MessagingViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);//flip the table view upside down
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.messageTextField.delegate=self;
    self.messages=[[NSArray alloc]init];
    self.pageNum=1;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationItem.title=self.user.username;
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
    [messageQ includeKeys:@[@"sender", @"receiver"]];
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
            [self.tableView reloadData];
        }
    }];
}
/**
 When the users presses return, send messages
 @param[in] textField the textfield that pressed return
 @return NO, dont return, just send the message
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.messageTextField resignFirstResponder];
    [self didTapSend:textField];
    return NO;
}
/**
 Called when the keyboard appears on screen, moves the view up in order to show the text field
 @param[in] notification the notification to alert the keyboard appeared
 */
-(void)keyboardOnScreen:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame= [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
        self.view.transform=CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -1*keyboardFrame.size.height + CELL_TOP_OFFSET*1.5);
    }];
}
/**
 Called when the keyboard will hide on screen, moves the view back down
 @param[in] notification the notification to alert the keyboard will hide
 */
-(void)keyboardOffScreen:(NSNotification *)notification{
    [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
        self.view.transform=CGAffineTransformIdentity;
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
/**
Table view delegate method. returns a messageCell to be shown.
@param[in] tableView the table that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
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
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of messages
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of messages
*/
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
/**
 Triggered when the user sends the messages. Will post the message in chat
 and clear the field
 @param[in] sender the button that was tapped
 */
- (IBAction)didTapSend:(id)sender {
    if([self.messageTextField.text isEqualToString:@""])
        return;
    [Message sendMessage:self.messageTextField.text toUser:self.user withImage:nil withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error sending message" withMessage:error.localizedDescription on:self];
        else{
            [self getMessages:nil];
            [Helper performSelectorInBackground:@selector(updateMessageOrder:) withObject:self.user];
        }
        self.messageTextField.text=@"";
    }];
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
