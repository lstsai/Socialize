//
//  HomeViewController.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateViewController.h"
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (nonatomic) int pageNum;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;

-(void) getPosts;
-(void) setupLoadingIndicators;
@end

NS_ASSUME_NONNULL_END
