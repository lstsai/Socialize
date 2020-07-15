//
//  EventSearchViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventSearchViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface EventSearchViewController ()

@end

@implementation EventSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//-(void) getEvents:( UIRefreshControl * _Nullable )refreshControl{
//    if(![refreshControl isKindOfClass:[UIRefreshControl class]])
//         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//     
//     NSString* stateSearch, *citySearch;
//     if([self.stateField.text isEqualToString:@""] && [self.cityField.text  isEqualToString:@""])
//         stateSearch=self.locManager.currentPlacemark.administrativeArea;//the state
//         //citySearch=self.locManager.currentPlacemark.locality;
//     else
//         stateSearch=self.stateField.text;
//     
//     citySearch=self.cityField.text;
//    PFQuery *eventsQuery=[PFQuery queryWithClassName:@"Event"];
//    [eventsQuery setLimit:RESULTS_SIZE];
//    [eventsQuery includeKey:@"author"];
//    [eventsQuery whereKey:@"name" containsString:self.searchBar.text];
//}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//     if(!self.isMoreDataLoading)
//       {
//           int scrollContentHeight=self.tableView.contentSize.height;
//           int scrollOffsetThreshold = scrollContentHeight - self.tableView.bounds.size.height;
//           
//           if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging)
//           {
//               self.isMoreDataLoading=YES;
//               self.pageNum++;
//               CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
//               self.loadingMoreView.frame = frame;
//               [self.loadingMoreView startAnimating];
//               [self loadMoreResults];
//           }
//           
//       }
//}
//-(void) loadMoreResults{
//    NSDictionary *params= @{@"app_id": [[NSProcessInfo processInfo] environment][@"CNapp-id"], @"app_key": [[NSProcessInfo processInfo] environment][@"CNapp-key"], @"search":self.searchBar.text, @"rated":@"TRUE", @"state": self.stateField.text, @"city": self.cityField.text, @"pageNum": @(self.pageNum), @"pageSize":@(RESULTS_SIZE)};
//    [[APIManager shared] getOrganizationsWithCompletion:params completion:^(NSArray * _Nonnull organizations, NSError * _Nonnull error) {
//        if(error)
//        {
//            NSLog(@"Error getting organizations: %@", error.localizedDescription);
//        }
//        else{
//            [self.organizations addObjectsFromArray:organizations];
//            [self.tableView reloadData];
//            [self.loadingMoreView stopAnimating];
//        }
//        self.isMoreDataLoading=NO;
//
//    }];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
