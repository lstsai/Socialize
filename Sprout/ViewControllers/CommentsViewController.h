//
//  CommentsViewController.h
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface CommentsViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Post* post;
@property (strong, nonatomic) NSArray *comments;

-(void) getPostComments;
@end

NS_ASSUME_NONNULL_END
