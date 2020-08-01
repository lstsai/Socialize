//
//  OutgoingMessageCell.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "OutgoingMessageCell.h"

@implementation OutgoingMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 Load out going message and image if applicable
 */
-(void) loadMessage{
    self.messageLabel.text=self.message.messageText;
    if(self.message.image)
    {
        self.messageImage.hidden=NO;
        self.messageImage.file=self.message.image;
        [self.messageImage loadInBackground];
    }
    else
    {
        self.messageImage.hidden=YES;
    }
    [self.stackView layoutIfNeeded];
    [self.contentView layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
