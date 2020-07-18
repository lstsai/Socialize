//
//  OrgVerticalCell.h
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organization.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrgVerticalCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orgImage;
@property (strong, nonatomic) Organization *org;
@property (weak, nonatomic) IBOutlet UILabel *numLikeLabel;

-(void) loadData;
@end

NS_ASSUME_NONNULL_END
