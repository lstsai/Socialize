//
//  HomeViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()<CreateViewControllerDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) didCreateEvent{
    NSLog(@"Refresh placeholder");
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
