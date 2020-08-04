//
//  Message.m
//  Sprout
//
//  Created by laurentsai on 7/31/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Message.h"
#import "Helper.h"
@implementation Message
@dynamic sender;
@dynamic receiver;
@dynamic messageText;
@dynamic createdAt;
@dynamic image;
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
 @param[in] image the image the user might attach
 @param[in] completion the completion block to be executed when the message is sent
 */
+ (void) sendMessage:(NSString * _Nullable )message toUser:(PFUser*)toUser withImage:(UIImage*_Nullable) image withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    //create post with given info
    Message *newMessage= [Message new];
    newMessage.image=[Helper getPFFileFromImage:image withName:message];
    newMessage.messageText= message;
    newMessage.sender=[PFUser currentUser];
    newMessage.receiver= toUser;
    [newMessage saveInBackgroundWithBlock:completion];
}
@end
