//
//  OrgDetailsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organization.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrgDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) Organization *org;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tagLine;
@property (weak, nonatomic) IBOutlet UILabel *mission;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *cause;
@property (weak, nonatomic) IBOutlet UILabel *website;
-(void) loadOrgDetails;


@end

NS_ASSUME_NONNULL_END
