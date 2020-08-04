//
//  EditOrgViewController.h
//  Sprout
//
//  Created by laurentsai on 8/4/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimedOrganization.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface EditOrgViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *orgImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *taglineField;
@property (weak, nonatomic) IBOutlet UITextField *causeField;
@property (weak, nonatomic) IBOutlet UITextField *categoryField;
@property (weak, nonatomic) IBOutlet UITextField *websiteField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextView *missionTextView;
@property ClaimedOrganization* claimedOrg;

-(void) loadCurrentInfo;
-(void) keyboardOnScreen:(NSNotification *)notification;
-(void) keyboardOffScreen:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
