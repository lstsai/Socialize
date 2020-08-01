//
//  Message.h
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Object to represent a direct message to anoter user
 */
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : PFObject<PFSubclassing>
@property (nonatomic, strong) PFUser *sender;
@property (nonatomic, strong) PFUser *receiver;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSDate *createdAt;

+ (void) sendChat:( NSString * _Nullable )chat toUser:(PFUser*)toUser withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
