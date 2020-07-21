//
//  HomeViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "HomeViewController.h"
#import "PostCell.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "AppDelegate.h"
@interface HomeViewController ()<CreateViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) didCreateEvent{
    [self getPosts];
}

-(void) getPosts{
    PFQuery *postsQ= [PFQuery queryWithClassName:@"Post"];
    [postsQ orderByDescending:@"createdAt"];
    [postsQ setLimit:RESULTS_SIZE];
    [postsQ includeKey:@"relatedObject"];
    [postsQ includeKey:@"author"];
    [postsQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
        {
            [AppDelegate displayAlert:@"Error Loading Posts" withMessage:error.localizedDescription on:self];
        }
        else{
            self.posts=[objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *postCell= [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    return postCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
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
}



@end
