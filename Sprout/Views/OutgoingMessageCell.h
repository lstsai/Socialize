//
//  OutgoingMessageCell.h
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
Cell representing an out going message
*/
#import <UIKit/UIKit.h>
#import "Message.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface OutgoingMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) Message* message;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet PFImageView *messageImage;
-(void) loadMessage;
@end

NS_ASSUME_NONNULL_END
