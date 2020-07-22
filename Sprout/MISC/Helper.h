//
//  Helper.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "Organization.h"
#import "Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface Helper : PFObject
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName;
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion;
+ (void)didLikeOrg:(Organization*)likedOrg sender:(UIViewController* _Nullable)viewC;
+ (void)didUnlikeOrg:(Organization*)unlikedOrg;
+ (void) addOrgToFriendsList:(Organization*)likedOrg;
+ (void) deleteOrgFromFriendsList:(Organization*)unlikedOrg;
+ (void) didLikeEvent:(Event*)likedEvent senderVC:(UIViewController* _Nullable)viewC;
+ (void)didUnlikeEvent:(Event*)unlikedEvent;
+ (void) addEventToFriendsList:(Event*)likedEvent;
+ (void) deleteEventFromFriendsList:(Event*)unlikedEvent;
+ (void)displayAlert:(NSString*)title withMessage:(NSString*)message on:(UIViewController * _Nullable)senderVC;


@end

NS_ASSUME_NONNULL_END
