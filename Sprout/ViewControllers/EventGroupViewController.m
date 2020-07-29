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
@interface EventGroupViewController ()<EventGroupCellDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation EventGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self getPosts];
    [self loadDetails];


}
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
-(void) getPosts{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery* postsQuery= [PFQuery queryWithClassName:@"Post"];
    [postsQuery whereKey:@"event" equalTo:self.event];
    [postsQuery whereKey:@"groupPost" equalTo:@(YES)];
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

- (void)didTapComment:(nonnull Post *)post {
    [self performSegueWithIdentifier:@"commentSegue" sender:post];
}

- (void)didTapUser:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"profileSegue" sender:user];

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventGroupCell *egc=[tableView dequeueReusableCellWithIdentifier:@"EventGroupCell" forIndexPath:indexPath];
    egc.post=self.posts[indexPath.row];
    egc.delegate=self;
    [egc loadDetails];
    return egc;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
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
    }
}



@end
