//
//  OrgDetailsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrgDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backdropImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tagLine;
@property (weak, nonatomic) IBOutlet UILabel *mission;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *streetAddress;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZip;
@property (weak, nonatomic) IBOutlet UILabel *cause;
@property (weak, nonatomic) IBOutlet UILabel *website;

@end

NS_ASSUME_NONNULL_END
