//
//  OrgDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OrgDetailsViewController.h"
#import "Location.h"
@interface OrgDetailsViewController ()

@end

@implementation OrgDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadOrgDetails];
}
-(void) loadOrgDetails{
    self.name.text=self.org.name;
    self.category.text=self.org.category;
    self.cause.text=self.org.cause;
    self.address.text=[Location addressFromLocation:self.org.location];
    self.tagLine.text=self.org.tagLine;
    self.website.text=[self.org.website absoluteString];
    self.mission.text=self.org.missionStatement;
    
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
