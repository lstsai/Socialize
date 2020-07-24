//
//  RequestsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RequestsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSArray* friendRequests;

-(void) getFriendRequests;
- (void)didTapAccept:(RequestCell*)sender;
- (void)didTapDelete:(RequestCell*)sender;

@end

NS_ASSUME_NONNULL_END
