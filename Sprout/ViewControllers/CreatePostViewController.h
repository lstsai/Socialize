//
//  CreatePostViewController.h
//  Sprout
//
//  Created by laurentsai on 7/22/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View controller that is displayed as the user is creating a post about an organization or event
 */
#import <UIKit/UIKit.h>
#import "Event.h"
#import "Organization.h"
#import "UITextView+Placeholder.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface CreatePostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) Organization * _Nullable org;
@property (strong, nonatomic) Event * _Nullable event;
@property (nonatomic) BOOL isGroupPost;
@property (weak, nonatomic) IBOutlet UILabel *attachImageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImage;
@end

NS_ASSUME_NONNULL_END
