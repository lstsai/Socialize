//
//  CreatePostViewController.h
//  Sprout
//
//  Created by laurentsai on 7/22/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

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
@end

NS_ASSUME_NONNULL_END
