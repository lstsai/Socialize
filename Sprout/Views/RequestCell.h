//
//  RequestCell.h
//  Sprout
//
//  Created by laurentsai on 7/23/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface RequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) PFUser* requestUser;
-(void) loadData;
-(void) showStatus:(NSString*) message;
@end

NS_ASSUME_NONNULL_END
