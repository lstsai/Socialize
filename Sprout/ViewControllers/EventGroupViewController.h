//
//  EventGroupViewController.h
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface EventGroupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Event* event;
@property (strong, nonatomic) NSArray* posts;
-(void) getPosts;
-(void) loadDetails;
@end

NS_ASSUME_NONNULL_END
