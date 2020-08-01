//
//  Message.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Message.h"

@implementation Message
@dynamic sender;
@dynamic receiver;
@dynamic messageText;
@dynamic createdAt;
/**
 Returns the name of the class in parse
 */
+ (nonnull NSString *)parseClassName {
    return @"Message";
}
/**
Creates and saves a comment in parse.
 @param[in] message the string for the message text
 @param[in] toUser the user the chat is being sent to
 @param[in] completion the completion block to be executed when the message is sent
 */
+ (void) sendChat:( NSString * _Nullable )message toUser:(PFUser*)toUser withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    //create post with given info
    Message *newMessage= [Message new];
    newMessage.messageText= message;
    newMessage.sender=[PFUser currentUser];
    newMessage.receiver= toUser;
    [newMessage saveInBackgroundWithBlock:completion];
}
@end
