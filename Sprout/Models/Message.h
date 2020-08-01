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
@property (nonatomic, strong) PFFileObject *image;


+ (void) sendMessage:( NSString * _Nullable )message toUser:(PFUser*)toUser withImage:(UIImage*_Nullable) image withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
