//
//  MessagingViewController.h
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface MessagingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) PFUser* user;
@property (strong, nonatomic) NSArray* messages;
@property (nonatomic) int pageNum;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (nonatomic) BOOL isMoreDataLoading;
-(void) getMessages;
- (IBAction)didTapSend:(id)sender;
-(void)keyboardOnScreen:(NSNotification *)notification;
-(void)keyboardOffScreen:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
