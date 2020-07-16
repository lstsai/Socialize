//
//  EventCollectionCell.m
//  Sprout
//
//  Created by laurentsai on 7/16/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventCollectionCell.h"

@implementation EventCollectionCell
-(void) loadEventCell:(Event*)event{
    
    self.eventImage.file=event.image;
    [self.eventImage loadInBackground];
    self.eventNameLabel.text=event.name;
}
@end
