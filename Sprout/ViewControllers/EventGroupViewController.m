//
//  EventGroupViewController.m
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventGroupViewController.h"
#import "EventGroupCell.h"
#import "CommentsViewController.h"
#import "ProfileViewController.h"
#import "Helper.h"
#import "MBProgressHUD.h"
#import "CreatePostViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Constants.h"

@interface EventGroupViewController ()<EventGroupCellDelegate, UITableViewDelegate, UITableViewDataSource, CreatePostViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation EventGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.emptyDataSetSource=self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self getPosts:@""];
    [self loadDetails];
    self.scrollView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;

}
/**
 Loads the details of the page.
 */
-(void) loadDetails{
    self.eventNameLabel.text=self.event.name;
    [self.event.author fetchIfNeeded];
    self.locationLabel.text=self.event.streetAddress;
    NSString *sdateString, *edateString;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //display the start time and end time differently depending on if start and end are on same day
    if([[NSCalendar currentCalendar] isDate:self.event.startTime inSameDayAsDate:self.event.endTime])
    {
        [dateFormat setDateFormat:@"E, d MMM yyyy\nh:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        [dateFormat setDateFormat:@" - h:mm a"];
        edateString=[dateFormat stringFromDate:self.event.endTime];
        self.dateTimeLabel.text=[sdateString stringByAppendingString:edateString];
    }
    else{
        [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        edateString =[dateFormat stringFromDate:self.event.endTime];
        self.dateTimeLabel.text=[sdateString stringByAppendingFormat:@"\nTo %@", edateString];
    }
    
    if(self.event.image)
    {
        self.eventImageView.file=self.event.image;
        [self.eventImageView loadInBackground];
    }
}
/**
Fetches the posts from parse that is related to this group. Includes posts that matches the search
 @param[in] search the search text to match for posts
 */
-(void) getPosts:(NSString*)search{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery* postsQuery= [PFQuery queryWithClassName:@"Post"];
    [postsQuery whereKey:@"event" equalTo:self.event];
    [postsQuery whereKey:@"groupPost" equalTo:@(YES)];
    [postsQuery whereKey:@"postDescription" matchesRegex:[NSString stringWithFormat:@"(?i)%@",search]];
    [postsQuery orderByDescending:@"createdAt"];
    [postsQuery includeKey:@"author"];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [Helper displayAlert:@"Error getting posts" withMessage:error.localizedDescription on:self];
        }
        else{
            self.posts=objects;
            [self.tableView reloadData];
        }
    }];
}
/**
 Triggered when the uses presses the comment button on a particular post
 @param[in] post the post that the user tapped on
 */
- (void)didTapComment:(nonnull Post *)post {
    [self performSegueWithIdentifier:@"commentSegue" sender:post];
}
/**
Triggered when the uses taps on the profile image of a post
@param[in] user the post that the user tapped on
*/
- (void)didTapUser:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"profileSegue" sender:user];

}
/**
Triggered when the uses presses the search button. Reloads the table view to get posts with the search
@param[in] sender  the button the user pressed
*/
- (IBAction)didTapSearch:(id)sender {
    [self getPosts:self.searchBar.text];
    [self.searchBar endEditing:YES];
}
/**
Triggered after the user creates a new post for this group, reloads the table view
*/
-(void) didCreatePost{
    [self getPosts:@""];
}
/**
Table view delegate method. returns a postcell to be shown.
@param[in] tableView the table that is calling this method
@param[in] indexPath the path for the returned cell to be displayed
@return the cell that should be shown in the passed indexpath
*/
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventGroupCell *egc=[tableView dequeueReusableCellWithIdentifier:@"EventGroupCell" forIndexPath:indexPath];
    egc.post=self.posts[indexPath.row];
    egc.delegate=self;
    [egc loadDetails];
    return egc;
}
/**
Table view delegate method. returns the number of sections that the table has. This table only has
 one section so it always returns the total number of posts
@param[in] tableView the table that is calling this method
@param[in] section the section in question
@return the number of posts
*/
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}
/**
Empty table view delegate method. Returns the image to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the image to be shown
*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"share-post"];
}
/**
Empty table view delegate method. Returns the title to be displayed when there are no posts
@param[in] scrollView the table view that is empty
@return the title to be shown
*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Posts to Show for this Event";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:EMPTY_TITLE_FONT_SIZE],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/**
Empty table view delegate method. Returns if the empty view should be shown
@param[in] scrollView the table view that is empty
@return if the empty view shouls be shown
 YES: if there are no posts
 NO: there are posts
*/
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.posts.count==0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"commentSegue"])
    {
        CommentsViewController *commentVC=segue.destinationViewController;
        commentVC.post=(Post*)sender;
    }
    else if([segue.identifier isEqualToString:@"profileSegue"])
    {
        ProfileViewController *profileVC=segue.destinationViewController;
        profileVC.user=(PFUser*)sender;
    }
    else if([segue.identifier isEqualToString:@"createSegue"])
    {
        CreatePostViewController *createVC=segue.destinationViewController;
        createVC.event=self.event;
        createVC.org=nil;
        createVC.isGroupPost=YES;
        createVC.delegate=self;
    }
}



@end
