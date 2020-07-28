//
//  PersonCell.h
//  Sprout
//
//  Created by laurentsai on 7/17/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Collection view cell to represent users in the people search page
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@import Parse;
@interface PersonCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
-(void) loadData;
@end

NS_ASSUME_NONNULL_END
